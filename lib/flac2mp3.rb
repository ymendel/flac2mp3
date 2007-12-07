$:.unshift File.dirname(__FILE__)
require 'flac2mp3/string_extensions'

module Flac2mp3
  class << self
    def convert(filename)
      raise TypeError unless FileTest.file?(filename)
    end
  end
end
