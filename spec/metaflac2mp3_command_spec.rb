require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'metaflac2mp3 command' do
  def run_command(*args)
    Object.const_set(:ARGV, args)
    begin
      eval File.read(File.join(File.dirname(__FILE__), *%w[.. bin metaflac2mp3]))
    rescue SystemExit
    end
  end
  
  before :each do
    Flac2mp3.stubs(:convert_metadata)
    
    [:ARGV, :OPTIONS, :MANDATORY_OPTIONS].each do |const|
      Object.send(:remove_const, const) if Object.const_defined?(const)
    end
    
    @infile = 'blah.flac'
    @outfile = 'something.mp3'
  end
  
  it 'should exist' do
    lambda { run_command(@infile, @outfile) }.should_not raise_error(Errno::ENOENT)
  end
  
  it 'should require two filenames' do
    self.expects(:puts) { |text|  text.match(/usage.+filename/i) }
    run_command(@infile)
  end
  
  it 'should pass the filenames to Flac2mp3 for metadata conversion' do
    Flac2mp3.expects(:convert_metadata).with(@infile, @outfile)
    run_command(@infile, @outfile)
  end
  
  it 'should not attempt to convert any files' do
    Flac2mp3.expects(:convert).never
    run_command(@infile, @outfile)
  end
end
