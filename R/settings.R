#' Fluidsynth settings
#'
#' Get available settings and their types.
#'
#' @export
#' @name fluidsynth_settings
#' @rdname fluidsynth_settings
#' @useDynLib miditools C_fluidsynth_list_settings
#' @examples
#' # List available settings:
#' fluidsynth_setting_list()
#' fluidsynth_setting_options('audio.driver')
#' fluidsynth_setting_default('synth.sample-rate')
fluidsynth_setting_list <- function(){
  out <- .Call(C_fluidsynth_list_settings)
  names(out) <- c('name', 'type')
  data.frame(out)
}

#' @export
#' @rdname fluidsynth_settings
#' @useDynLib miditools C_fluidsynth_list_options
#' @param setting string with one of the options listed in [fluidsynth_setting_list()]
fluidsynth_setting_options <- function(setting){
  setting <- as.character(setting)
  .Call(C_fluidsynth_list_options, setting)
}

#' @export
#' @rdname fluidsynth_settings
#' @useDynLib miditools C_fluidsynth_get_default
fluidsynth_setting_default <- function(setting){
  setting <- as.character(setting)
  .Call(C_fluidsynth_get_default, setting)
}
