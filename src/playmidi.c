#include <fluidsynth.h>
#include <Rinternals.h>
#include <unistd.h>

static void check_interrupt_fn(void *dummy) {
  R_CheckUserInterrupt();
}

static int pending_interrupt(void) {
  return !(R_ToplevelExec(check_interrupt_fn, NULL));
}

static void set_user_settings(fluid_settings_t* settings, SEXP userset){
  SEXP optnames = Rf_getAttrib(userset, R_NamesSymbol);
  for(int i = 0; i < Rf_length(userset); i++){
    SEXP val = VECTOR_ELT(userset, i);
    const char *optname = CHAR(STRING_ELT(optnames, i));
    int type = fluid_settings_get_type(settings, optname);
    switch (type) {
    case FLUID_NUM_TYPE:
      fluid_settings_setnum(settings, optname, REAL(val)[0]);
      break;
    case FLUID_INT_TYPE:
      fluid_settings_setint(settings, optname, (int) REAL(val)[0]);
      break;
    case FLUID_STR_TYPE:
      fluid_settings_setstr(settings, optname, CHAR(STRING_ELT(val, 0)));
      break;
    }
  }
}

SEXP C_midi_play(SEXP midi, SEXP soundfont, SEXP output, SEXP userset, SEXP progress){
  const char *midi_file = CHAR(Rf_asChar(midi));
  const char *soundfont_file = CHAR(Rf_asChar(soundfont));
  const char *output_str = Rf_length(output) ? CHAR(Rf_asChar(output)) : NULL;
  const int play_to_file = Rf_inherits(output, "outputfile");

  if(!fluid_is_midifile(midi_file))
    Rf_error("File is not a midi: %s ", midi_file);
  if(!fluid_is_soundfont(soundfont_file))
    Rf_error("File is not a soundfont: %s ",soundfont_file);
  fluid_settings_t* settings = new_fluid_settings();

  /* To save output to a file: https://www.fluidsynth.org/api/settings_audio.html */
  if(play_to_file){
    //fluid_settings_setstr(settings, "audio.file.type", "wav");
    fluid_settings_setstr(settings, "audio.file.name", output_str);
    fluid_settings_setstr(settings, "player.timing-source", "sample");
    fluid_settings_setint(settings, "synth.lock-memory", 0);
  } else {
    if(output_str)
      fluid_settings_setstr(settings, "audio.driver", output_str);
  }

  /* Custom user settings */
  set_user_settings(settings, userset);

  fluid_synth_t* synth = new_fluid_synth(settings);
  fluid_player_t* player = new_fluid_player(synth);
  fluid_synth_sfload(synth, soundfont_file, 1);
  fluid_player_add(player, midi_file);

  /* start the synthesizer thread */
  fluid_audio_driver_t* adriver = NULL;
  fluid_file_renderer_t* renderer = NULL;
  if(play_to_file){
    renderer = new_fluid_file_renderer(synth);
  } else {
    adriver = new_fluid_audio_driver(settings, synth);
  }

  /* play the midi files, if any */
  fluid_player_play(player);

  /* play until we interrupt */
  int total = 0;
  while(fluid_player_get_status(player) == FLUID_PLAYER_PLAYING){
    if(play_to_file){
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
        REprintf("\rSynthesizing midi: %d/%d", now, total);
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
