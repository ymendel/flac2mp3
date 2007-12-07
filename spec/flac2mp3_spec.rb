require File.dirname(__FILE__) + '/spec_helper.rb'

describe Flac2mp3 do
  it 'should convert' do
    Flac2mp3.should respond_to(:convert)
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
  
  it 'should check if the filename belongs to a regular file' do
    lambda { Flac2mp3.convert(@filename) }.should_not raise_error(TypeError)
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
