require File.dirname(__FILE__) + '/spec_helper.rb'

describe Flac2mp3 do
  it 'should convert' do
    Flac2mp3.should respond_to(:convert)
  end
  
  it 'should provide output filename' do
    Flac2mp3.should respond_to(:output_filename)
  end
  
  it 'should provide tag mapping' do
    Flac2mp3.should respond_to(:tag_mapping)
  end
end

describe Flac2mp3, 'when converting' do
  it 'should require a filename' do
    lambda { Flac2mp3.convert }.should raise_error(ArgumentError)
  end
  
  it 'should accept a filename' do
    lambda { Flac2mp3.convert('blah.flac') }.should_not raise_error(ArgumentError)
  end
  
  it 'should check if the filename belongs to a regular file' do
    filename = 'blah.flac'
    FileTest.expects(:file?).with(filename).returns(true)
    Flac2mp3.convert(filename)
  end
end

describe Flac2mp3, 'when converting and given a filename belonging to a regular file' do
  before :each do
    @filename = 'blah.flac'
    FileTest.stubs(:file?).with(@filename).returns(true)
  end
  
  it 'should not error' do
    lambda { Flac2mp3.convert(@filename) }.should_not raise_error(TypeError)
  end
  
  it 'should extend the filename with the string extensions' do
    @filename.expects(:extend).with(Flac2mp3::StringExtensions)
    Flac2mp3.convert(@filename)
  end
  
  it 'should get the output filename' do
    Flac2mp3.expects(:output_filename).with(@filename)
    Flac2mp3.convert(@filename)
  end
  
  it 'should extend the output filename with the string extensions' do
    @output_filename = 'blah.mp3'
    Flac2mp3.stubs(:output_filename).with(@filename).returns(@output_filename)
    @output_filename.expects(:extend).with(Flac2mp3::StringExtensions)
    Flac2mp3.convert(@filename)
  end
end

describe Flac2mp3, 'when converting and given a filename not belonging to a regular file' do
  before :each do
    @filename = 'blah.flac'
    FileTest.stubs(:file?).with(@filename).returns(false)
  end
  
  it 'should error' do
    lambda { Flac2mp3.convert(@filename) }.should raise_error(TypeError)
  end
end

describe Flac2mp3, 'when getting an output filename' do
  it 'should require a filename' do
    lambda { Flac2mp3.output_filename }.should raise_error(ArgumentError)
  end
  
  it 'should accept a filename' do
    lambda { Flac2mp3.output_filename('blah.flac') }.should_not raise_error(ArgumentError)
  end
  
  it 'should convert a .flac extension to an .mp3 extension' do
    Flac2mp3.output_filename('blah.flac').should == 'blah.mp3'
  end
  
  it 'should append an .mp3 extension if no .flac extension exists' do
    Flac2mp3.output_filename('blah').should == 'blah.mp3'
  end
end

describe Flac2mp3, 'providing a mapping of tags' do
  it 'should return a hash' do
    Flac2mp3.tag_mapping.should be_kind_of(Hash)
  end
  
  it "should map 'album' to 'album'" do
    Flac2mp3.tag_mapping[:album].should == :album
  end
  
  it "should map 'artist' to 'artist'" do
    Flac2mp3.tag_mapping[:artist].should == :artist
  end
  
  it "should map 'bpm' to 'bpm'" do
    Flac2mp3.tag_mapping[:bpm].should == :bpm
  end
  
  it "should map 'comment' to 'comments'" do
    Flac2mp3.tag_mapping[:comment].should == :comments
  end
  
  it "should map 'composer' to 'composer'" do
    Flac2mp3.tag_mapping[:composer].should == :composer
  end
  
  it "should map 'date' to 'year'" do
    Flac2mp3.tag_mapping[:date].should == :year
  end
  
  it "should map 'genre' to 'genre_s'" do
    Flac2mp3.tag_mapping[:genre].should == :genre_s
  end
  
  it "should map 'title' to 'title'" do
    Flac2mp3.tag_mapping[:title].should == :title
  end
  
  it "should map 'tracknumber' to 'tracknum'" do
    Flac2mp3.tag_mapping[:tracknumber].should == :tracknum
  end
end
