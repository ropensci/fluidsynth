.onAttach <- function(libname, pkg){
  packageStartupMessage(paste("Using libfluidsynth", libfluidsynth_version()))
}
