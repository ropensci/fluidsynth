#' Play a midi file
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
midi_play <- function(midi = demo_midi(), soundfont = general_user_gs()){
  midi <- normalizePath(midi, mustWork = TRUE)
  soundfont <- normalizePath(soundfont, mustWork = TRUE)
  .Call(C_midi_play, midi, soundfont, NULL, FALSE)
}

#' @rdname miditools
#' @export
#' @param output filename of the output. It is recommended to use wav output.
#' @param progress print status progress to the terminal
midi_convert <- function(midi = demo_midi(), soundfont = general_user_gs(), output = 'output.wav',
                         progress = TRUE){
  midi <- normalizePath(midi, mustWork = TRUE)
  soundfont <- normalizePath(soundfont, mustWork = TRUE)
  output <- normalizePath(output, mustWork = FALSE)
  progress <- as.logical(progress)
  .Call(C_midi_play, midi, soundfont, output, progress)
}

general_user_gs <- function(){
  system.file(package = 'miditools', 'generaluser-gs/v1.471.sf2', mustWork = TRUE)
}

demo_midi <- function(){
  list.files(system.file(package = 'miditools', 'generaluser-gs/midi'), full.names = TRUE)
}
