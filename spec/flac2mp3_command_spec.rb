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
    
    [:ARGV, :OPTIONS, :MANDATORY_OPTIONS].each do |const|
      Object.send(:remove_const, const) if Object.const_defined?(const)
    end
  end
  
  it 'should exist' do
    lambda { run_command('blah') }.should_not raise_error(Errno::ENOENT)
  end
  
  it 'should require a filename' do
    self.expects(:puts) { |text|  text.match(/usage.+filename/i) }
    run_command
  end
  
  it 'should pass the filename to Flac2mp3 for conversion' do
    Flac2mp3.expects(:convert).with('blah', anything)
    run_command('blah')
  end
  
  it 'should duplicate the filename' do
    filename = 'blah'
    filename.expects(:dup).returns(filename)
    run_command(filename)
  end
  
  it 'should pass on a true flac-deletion option if specified on the command line (using --delete)' do
    Flac2mp3.expects(:convert).with(anything, true)
    run_command('blah', '--delete')
  end
  
  it 'should pass on a false flac-deletion option if specified on the command line (using --no-delete)' do
    Flac2mp3.expects(:convert).with(anything, false)
    run_command('blah', '--no-delete')
  end
  
  it 'should pass on a true flac-deletion option if specified on the command line (using -d)' do
    Flac2mp3.expects(:convert).with(anything, true)
    run_command('blah', '-d')
  end
  
  it 'should pass on a false flac-deletion option if nothing specified on the command line' do
    Flac2mp3.expects(:convert).with(anything, false)
    run_command('blah')
  end
end
