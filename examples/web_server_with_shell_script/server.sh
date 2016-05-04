#!/bin/sh
read get docid junk
cat `echo "$docid"` | \
  ruby -p -e '$_.gsub(/^\/ [\r\n]/,"").chomp'