#' Fluidsynth settings
#'
#' Get available settings and their types.
#' See [fluidsynth docs](https://www.fluidsynth.org/api/fluidsettings.html)
#' for more information on the available options.
#'
#' @export
#' @name fluidsynth_settings
#' @rdname fluidsynth_settings
#' @family fluidsynth
#' @returns a list with available options
#' @useDynLib fluidsynth C_fluidsynth_list_settings
#' @references [FluidSynth Settings Reference](https://www.fluidsynth.org/api/fluidsettings.html)
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
#' @useDynLib fluidsynth C_fluidsynth_list_options
#' @param setting string with one of the options listed in [fluidsynth_setting_list()], see examples.
fluidsynth_setting_options <- function(setting){
  setting <- as.character(setting)
  .Call(C_fluidsynth_list_options, setting)
}

#' @export
#' @rdname fluidsynth_settings
#' @useDynLib fluidsynth C_fluidsynth_get_default
fluidsynth_setting_default <- function(setting){
  setting <- as.character(setting)
  .Call(C_fluidsynth_get_default, setting)
}

#' @export
#' @rdname fluidsynth_settings
#' @useDynLib fluidsynth C_fluidsynth_version
libfluidsynth_version <- function(){
  .Call(C_fluidsynth_version)
}

validate_fluidsynth_settings <- function(opts){
  if(length(opts)){
    settings <- fluidsynth_setting_list()
    for(o in names(opts)){
      if(!(o %in% settings$name))
        stop("Unsupported fluidsynth option: ", o)
      val <- opts[[o]]
      if(length(val) != 1)
        stop("Option is not of length 1: ", o)
      type <- settings[settings$name == o, "type"]
      if(type == 'string' && !is.character(val))
        stop("Option should be a string: ", o)
      if(type != 'string'){
        if(!is.numeric(val))
          stop("Option should be a number: ", o)
        opts[[o]] <- as.numeric(val)
      }
    }
    return(opts)
  }
}
