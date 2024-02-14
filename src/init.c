#include <Rinternals.h>
#include <stdlib.h>
#include <R_ext/Rdynload.h>
#ifdef HAS_LIBSDL2
#include <SDL2/SDL.h>
#endif

/* .Call calls */
extern SEXP C_fluidsynth_list_settings(void);
extern SEXP C_fluidsynth_list_options(SEXP);
extern SEXP C_fluidsynth_get_default(SEXP);
extern SEXP C_midi_play(SEXP, SEXP, SEXP, SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
  {"C_fluidsynth_list_options", (DL_FUNC) &C_fluidsynth_list_options, 1},
  {"C_fluidsynth_get_default", (DL_FUNC) &C_fluidsynth_get_default, 1},
  {"C_fluidsynth_list_settings", (DL_FUNC) &C_fluidsynth_list_settings, 0},
  {"C_midi_play", (DL_FUNC) &C_midi_play, 5},
  {NULL, NULL, 0}
};

void R_init_miditools(DllInfo *dll){
#ifdef HAS_LIBSDL2
   SDL_Init(SDL_INIT_AUDIO);
#endif
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
