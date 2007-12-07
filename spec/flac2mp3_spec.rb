require File.dirname(__FILE__) + '/spec_helper.rb'

describe Flac2mp3 do
  it 'should convert' do
    Flac2mp3.should respond_to(:convert)
  end
  
  it 'should provide output filename' do
    Flac2mp3.should respond_to(:output_filename)
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
