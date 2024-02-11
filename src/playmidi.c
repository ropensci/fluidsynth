#include <fluidsynth.h>
#include <Rinternals.h>
#include <unistd.h>

void check_interrupt_fn(void *dummy) {
  R_CheckUserInterrupt();
}

int pending_interrupt(void) {
  return !(R_ToplevelExec(check_interrupt_fn, NULL));
}

SEXP C_midi_play(SEXP midi, SEXP soundfont){
  const char *midi_file = CHAR(Rf_asChar(midi));
  const char *soundfont_file = CHAR(Rf_asChar(soundfont));
  if(!fluid_is_midifile(midi_file))
    Rf_error("File is not a midi: %s ", midi_file);
  if(!fluid_is_soundfont(soundfont_file))
    Rf_error("File is not a soundfont: %s ",soundfont_file);
  fluid_settings_t* settings = new_fluid_settings();
  fluid_synth_t* synth = new_fluid_synth(settings);
  fluid_player_t* player = new_fluid_player(synth);
  fluid_synth_sfload(synth, soundfont_file, 1);
  fluid_player_add(player, midi_file);

  /* start the synthesizer thread */
  fluid_audio_driver_t* adriver = new_fluid_audio_driver(settings, synth);

  /* play the midi files, if any */
  fluid_player_play(player);

  /* play until we interrupt */
  while(fluid_player_get_status(player) == FLUID_PLAYER_PLAYING){
    usleep(200);
    if(pending_interrupt()){
      fluid_player_stop(player);
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
