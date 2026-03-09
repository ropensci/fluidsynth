#include <fluidsynth.h>
#include <Rinternals.h>
#include <stdlib.h>
#include <R_ext/Rdynload.h>
#ifdef HAS_LIBSDL2
#include <SDL2/SDL.h>
#endif
#ifdef HAVE_GLIB
#include <glib.h>
#endif

/* .Call calls */
extern SEXP C_fluidsynth_list_settings(void);
extern SEXP C_fluidsynth_list_options(SEXP);
extern SEXP C_fluidsynth_get_default(SEXP);
extern SEXP C_fluidsynth_version(void);
extern SEXP C_midi_play(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP C_midi_read(SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
  {"C_fluidsynth_list_options", (DL_FUNC) &C_fluidsynth_list_options, 1},
  {"C_fluidsynth_get_default", (DL_FUNC) &C_fluidsynth_get_default, 1},
  {"C_fluidsynth_list_settings", (DL_FUNC) &C_fluidsynth_list_settings, 0},
  {"C_fluidsynth_version", (DL_FUNC) &C_fluidsynth_version, 0},
  {"C_midi_play", (DL_FUNC) &C_midi_play, 5},
  {"C_midi_read", (DL_FUNC) &C_midi_read, 2},
  {NULL, NULL, 0}
};

static void logging_callback(int level, const char *message, void *data){
  if(level <= FLUID_ERR){
    REprintf("[FluidSynth] %s\n", message);
  }
}

#ifdef HAVE_GLIB
static void glib_log_suppress(const gchar *log_domain, GLogLevelFlags log_level,
                               const gchar *message, gpointer user_data){
  /* Suppress GLib warnings such as "Home directory not accessible: Permission denied"
   * which appear on build servers where HOME is not accessible and cannot be suppressed
   * by R's suppressMessages(). Only non-critical GLib messages are intercepted here. */
  (void)log_domain; (void)log_level; (void)message; (void)user_data;
}
#endif

void R_init_fluidsynth(DllInfo *dll){
#ifdef HAS_LIBSDL2
   SDL_Init(SDL_INIT_AUDIO);
#endif
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  fluid_set_log_function(FLUID_PANIC, logging_callback, NULL);
  fluid_set_log_function(FLUID_ERR, logging_callback, NULL);
  fluid_set_log_function(FLUID_WARN, logging_callback, NULL);
  fluid_set_log_function(FLUID_INFO, logging_callback, NULL);
  fluid_set_log_function(FLUID_DBG, logging_callback, NULL);
#ifdef HAVE_GLIB
  g_log_set_handler(NULL, G_LOG_LEVEL_WARNING | G_LOG_LEVEL_MESSAGE | G_LOG_LEVEL_INFO | G_LOG_LEVEL_DEBUG,
                    glib_log_suppress, NULL);
#endif
}
