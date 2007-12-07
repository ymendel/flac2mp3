$:.unshift File.dirname(__FILE__)
require 'flac2mp3/string_extensions'

module Flac2mp3
  class << self
    def convert(filename)
      raise TypeError unless FileTest.file?(filename)
      filename.extend(Flac2mp3::StringExtensions)
      output_filename(filename)
    end
    
    def output_filename(filename)
      filename.chomp('.flac') + '.mp3'
    end
  end
end
