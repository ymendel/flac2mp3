$:.unshift File.dirname(__FILE__)
require 'flac2mp3/string_extensions'
require 'flacinfo'
require 'mp3info'

class Flac2mp3
  def initialize(options = {})
    @options = options
  end
  
  def convert(filename)
    raise TypeError, "'#{filename}' is not a file" unless FileTest.file?(filename)
    process_conversion(filename)
    File.delete(filename) if delete?
  end
  
  def process_conversion(filename)
    outfile = output_filename(filename)
    convert_data(filename, outfile)
    convert_metadata(filename, outfile)
  end
  
  def convert_data(filename, outfile)
    system "#{flac_command(filename)} | #{mp3_command(outfile)}"
  end
  
  def flac_command(filename)
    command = 'flac'
    command << ' --silent' if silent?
    
    "#{command} --stdout --decode #{safequote(filename)}"
  end
  
  def mp3_command(filename)
    command = 'lame'
    command << ' --silent' if silent?
    
    "#{command} #{encoding} - #{safequote(filename)}"
  end
  
  def convert_metadata(filename, outfile)
    set_mp3data(outfile, get_flacdata(filename))
  end
  
  def get_flacdata(filename)
    FlacInfo.new(filename).tags.inject({}) do |hash, (key, value)|
      key = key.to_s.downcase.to_sym
      value = value.to_i if value.respond_to?(:match) and value.match(/^\d+$/)
      value = value.to_s if self.class.string_fields.include?(key)
      
      hash[key] = value
      hash
    end
  end
  
  def set_mp3data(filename, tags)
    raise TypeError, "Tags must be a hash" unless tags.is_a?(Hash)
    Mp3Info.open(filename) do |mp3|
      self.class.convert_tags(tags).each do |mp3tag, data|
        tag = mp3.send(data[:target])
        tag.send("#{mp3tag}=", data[:value])
      end
    end
  end
  
  def options
    @options.dup
  end
  
  def delete?
    !!options[:delete]
  end
  
  def silent?
    !!options[:silent]
  end
  
  def encoding
    options[:encoding] || self.class.default_encoding
  end
  
  def output_filename(filename)
    filename.chomp('.flac') + '.mp3'
  end
  
  def safequote(filename)
    filename.gsub(/(\W)/, '\\\\\1')
  end
  
  class << self
    def convert(filename, options = {})
      new(options).convert(filename)
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
    
    def default_encoding
      '--preset standard'
    end
  end
end
