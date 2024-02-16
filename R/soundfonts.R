#' Managing soundfonts
#'
#' FluidSynth requires a soundfont to synthesize a midi. On Linux distributions
#' some soundfounds are often preinstalled, though their quality varies. If your
#' midi sounds very poor, try seleting another soundfont.
#'
#' [GenralUser-GS](https://schristiancollins.com/generaluser) by S. Christian Collins
#' is a nice free soundfont. The `download_generaluser_gs()` function will
#' automatically download a copy to that will be picked up by this package.
#'
#' @export
#' @name soundfonts
#' @rdname soundfonts
#' @param download automatically download soundfont if none exists.
soundfont_path <- function(download = TRUE){
  if(file.exists(generaluser_gs_path())){
    return(generaluser_gs_path())
  }
  default <- fluidsynth_setting_default('synth.default-soundfont')
  if(file.exists(default)){
    return(default)
  }
  if(grepl('redhat-linux', R.version$platform)){
    stop('No soundfont found. Install one using either "yum install fluid-soundfont-gm" or in R: download_generaluser_gs()')
  }
  download_generaluser_gs()
}

#' @export
#' @rdname soundfonts
download_generaluser_gs <- function(){
  path <- generaluser_gs_path()
  if(!file.exists(path)){
    url <- 'https://github.com/ropensci/fluidsynth/releases/download/generaluser-gs-v1.471/generaluser-gs-v1.471.zip'
    if(getOption('timeout') < 300) options(timeout = 300)
    on.exit(unlink('generaluser-gs-v1.471.zip'))
    utils::download.file(url, 'generaluser-gs-v1.471.zip')
    dir.create(dirname(path), showWarnings = FALSE)
    utils::unzip('generaluser-gs-v1.471.zip', exdir = dirname(path))
  }
  return(path)
}

generaluser_gs_path <- function(){
  file.path(system.file(package = 'fluidsynth'), 'generaluser-gs/v1.471.sf2')
}

demo_midi <- function(){
  list.files(system.file(package = 'fluidsynth', 'generaluser-gs/midi'), full.names = TRUE)
}
