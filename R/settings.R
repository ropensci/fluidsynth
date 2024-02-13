#' Fluidsynth settings
#'
#' List available settings and their types.
#'
#' @export
#' @rdname fluidsynth_settings
#' @useDynLib miditools C_fluidsynth_list_settings
#' @examples
#' # List available settings:
#' fluidsynth_settings()
#' fluidsynth_list_options('audio.driver')
fluidsynth_settings <- function(){
  out <- .Call(C_fluidsynth_list_settings)
  names(out) <- c('name', 'type')
  data.frame(out)
}

#' @export
#' @rdname fluidsynth_settings
#' @useDynLib miditools C_fluidsynth_list_options
#' @param setting string with one of the options listed in [fluidsynth_settings]
fluidsynth_list_options <- function(setting){
  setting <- as.character(setting)
  .Call(C_fluidsynth_list_options, setting)
}
