# miditools

Bindings to libfluidsynth to play and render midi files.

## Installation

You can install the development version of miditools with:

``` r
# install.packages("miditools", repos = 'https://ropensci.r-universe.dev')
```

On Debian/Ubuntu you need to install `libfluidsynth-dev` first:

```sh
sudo apt-get install libfluidsynth-dev
```

And on Fedora you need:

```sh
sudo dnf install fluidsynth-dev
```

On RHEL/CentOS/RockyLinux you first need to enable EPEL:


```sh
yum install -y epel-release
sudo yum install fluidsynth-dev
```
