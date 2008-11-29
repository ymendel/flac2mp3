require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'flac2mp3 command' do
  def run_command(*args)
    Object.const_set(:ARGV, args)
    begin
      eval File.read(File.join(File.dirname(__FILE__), *%w[.. bin flac2mp3]))
    rescue SystemExit
    end
  end
  
  before :each do
    @convert_state = states('convert').starts_as('setup')
    Flac2mp3.stubs(:convert).when(@convert_state.is('setup'))
    Flac2mp3.stubs(:convert_metadata)
    
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
  
  it 'should pass on a true flac-deletion option if specified on the command line (using --delete)' do
    Flac2mp3.expects(:convert).with(anything, has_entry(:delete => true))
    run_command('blah', '--delete')
  end
  
  it 'should pass on a false flac-deletion option if specified on the command line (using --no-delete)' do
    Flac2mp3.expects(:convert).with(anything, has_entry(:delete => false))
    run_command('blah', '--no-delete')
  end
  
  it 'should pass on a true flac-deletion option if specified on the command line (using -d)' do
    Flac2mp3.expects(:convert).with(anything, has_entry(:delete => true))
    run_command('blah', '-d')
  end
  
  it 'should not pass on any flac-deletion option if nothing specified on the command line' do
    Flac2mp3.expects(:convert).with(anything, Not(has_key(:delete)))
    run_command('blah')
  end
  
  it 'should pass on a true silence option if specified on the command line (using --silent)' do
    Flac2mp3.expects(:convert).with(anything, has_entry(:silent => true))
    run_command('blah', '--silent')
  end
  
  it 'should pass on a true silence option if specified on the command line (using -s)' do
    Flac2mp3.expects(:convert).with(anything, has_entry(:silent => true))
    run_command('blah', '-s')
  end
  
  it 'should not pass on any silence option if nothing specified on the command line' do
    Flac2mp3.expects(:convert).with(anything, Not(has_key(:silent)))
    run_command('blah')
  end
  
  it 'should pass on the encoding option specified on the command line' do
    Flac2mp3.expects(:convert).with(anything, has_entry(:encoding => '--preset fast standard'))
    run_command('blah', '--encoding', '--preset fast standard')
  end
  
  it 'should pass on the encoding option specified in shorthand on the command line' do
    Flac2mp3.expects(:convert).with(anything, has_entry(:encoding => '--preset fast standard'))
    run_command('blah', '-e', '--preset fast standard')
  end
  
  it 'should pass on no encoding option if none specified on the command line' do
    Flac2mp3.expects(:convert).with(anything, Not(has_key(:encoding)))
    run_command('blah')
  end
  
  it 'should take a --meta option to convert metadata' do
    lambda { run_command('--meta', 'blah.flac', 'something.mp3') }.should_not raise_error(OptionParser::InvalidOption)
  end
  
  describe 'when converting metadata' do
    before :each do
      @infile = 'blah.flac'
      @outfile = 'something.mp3'
    end
    
    it 'should require two filenames' do
      self.expects(:puts) { |text|  text.match(/usage.+filename/i) }
      run_command('--meta', @infile)
    end
    
    it 'should pass the filenames to Flac2mp3 for metadata conversion' do
      Flac2mp3.expects(:convert_metadata).with(@infile, @outfile)
      run_command('--meta', @infile, @outfile)
    end
    
    it 'should not attempt to convert any files' do
      @convert_state.become('test')
      Flac2mp3.expects(:convert).never.when(@convert_state.is('test'))
      run_command('--meta', @infile, @outfile)
    end
    
    it 'should accept a shorthand -m option' do
      Flac2mp3.expects(:convert_metadata).with(@infile, @outfile)
      run_command('-m', @infile, @outfile)
    end
  end
end
