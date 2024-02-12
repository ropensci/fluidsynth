#include <Rinternals.h>
#include <stdlib.h>
#include <R_ext/Rdynload.h>

/* .Call calls */
extern SEXP C_midi_play(SEXP, SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
  {"C_midi_play", (DL_FUNC) &C_midi_play, 4},
  {NULL, NULL, 0}
};

void R_init_miditools(DllInfo *dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
