#' Managing soundfonts
#'
#' FluidSynth requires a soundfont to synthesize a midi. On Linux distributions
#' some soundfounds are often preinstalled, though their quality varies. If your
#' midi sounds very poor, try seleting another soundfont.
#'
#' [GenralUser-GS](https://schristiancollins.com/generaluser) by S. Christian Collins
#' is a nice free soundfont. The `soundfont_generaluser_gs()` function will
#' automatically download a copy to for this package.
#'
#' @export
#' @name soundfonts
#' @rdname soundfonts
#' @param download automatically download soundfont if none exists.
soundfont_path <- function(download = TRUE){
  general_user <- soundfont_generaluser_gs(download = FALSE)
  if(file.exists(general_user)){
    return(general_user)
  }
  default <- fluidsynth_setting_default('synth.default-soundfont')
  if(file.exists(default)){
    return(default)
  }
  soundfont_generaluser_gs(download = download)
}

#' @export
#' @rdname soundfonts
soundfont_generaluser_gs <- function(download = TRUE){
  path <- file.path(system.file(package = 'fluidsynth'), 'generaluser-gs/v1.471.sf2')
  if(!file.exists(path) && isTRUE(download)){
    url <- 'https://github.com/ropensci/fluidsynth/releases/download/generaluser-gs-v1.471/generaluser-gs-v1.471.zip'
    if(getOption('timeout') < 300) options(timeout = 300)
    on.exit(unlink('generaluser-gs-v1.471.zip'))
    download.file(url, 'generaluser-gs-v1.471.zip')
    dir.create(dirname(path), showWarnings = FALSE)
    unzip('generaluser-gs-v1.471.zip', exdir = dirname(path))
  }
  return(path)
}
