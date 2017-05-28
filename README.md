# flac2mp3

## Description

`flac2mp3` is meant to, as the name implies, convert FLAC files to MP3 files

## Features/Problems

  * Will convert a file from FLAC to MP3 format, natch.
  * Not *only* is the song data converted, but so is the metadata!
  * Options:
    * silent running
    * delete the FLAC after conversion
    * MP3 encoding (defaults to `--preset standard`)
  * Reads options from YAML config file, `~/.flac2mp3`

Currently operates on one file at a time. To convert more, try something like

    for f in *.flac; do flac2mp3 "$f"; done

or

    find . -name '*.flac' -exec flac2mp3 {} \;

If neither of those commands will work for you, try using a different OS.

## Synopsis

    $ flac2mp3 flac_filename
    $ flac2mp3 flac_filename --silent
    $ flac2mp3 --meta flac_filename mp3_filename

or with lame options

    $ flac2mp3 flac_filename -e "-b 320"

(or)

    $ metaflac2mp3 flac_filename mp3_filename

or, if you insist

``` ruby
require 'flac2mp3'

Flac2mp3.convert(flac_filename)
Flac2mp3.convert(flac_filename, :silent => true)
Flac2mp3.convert_metadata(flac_filename, mp3_filename)
```

## Requirements

  * `flac`, the binary
  * `lame`, the binary
  * `flacinfo-rb`, the gem
  * `ruby-mp3info`, the gem
  * ruby, the interpreter

## Install

    gem install flac2mp3

## Thanks

  * Rich Lafferty, for turning me on to the wonderful idea of keeping everything in FLAC format
  * Apple, for having a bunch of little-i, capital-letter products that don't like FLAC format
  * Robin Bowes, for `flac2mp3.pl`, which annoyed me enough to get me to write this
