flac2mp3 is meant to, as the name implies, convert FLAC files to MP3 files.

It presently requires the `flac` and `lame` binaries to execute, as those are used for the actual conversion.
It moves tags using the flacinfo-rb and ruby-mp3info gems.

flac2mp3 operates on one file at a time. To convert more, try something like

  for f in *.flac; do flac2mp3 "$f"; done

or

  find . -name '*.flac' -exec flac2mp3 {} \;
