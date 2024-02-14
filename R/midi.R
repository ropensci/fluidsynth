#' Play or convert a midi file
#'
#' Renders a midi file to your audio device or to a wav file. Additional settings
#' can be specified, see [fluidsynth_setting_list] for availble options.
#' On Linux you may need to specify an `audio.driver` that works for your hardware.
#'
#' On some platforms [midi_convert] supports writing other formats than wav, but
#' this does not always work well. Instead it is recommended to use [av::av_audio_convert]
#' to convert the wav file into any of the popular audio formats.
#'
#' You need a soundfont to play midi.
#' A free soundfont called [GeneralUser-GS](https://www.schristiancollins.com/generaluser.php) is
#' included with this package.
#'
#' @useDynLib miditools C_midi_play
#' @export
#' @rdname miditools
#' @param midi path to the midi file
#' @param soundfont path to the soundfont
#' @param settings a named vector with additional settings from [fluidsynth_setting_list()]
#' @param audio.driver which audio driver to use,
#' see [fluidsynth docs](https://www.fluidsynth.org/api/CreatingAudioDriver.html)
#' @examples
#' midi_convert(settings = list('synth.sample-rate'= 22050), output =  'lowquality.wav')
midi_play <- function(midi = demo_midi(), soundfont = general_user_gs(), audio.driver = NULL,
                      settings = list(), progress = TRUE){
  midi <- normalizePath(midi, mustWork = TRUE)
  soundfont <- normalizePath(soundfont, mustWork = TRUE)
  progress <- as.logical(progress)
  audio.driver <- as.character(audio.driver)
  settings <- validate_fluidsynth_settings(settings)
  .Call(C_midi_play, midi, soundfont, audio.driver, settings, progress)
  invisible()
}

#' @rdname miditools
#' @export
#' @param output filename of the output. It is recommended to use wav output.
#' @param progress print status progress to the terminal
midi_convert <- function(midi = demo_midi(), soundfont = general_user_gs(), output = 'output.wav',
                         settings = list(), progress = TRUE){
  midi <- normalizePath(midi, mustWork = TRUE)
  soundfont <- normalizePath(soundfont, mustWork = TRUE)
  output <- structure(normalizePath(output, mustWork = FALSE), class = 'outputfile')
  progress <- as.logical(progress)
  settings <- validate_fluidsynth_settings(settings)
  .Call(C_midi_play, midi, soundfont, output, settings, progress)
  c(output)
}

general_user_gs <- function(){
  system.file(package = 'miditools', 'generaluser-gs/v1.471.sf2', mustWork = TRUE)
}

demo_midi <- function(){
  list.files(system.file(package = 'miditools', 'generaluser-gs/midi'), full.names = TRUE)
}
