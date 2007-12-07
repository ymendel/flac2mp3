$:.unshift File.dirname(__FILE__)
require 'flac2mp3/string_extensions'
require 'flacinfo'

module Flac2mp3
  class << self
    def convert(filename)
      raise TypeError unless FileTest.file?(filename)
      filename.extend(Flac2mp3::StringExtensions)
      out_file = output_filename(filename)
      out_file.extend(Flac2mp3::StringExtensions)
    end
    
    def output_filename(filename)
      filename.chomp('.flac') + '.mp3'
    end
    
    def tag_mapping
      {
        :album       => :album,
        :artist      => :artist,
        :bpm         => :bpm,
        :comment     => :comments,
        :composer    => :composer,
        :date        => :year,
        :genre       => :genre_s,
        :title       => :title,
        :tracknumber => :tracknum
      }
    end
    
    def flacdata(filename)
      data = FlacInfo.new(filename)
      data.tags.inject({}) do |hash, (key, value)|
        value = value.to_i if value.respond_to(:match) and value.match(/^\d+$/)
        hash[key.to_s.downcase.to_sym] = value
        hash
      end
    end
  end
end
