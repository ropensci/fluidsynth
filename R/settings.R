#' Fluidsynth settings
#'
#' List available settings and their types.
#'
#' @export
#' @rdname fluidsynth_settings
#' @useDynLib miditools C_fluidsynth_list_settings
fluidsynth_settings <- function(){
  out <- .Call(C_fluidsynth_list_settings)
  names(out) <- c('name', 'type')
  data.frame(out)
}
