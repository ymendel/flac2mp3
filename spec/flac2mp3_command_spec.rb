require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'flac2mp3 command' do
  before :all do
    path = File.join(File.dirname(__FILE__), *%w[.. bin])
    ENV['PATH'] = [path, ENV['PATH']].join(':')
  end
  
  before :each do
    Flac2mp3.stubs(:convert)
  end
  
  it 'should exist' do
    pending 'figuring out how to test this command'
    
    system('flac2mp3 blah').should be_true
  end
  
  it 'should require a filename' do
    pending 'figuring out how to test this command'
      
    `flac2mp3`.should match(/usage:.+filename/i)
  end
  
  it 'should pass the filename to Flac2mp3 for conversion' do
    pending 'figuring out how to test this command'
    
    Flac2mp3.expects(:convert).with('blah')
    system('flac2mp3 blah')
  end
end
