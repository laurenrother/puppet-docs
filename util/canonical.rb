#!/usr/bin/env ruby

# It's a tad brittle, but this was very helpful when trying to do canonical links for a whole directory of markdown files.
# This must take a directory as its only argument. No slash on the end. You'll have to do a find-and-replace at the end to clean it up a bit.

mydir = ARGV.shift
files = Dir.glob("#{mydir}/**/*")

files.each do |thisfile|
  next unless File.file?(thisfile)
  next unless /\.(md|markdown|html)/.match(thisfile)
  content = ''
  File.open(thisfile, 'r') {|handle|
    content = handle.read
  }
  segments = content.split(/^---/)
  next unless segments.length >= 3
  next if segments[1] =~ /^canonical:/
  segments[1] += "canonical: \"#{thisfile.sub(/\.(md|markdown)$/, '.html')}\"\n"
  File.open(thisfile, 'w') {|handle|
    handle.print segments.join('---')
  }


end