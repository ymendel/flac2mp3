require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'flac2mp3 command' do
  def run_command(*args)
    Object.const_set(:ARGV, args)
    begin
      eval File.read(File.join(File.dirname(__FILE__), *%w[.. bin flac2mp3]))
    rescue SystemExit
    end
  end
  
  before :all do
    path = File.join(File.dirname(__FILE__), *%w[.. bin])
    ENV['PATH'] = [path, ENV['PATH']].join(':')
  end
  
  before :each do
    Flac2mp3.stubs(:convert)
  end
  
  it 'should exist' do
    lambda { run_command('blah') }.should_not raise_error(Errno::ENOENT)
  end
  
  it 'should require a filename' do
    self.expects(:puts) { |text|  text.match(/usage.+filename/i) }
    run_command
  end
  
  it 'should pass the filename to Flac2mp3 for conversion' do
    Flac2mp3.expects(:convert).with('blah')
    run_command('blah')
  end
  
  it 'should duplicate the filename' do
    filename = 'blah'
    filename.expects(:dup).returns(filename)
    run_command(filename)
  end
end
