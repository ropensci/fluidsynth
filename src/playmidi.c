#include <fluidsynth.h>
#include <Rinternals.h>
#include <unistd.h>

void check_interrupt_fn(void *dummy) {
  R_CheckUserInterrupt();
}

int pending_interrupt(void) {
  return !(R_ToplevelExec(check_interrupt_fn, NULL));
}

SEXP C_midi_play(SEXP midi, SEXP soundfont, SEXP outfile, SEXP audio_driver, SEXP progress){
  const char *midi_file = CHAR(Rf_asChar(midi));
  const char *soundfont_file = CHAR(Rf_asChar(soundfont));
  const char *output_file = Rf_length(outfile) ? CHAR(Rf_asChar(outfile)) : NULL;
  if(!fluid_is_midifile(midi_file))
    Rf_error("File is not a midi: %s ", midi_file);
  if(!fluid_is_soundfont(soundfont_file))
    Rf_error("File is not a soundfont: %s ",soundfont_file);
  fluid_settings_t* settings = new_fluid_settings();

  /* To save output to a file: https://www.fluidsynth.org/api/settings_audio.html */
  if(output_file){
    fluid_settings_setstr(settings, "audio.file.type", "wav");
    fluid_settings_setstr(settings, "audio.file.name", CHAR(Rf_asChar(outfile)));
    fluid_settings_setstr(settings, "player.timing-source", "sample");
    fluid_settings_setint(settings, "synth.lock-memory", 0);
  } else {
    if(Rf_length(audio_driver))
      fluid_settings_setstr(settings, "audio.driver", CHAR(Rf_asChar(audio_driver)));
  }

  fluid_synth_t* synth = new_fluid_synth(settings);
  fluid_player_t* player = new_fluid_player(synth);
  fluid_synth_sfload(synth, soundfont_file, 1);
  fluid_player_add(player, midi_file);

  /* start the synthesizer thread */
  fluid_audio_driver_t* adriver = NULL;
  fluid_file_renderer_t* renderer = NULL;
  if(output_file){
    renderer = new_fluid_file_renderer(synth);
  } else {
    adriver = new_fluid_audio_driver(settings, synth);
  }

  /* play the midi files, if any */
  fluid_player_play(player);

  /* play until we interrupt */
  int total = 0;
  while(fluid_player_get_status(player) == FLUID_PLAYER_PLAYING){
    if(output_file){
      if(fluid_file_renderer_process_block(renderer) != FLUID_OK)
        break;
    } else {
      usleep(200);
    }
    if(pending_interrupt()){
      fluid_player_stop(player);
    }
    if(Rf_asLogical(progress)){
      int now = fluid_player_get_current_tick(player);
      if(total == 0)
        total = fluid_player_get_total_ticks(player);
      if(now < total){
        REprintf("\r%d/%d", now, total);
      } else {
        REprintf("\r");
      }
    }
  }

  /* wait for playback termination */
  fluid_player_join(player);

  /* cleanup */
  delete_fluid_audio_driver(adriver);
  delete_fluid_player(player);
  delete_fluid_synth(synth);
  delete_fluid_settings(settings);
  return R_NilValue;
}
