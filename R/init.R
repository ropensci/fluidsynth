.onAttach <- function(libname, pkg){
  packageStartupMessage(paste("Using libfluidsynth", libfluidsynth_version()))
}

# On CRAN, pipewire emits warnings that it can't read the HOME dir
# https://github.com/PipeWire/pipewire/blob/master/README.md
.onLoad <- function(lib, pkg){
  if(is_check()){
    Sys.setenv(PIPEWIRE_DEBUG="0")
  }
}


is_check <- function(){
  grepl('fluidsynth.Rcheck', getwd(), fixed = TRUE)
}
