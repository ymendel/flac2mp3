$:.unshift File.dirname(__FILE__)
require 'flac2mp3/string_extensions'
require 'flacinfo'
require 'mp3info'

module Flac2mp3
  class << self
    def convert(filename, delete_flac = false)
      raise TypeError, "'#{filename}' is not a file" unless FileTest.file?(filename)
      filename.extend(Flac2mp3::StringExtensions)
      out_filename = output_filename(filename)
      out_filename.extend(Flac2mp3::StringExtensions)
      
      system "flac -c -d #{filename.safequote} | lame --preset standard - #{out_filename.safequote}"
      
      mp3data(out_filename, flacdata(filename))
      
      File.delete(filename) if delete_flac
    end
    
    def output_filename(filename)
      filename.chomp('.flac') + '.mp3'
    end
    
    def tag_mapping
      {
        :album       => :album,
        :artist      => :artist,
        :bpm         => :TBPM,
        :description => :comments,
        :composer    => :TCOM,
        :date        => :year,
        :genre       => :genre_s,
        :title       => :title,
        :tracknumber => :TRCK,
        :tracktotal  => :TRCK,
        :discnumber  => :TPOS,
        :disctotal   => :TPOS,
        :compilation => :TCMP
      }
    end
    
    def flacdata(filename)
      data = FlacInfo.new(filename)
      data.tags.inject({}) do |hash, (key, value)|
        key = key.to_s.downcase.to_sym
        value = value.to_i if value.respond_to?(:match) and value.match(/^\d+$/)
        value = value.to_s if string_fields.include?(key)
        hash[key] = value
        hash
      end
    end
    
    def mp3data(filename, tags)
      raise TypeError, "Tags must be a hash" unless tags.is_a?(Hash)
      Mp3Info.open(filename) do |mp3|
        convert_tags(tags).each do |mp3tag, data|
          tag = mp3.send(data[:target])
          tag.send("#{mp3tag}=", data[:value])
        end
      end
    end
    
    
    private
    
    def string_fields
      [:title, :description]
    end
    
    def tag2_fields
      [:bpm, :composer, :compilation, :tracktotal, :tracknumber, :disctotal, :discnumber]
    end
    
    def tag_formats
      {
        :TRCK => ':tracknumber/:tracktotal',
        :TPOS => ':discnumber/:disctotal'
      }
    end
    
    def convert_tags(tags)
      mp3_tags = {}
      
      tags.each do |key, value|
        next unless mp3tag = tag_mapping[key]
        
        if format = tag_formats[mp3tag]
          value = format.gsub(/:(\w+)/) do 
            field = $1
            tags[field.to_sym]
          end
        end
        
        target = tag2_fields.include?(key) ? :tag2 : :tag
        mp3_tags[mp3tag] = { :target => target, :value => value }
      end
      mp3_tags
    end
  end
end
