#' Managing soundfonts
#'
#' FluidSynth requires a soundfont to synthesize a midi. On Linux distributions
#' some soundfonts are often preinstalled, though their quality varies. If your
#' midi sounds very poor, try using another soundfont.
#'
#' [GeneralUser-GS](https://schristiancollins.com/generaluser) by S. Christian Collins
#' is a nice free soundfont. You can use `soundfont_download()` to install a copy
#' of this soundbank for use by this package.
#'
#' @export
#' @name soundfonts
#' @rdname soundfonts
#' @family fluidsynth
#' @returns the path to a local soundfont to synthesize a midi file.
#' @param download automatically download soundfont if none exists.
soundfont_path <- function(download = FALSE){
  if(file.exists(generaluser_gs_path())){
    return(generaluser_gs_path())
  }
  default <- fluidsynth_setting_default('synth.default-soundfont')
  if(file.exists(default)){
    return(default)
  }
  if(grepl('redhat-linux', R.version$platform)){
    stop('No soundfont found. Install one using either "yum install fluid-soundfont-gm" or in R: soundfont_download()')
  }
  if(isTRUE(download)){
    return(soundfont_download())
  }
  stop('No default soundfont found. You can install using: soundfont_download()')
}

#' @export
#' @rdname soundfonts
soundfont_download <- function(){
  path <- generaluser_gs_path()
  if(!file.exists(path)){
    url <- 'https://github.com/ropensci/fluidsynth/releases/download/generaluser-gs-v1.471/generaluser-gs-v1.471.zip'
    if(getOption('timeout') < 300) {
      old <- options(timeout = 300)
      on.exit(options(old))
    }
    tmp <- tempfile(fileext = '.zip')
    on.exit(unlink(tmp), add = TRUE)
    utils::download.file(url, tmp, quiet = TRUE)
    dir.create(dirname(path), showWarnings = FALSE)
    utils::unzip(tmp, exdir = dirname(path))
  }
  return(path)
}

generaluser_gs_path <- function(){
  file.path(rappdirs::user_data_dir('soundfonts'), 'generaluser-gs/v1.471.sf2')
}
