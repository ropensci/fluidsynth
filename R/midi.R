#' Play or convert a midi file
#'
#' Play a midi file to your audio device, render it to a file, or parse the raw data.
#' Additional settings can be specified, see [fluidsynth_setting_list] for available
#' options.
#'
#' The `midi_convert` function internally uses fluidsynth to generate a raw wav file,
#' and then [av::av_audio_convert()] to convert into the requested about format. See
#' [av::av_muxers()] for supported output formats and their corresponding file extension.
#'
#' You need a soundfont to synthesize midi, see the [soundfonts] page. On Linux you may
#' also need to specify an `audio.driver` that works for your hardware, although on
#' recent distributions the defaults generally work.
#'
#' @useDynLib fluidsynth C_midi_play
#' @export
#' @rdname fluidsynth
#' @family fluidsynth
#' @returns midi_read returns data frame with midi events.
#' @param midi path to the midi file
#' @param soundfont path to the soundfont
#' @param settings a named vector with additional settings from [fluidsynth_setting_list()]
#' @param audio.driver which audio driver to use,
#' see [fluidsynth docs](https://www.fluidsynth.org/api/CreatingAudioDriver.html)
#' @examples
#' df <- midi_read(demo_midi())
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

#' @export
#' @rdname fluidsynth
#' @useDynLib fluidsynth C_midi_read
midi_read <- function(midi = demo_midi(), verbose = FALSE){
  midi <- normalizePath(midi, mustWork = TRUE)
  verbose <- as.logical(verbose)
  out <- .Call(C_midi_read, midi, verbose)
  names(out) <- c("tick", "channel", "event", "param1", "param2")
  out$event <- factor(out$event, levels = c(midi_events), labels = names(midi_events))
  data.frame(out)
}

#' @export
#' @rdname fluidsynth
demo_midi <- function(){
  list.files(system.file(package = 'fluidsynth', 'midi'), pattern = '\\.mid$', full.names = TRUE)
}

# Values from: https://github.com/FluidSynth/fluidsynth/blob/master/src/midi/fluid_midi.h#L46C1-L71C27
midi_events <- c(
  NOTE_OFF = 0x80,
  NOTE_ON = 0x90,
  KEY_PRESSURE = 0xa0,
  CONTROL_CHANGE = 0xb0,
  PROGRAM_CHANGE = 0xc0,
  CHANNEL_PRESSURE = 0xd0,
  PITCH_BEND = 0xe0,
  MIDI_SYSEX = 0xf0,
  MIDI_TIME_CODE = 0xf1,
  MIDI_SONG_POSITION = 0xf2,
  MIDI_SONG_SELECT = 0xf3,
  MIDI_TUNE_REQUEST = 0xf6,
  MIDI_EOX = 0xf7,
  MIDI_SYNC = 0xf8,
  MIDI_TICK = 0xf9,
  MIDI_START = 0xfa,
  MIDI_CONTINUE = 0xfb,
  MIDI_STOP = 0xfc,
  MIDI_ACTIVE_SENSING = 0xfe,
  MIDI_SYSTEM_RESET = 0xff,
  MIDI_META_EVENT = 0xff
)
