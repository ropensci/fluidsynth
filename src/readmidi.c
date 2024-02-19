#include <fluidsynth.h>
#include <Rinternals.h>
#include <unistd.h>

static void check_interrupt_fn(void *dummy) {
  R_CheckUserInterrupt();
}

static int pending_interrupt(void) {
  return !(R_ToplevelExec(check_interrupt_fn, NULL));
}

static int event_count = 0;
static fluid_player_t* global_player = NULL;
static int event_callback(void *data, fluid_midi_event_t *event){
  if(data){
    //fluid_event_t *evt = new_fluid_event();
    //fluid_event_from_midi_event(evt, event);
    SEXP df = data;
    INTEGER(VECTOR_ELT(df, 0))[event_count] = fluid_player_get_current_tick(global_player);
    INTEGER(VECTOR_ELT(df, 1))[event_count] = fluid_midi_event_get_channel(event);
    INTEGER(VECTOR_ELT(df, 2))[event_count] = fluid_midi_event_get_type(event);
    INTEGER(VECTOR_ELT(df, 3))[event_count] = fluid_midi_event_get_key(event);
    INTEGER(VECTOR_ELT(df, 4))[event_count] = fluid_midi_event_get_value(event);
    //delete_fluid_event(evt);
  }
  event_count++;
  return FLUID_OK;
}

SEXP C_midi_read(SEXP midi, SEXP progress){
  const char *midi_file = CHAR(Rf_asChar(midi));
  if(!fluid_is_midifile(midi_file))
    Rf_error("File is not a midi: %s ", midi_file);
  fluid_settings_t* settings = new_fluid_settings();
  fluid_synth_t* synth = new_fluid_synth(settings);
  fluid_player_t* player = new_fluid_player(synth);
  fluid_player_add(player, midi_file);
  fluid_player_set_playback_callback(player, event_callback, NULL);
  fluid_player_play(player);

  /* First loop over midi to count number of events */
  event_count = 0;
  while(fluid_player_get_status(player) == FLUID_PLAYER_PLAYING){
    if(fluid_synth_process(synth, 2000, 0, NULL, 0, NULL) != FLUID_OK)
      break;
    if(pending_interrupt())
      fluid_player_stop(player);
    if(Rf_asLogical(progress))
      REprintf("\rCounting MIDI events: %d", event_count);
  }

  /* Allocate output data */
  static int df_columns = 5;
  SEXP df = PROTECT(Rf_allocVector(VECSXP, df_columns));
  for(int i = 0; i < df_columns; i++){
    SET_VECTOR_ELT(df, i, PROTECT(Rf_allocVector(INTSXP, event_count)));
  }

  /* Restart play again */
  event_count = 0;
  fluid_player_join(player);

  /* Workaround for hang in Ubuntu 20.04: reset player */
#if FLUIDSYNTH_VERSION_MAJOR == 2 && FLUIDSYNTH_VERSION_MINOR < 2
  delete_fluid_player(player);
  player = new_fluid_player(synth);
  fluid_player_add(player, midi_file);
#endif

  fluid_player_set_playback_callback(player, event_callback, df);
  global_player = player;
  fluid_player_play(player);
  while(fluid_player_get_status(player) == FLUID_PLAYER_PLAYING){
    if(fluid_synth_process(synth, 2000, 0, NULL, 0, NULL) != FLUID_OK)
      break;
    if(pending_interrupt())
      fluid_player_stop(player);
    if(Rf_asLogical(progress))
      REprintf("\rStoring MIDI events: %d  ", event_count);
  }

  /* wait for playback termination */
  fluid_player_join(player);

  /* cleanup */
  delete_fluid_player(player);
  delete_fluid_synth(synth);
  delete_fluid_settings(settings);
  UNPROTECT(1+df_columns);
  return df;
}
