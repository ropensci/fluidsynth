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
#' @useDynLib fluidsynth C_midi_play
#' @export
#' @rdname fluidsynth
#' @param midi path to the midi file
#' @param soundfont path to the soundfont
#' @param settings a named vector with additional settings from [fluidsynth_setting_list()]
#' @param audio.driver which audio driver to use,
#' see [fluidsynth docs](https://www.fluidsynth.org/api/CreatingAudioDriver.html)
#' @examples
#' midi_convert(settings = list('synth.sample-rate'= 22050), output =  'lowquality.wav')
midi_play <- function(midi = demo_midi(), soundfont = soundfont_path(), audio.driver = NULL,
                      settings = list(), verbose = interactive()){
  midi <- normalizePath(midi, mustWork = TRUE)
  soundfont <- normalizePath(soundfont, mustWork = TRUE)
  verbose <- as.logical(verbose)
  audio.driver <- as.character(audio.driver)
  settings <- validate_fluidsynth_settings(settings)
  .Call(C_midi_play, midi, soundfont, audio.driver, settings, verbose)
  invisible()
}

#' @rdname fluidsynth
#' @export
#' @param output filename of the output. The out
#' @param verbose print some progress status to the terminal
midi_convert <- function(midi = demo_midi(), soundfont = soundfont_path(), output = 'output.mp3',
                         settings = list(), verbose = interactive()){
  midi <- normalizePath(midi, mustWork = TRUE)
  soundfont <- normalizePath(soundfont, mustWork = TRUE)
  tmp <- structure(tempfile(fileext = '.wav'), class = 'outputfile')
  on.exit(unlink(tmp))
  verbose <- as.logical(verbose)
  settings <- validate_fluidsynth_settings(settings)
  .Call(C_midi_play, midi, soundfont, tmp, settings, verbose)
  av::av_audio_convert(tmp, output, verbose = verbose)
}

demo_midi <- function(){
  list.files(system.file(package = 'fluidsynth', 'generaluser-gs/midi'), full.names = TRUE)
}
