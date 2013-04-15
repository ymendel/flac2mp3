require File.dirname(__FILE__) + '/spec_helper.rb'

def run_command(*args)
  Object.const_set(:ARGV, args)
  begin
    eval File.read(File.join(File.dirname(__FILE__), *%w[.. bin flac2mp3]))
  rescue SystemExit
  end
end

describe 'flac2mp3 command' do
  before do
    Flac2mp3.stub!(:convert)
    Flac2mp3.stub!(:convert_metadata)

    [:ARGV, :OPTIONS, :MANDATORY_OPTIONS].each do |const|
      Object.send(:remove_const, const) if Object.const_defined?(const)
    end
  end

  it 'should exist' do
    lambda { run_command('blah') }.should.not.raise(Errno::ENOENT)
  end

  it 'should require a filename' do
    self.should.receive(:puts) do |output|
      output.should.match(/usage.+filename/i)
    end
    run_command
  end

  it 'should pass the filename to Flac2mp3 for conversion' do
    Flac2mp3.should.receive(:convert) do |filename, _|
      filename.should == 'blah'
    end
    run_command('blah')
  end

  it 'should pass on a true flac-deletion option if specified on the command line (using --delete)' do
    Flac2mp3.should.receive(:convert) do |_, options|
      options[:delete].should == true
    end
    run_command('blah', '--delete')
  end

  it 'should pass on a false flac-deletion option if specified on the command line (using --no-delete)' do
    Flac2mp3.should.receive(:convert) do |_, options|
      options[:delete].should == false
    end
    run_command('blah', '--no-delete')
  end

  it 'should pass on a true flac-deletion option if specified on the command line (using -d)' do
    Flac2mp3.should.receive(:convert) do |_, options|
      options[:delete].should == true
    end
    run_command('blah', '-d')
  end

  it 'should not pass on any flac-deletion option if nothing specified on the command line' do
    Flac2mp3.should.receive(:convert) do |_, options|
      options.should.not.include(:delete)
    end
    run_command('blah')
  end

  it 'should pass on a true silence option if specified on the command line (using --silent)' do
    Flac2mp3.should.receive(:convert) do |_, options|
      options[:silent].should == true
    end
    run_command('blah', '--silent')
  end

  it 'should pass on a true silence option if specified on the command line (using -s)' do
    Flac2mp3.should.receive(:convert) do |_, options|
      options[:silent].should == true
    end
    run_command('blah', '-s')
  end

  it 'should not pass on any silence option if nothing specified on the command line' do
    Flac2mp3.should.receive(:convert) do |_, options|
      options.should.not.include(:silent)
    end
    run_command('blah')
  end

  it 'should pass on the encoding option specified on the command line' do
    Flac2mp3.should.receive(:convert) do |_, options|
      options[:encoding].should == '--preset fast standard'
    end
    run_command('blah', '--encoding', '--preset fast standard')
  end

  it 'should pass on the encoding option specified in shorthand on the command line' do
    Flac2mp3.should.receive(:convert) do |_, options|
      options[:encoding].should == '--preset fast standard'
    end
    run_command('blah', '-e', '--preset fast standard')
  end

  it 'should pass on no encoding option if none specified on the command line' do
    Flac2mp3.should.receive(:convert) do |_, options|
      options.should.not.include(:encoding)
    end
    run_command('blah')
  end

  it 'should take a --meta option to convert metadata' do
    lambda { run_command('--meta', 'blah.flac', 'something.mp3') }.should.not.raise(OptionParser::InvalidOption)
  end

  describe 'when converting metadata' do
    before do
      @infile = 'blah.flac'
      @outfile = 'something.mp3'
    end

    it 'should require two filenames' do
      self.should.receive(:puts) do |output|
        output.should.match(/usage.+filename/i)
      end
      run_command('--meta', @infile)
    end

    it 'should pass the filenames to Flac2mp3 for metadata conversion' do
      Flac2mp3.should.receive(:convert_metadata).with(@infile, @outfile)
      run_command('--meta', @infile, @outfile)
    end

    it 'should not attempt to convert any files' do
      Flac2mp3.should.receive(:convert).never
      run_command('--meta', @infile, @outfile)
    end

    it 'should accept a shorthand -m option' do
      Flac2mp3.should.receive(:convert_metadata).with(@infile, @outfile)
      run_command('-m', @infile, @outfile)
    end
  end
end
