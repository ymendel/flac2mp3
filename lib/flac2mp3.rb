$:.unshift File.dirname(__FILE__)
require 'flac2mp3/string_extensions'
require 'flacinfo'
require 'mp3info'

module Flac2mp3
  class << self
    def convert(filename)
      raise TypeError, "'#{filename}' is not a file" unless FileTest.file?(filename)
      filename.extend(Flac2mp3::StringExtensions)
      out_filename = output_filename(filename)
      out_filename.extend(Flac2mp3::StringExtensions)
      
      system "flac -c -d #{filename.safequote} | lame --preset standard - #{out_filename.safequote}"
      
      mp3data(out_filename, flacdata(filename))
    end
    
    def output_filename(filename)
      filename.chomp('.flac') + '.mp3'
    end
    
    def tag_mapping
      {
        :album       => :album,
        :artist      => :artist,
        :bpm         => :TBPM,
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
        key = key.to_s.downcase.to_sym
        value = value.to_i if value.respond_to?(:match) and value.match(/^\d+$/)
        value = value.to_s if key == :title
        hash[key] = value
        hash
      end
    end
    
    def mp3data(filename, tags)
      raise TypeError, "Tags must be a hash" unless tags.is_a?(Hash)
      Mp3Info.open(filename) do |mp3|
        tags.each do |key, value|
          next unless mp3tag = tag_mapping[key]
          tag = mp3.tag
          tag = mp3.tag2 if key == :bpm
          tag.send("#{mp3tag}=", value)
        end
      end
    end
  end
end
