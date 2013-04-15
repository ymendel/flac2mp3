require File.dirname(__FILE__) + '/spec_helper.rb'

describe Flac2mp3 do
  before do
    @flac2mp3 = Flac2mp3.new
  end

  describe 'when initialized' do
    before do
      @options = { :silent => true, :delete => false }
    end

    it 'should accept options' do
      lambda { Flac2mp3.new(@options) }.should.not.raise(ArgumentError)
    end

    it 'should not require options' do
      lambda { Flac2mp3.new }.should.not.raise(ArgumentError)
    end

    describe do
      # unnamed describe block just to give a level of organization
      # to this subclass-based initialize-behavior testing
      before do
        @subclass = Class.new(Flac2mp3) do
          attr_reader :config_loaded, :options_set, :options

          def load_config
            @config_loaded = true
          end

          def set_options(*args)
            @options_set = true
            @options = args
          end
        end
      end

      it 'should load the configuration' do
        obj = @subclass.new
        obj.config_loaded.should == true
      end

      it 'should set the options' do
        obj = @subclass.new(@options)
        obj.options_set.should == true
        obj.options.should == [@options]
      end

      it 'should default to empty options' do
        obj = @subclass.new
        obj.options_set.should == true
        obj.options.should == [{}]
      end
    end
  end

  it 'should load the configuration' do
    @flac2mp3.should.respond_to(:load_config)
  end

  describe 'loading the configuration' do
    it 'should look for a config file' do
      File.should.receive(:read).with(File.expand_path('~/.flac2mp3')).and_return('')
      @flac2mp3.load_config
    end

    describe 'when a config file is found' do
      before do
        @config = { :silent => true, :delete => false }
        @contents = @config.to_yaml
        File.stub!(:read).and_return(@contents)
      end

      it 'should parse the file as YAML' do
        YAML.should.receive(:load).with(@contents)
        @flac2mp3.load_config
      end

      it 'should store the config' do
        @flac2mp3.load_config
        @flac2mp3.config.should == @config
      end

      it 'should convert string keys to symbols' do
        File.stub!(:read).and_return({ 'silent' => true, 'delete' => false }.to_yaml)
        @flac2mp3.load_config
        @flac2mp3.config.should == @config
      end

      it 'should handle an empty file' do
        File.stub!(:read).and_return('')
        @flac2mp3.load_config
        @flac2mp3.config.should == {}
      end

      it 'should not allow changes to the config' do
        @flac2mp3.load_config
        @flac2mp3.config[:some_key] = 'some value'
        @flac2mp3.config.should == @config
      end
    end

    describe 'when no config file is found' do
      before do
        File.stub!(:read).and_raise(Errno::ENOENT)
      end

      it 'should store an empty config' do
        Flac2mp3.new.config.should == {}
      end
    end
  end

  it 'should set options' do
    @flac2mp3.should.respond_to(:set_options)
  end

  describe 'setting options' do
    before do
      @options = { :silent => true, :delete => false }
    end

    it 'should accept options' do
      lambda { @flac2mp3.set_options(:silent => true) }.should.not.raise(ArgumentError)
    end

    it 'should require options' do
      lambda { @flac2mp3.set_options }.should.raise(ArgumentError)
    end

    it 'should accept a hash of options' do
      lambda { @flac2mp3.set_options(:silent => true) }.should.not.raise(TypeError)
    end

    it 'should require a hash of options' do
      lambda { @flac2mp3.set_options('silent') }.should.raise(TypeError)
    end

    it 'should store the options' do
      @flac2mp3.set_options(@options)
      @flac2mp3.options.should == @options
    end

    it 'should not allow changes to the options' do
      @flac2mp3.set_options(@options.dup)
      @flac2mp3.options[:some_key] = 'some value'
      @flac2mp3.options.should == @options
    end
  end

  describe 'querying options' do
    before do
      File.stub!(:read).and_return('')
      @flac2mp3.load_config
    end

    it 'should indicate the original file should be deleted when a true option is given' do
      @flac2mp3.set_options(:delete => true)
      @flac2mp3.delete?.should == true
    end

    it 'should indicate the original file should not be deleted when a false option is given' do
      @flac2mp3.set_options(:delete => false)
      @flac2mp3.delete?.should == false
    end

    it 'should indicate the original file should not be deleted when no option is given' do
      @flac2mp3.set_options({})
      @flac2mp3.delete?.should == false
    end

    it 'should indicate the conversion should be silent when a true option is given' do
      @flac2mp3.set_options(:silent => true)
      @flac2mp3.silent?.should == true
    end

    it 'should indicate the conversion should not be silent when a false option is given' do
      @flac2mp3.set_options(:silent => false)
      @flac2mp3.silent?.should == false
    end

    it 'should indicate the conversion should not be silent when no option is given' do
      @flac2mp3.set_options({})
      @flac2mp3.silent?.should == false
    end

    it 'should store the given encoding' do
      encoding = '-VAWESOME'
      @flac2mp3.set_options(:encoding => encoding)
      @flac2mp3.encoding.should == encoding
    end

    it 'should default the encoding to --preset standard' do
      @flac2mp3.set_options({})
      @flac2mp3.encoding.should == '--preset standard'
    end

    it 'should use values from the configuration' do
      config = {:silent => true}
      File.stub!(:read).and_return(config.to_yaml)
      Flac2mp3.new.silent?.should == true
    end

    it 'should override configuration values with options' do
      config = {:silent => true}
      File.stub!(:read).and_return(config.to_yaml)
      Flac2mp3.new(:silent => false).silent?.should == false
    end

    it 'should combine configuration and option values' do
      config = {:silent => true}
      File.stub!(:read).and_return(config.to_yaml)
      flac2mp3 = Flac2mp3.new(:delete => true)

      flac2mp3.silent?.should == true
      flac2mp3.delete?.should == true
    end
  end

  it 'should convert' do
    @flac2mp3.should.respond_to(:convert)
  end

  describe 'when converting' do
    before do
      @filename = 'test.flac'
      @flac2mp3.stub!(:process_conversion)
      FileTest.stub!(:file?).and_return(true)
    end

    it 'should accept a filename' do
      lambda { @flac2mp3.convert(@filename) }.should.not.raise(ArgumentError)
    end

    it 'should require a filename' do
      lambda { @flac2mp3.convert }.should.raise(ArgumentError)
    end

    it 'should check if the filename belongs to a regular file' do
      FileTest.should.receive(:file?).with(@filename).and_return(true)
      @flac2mp3.convert(@filename)
    end

    describe 'when given a filename belonging to a regular file' do
      before do
        FileTest.stub!(:file?).and_return(true)
      end

      it 'should not error' do
        lambda { @flac2mp3.convert(@filename) }.should.not.raise(TypeError)
      end

      it 'should process the conversion' do
        @flac2mp3.should.receive(:process_conversion).with(@filename)
        @flac2mp3.convert(@filename)
      end

      it 'should check if the original file should be deleted' do
        @flac2mp3.should.receive(:delete?)
        @flac2mp3.convert(@filename)
      end

      describe 'when the original file should be deleted' do
        before do
          @flac2mp3.stub!(:delete?).and_return(true)
        end

        it 'should delete the original file' do
          File.should.receive(:delete).with(@filename)
          @flac2mp3.convert(@filename)
        end
      end

      describe 'when the original file should not be deleted' do
        before do
          @flac2mp3.stub!(:delete?).and_return(false)
        end

        it 'should not delete the original file' do
          File.should.receive(:delete).never
          @flac2mp3.convert(@filename)
        end
      end
    end

    describe 'when given a filename not belonging to a regular file' do
      before do
        FileTest.stub!(:file?).and_return(false)
      end

      it 'should error' do
        lambda { @flac2mp3.convert(@filename) }.should.raise(TypeError)
      end
    end
  end

  it 'should process conversion' do
    @flac2mp3.should.respond_to(:process_conversion)
  end

  describe 'when processing conversion' do
    before do
      @filename     = 'test.flac'
      @out_filename = 'test.mp3'
      @flac2mp3.stub!(:output_filename).and_return(@out_filename)
      @flac2mp3.stub!(:convert_data)
      @flac2mp3.stub!(:convert_metadata)
    end

    it 'should accept a filename' do
      lambda { @flac2mp3.process_conversion(@filename) }.should.not.raise(ArgumentError)
    end

    it 'should require a filename' do
      lambda { @flac2mp3.process_conversion }.should.raise(ArgumentError)
    end

    it 'get the output filename from the given filename' do
      @flac2mp3.should.receive(:output_filename).with(@filename)
      @flac2mp3.process_conversion(@filename)
    end

    it 'should convert data' do
      @flac2mp3.should.receive(:convert_data).with(@filename, @out_filename)
      @flac2mp3.process_conversion(@filename)
    end

    it 'should convert metadata' do
      @flac2mp3.should.receive(:convert_metadata).with(@filename, @out_filename)
      @flac2mp3.process_conversion(@filename)
    end
  end

  it 'should provide an output filename' do
    @flac2mp3.should.respond_to(:output_filename)
  end

  describe 'providing an output filename' do
    it 'should accept a filename' do
      lambda { @flac2mp3.output_filename('blah.flac') }.should.not.raise(ArgumentError)
    end

    it 'should require a filename' do
      lambda { @flac2mp3.output_filename }.should.raise(ArgumentError)
    end

    it 'should convert a .flac extension to an .mp3 extension' do
      @flac2mp3.output_filename('blah.flac').should == 'blah.mp3'
    end

    it 'should append an .mp3 extension if no .flac extension exists' do
      @flac2mp3.output_filename('blah').should == 'blah.mp3'
    end
  end

  it 'should convert data' do
    @flac2mp3.should.respond_to(:convert_data)
  end

  describe 'when converting data' do
    before do
      @filename     = 'test.flac'
      @out_filename = 'test.mp3'
      @flac_command = 'flac command'
      @mp3_command  = 'mp3 command'
      @flac2mp3.stub!(:flac_command).and_return(@flac_command)
      @flac2mp3.stub!(:mp3_command).and_return(@mp3_command)
      @flac2mp3.stub!(:system)
    end

    it 'should accept a filename and an output filename' do
      lambda { @flac2mp3.convert_data(@filename, @out_filename) }.should.not.raise(ArgumentError)
    end

    it 'should require an output filename' do
      lambda { @flac2mp3.convert_data(@filename) }.should.raise(ArgumentError)
    end

    it 'should require a filename' do
      lambda { @flac2mp3.convert_data }.should.raise(ArgumentError)
    end

    it 'should call the flac command with the given filename' do
      @flac2mp3.should.receive(:flac_command).with(@filename)
      @flac2mp3.convert_data(@filename, @out_filename)
    end

    it 'should call the mp3 command with the given output filename' do
      @flac2mp3.should.receive(:mp3_command).with(@out_filename)
      @flac2mp3.convert_data(@filename, @out_filename)
    end

    it 'should shell out to the system with the flac and mp3 commands' do
      @flac2mp3.should.receive(:system).with("#{@flac_command} | #{@mp3_command}")
      @flac2mp3.convert_data(@filename, @out_filename)
    end
  end

  it 'should provide a flac command' do
    @flac2mp3.should.respond_to(:flac_command)
  end

  describe 'when providing a flac command' do
    before do
      @filename = 'test.flac'
      @safe_filename = 'safetest.safeflac'
      @flac2mp3.stub!(:safequote).and_return(@safe_filename)
      @flac2mp3.stub!(:silent?)
    end

    it 'should accept a filename' do
      lambda { @flac2mp3.flac_command(@filename) }.should.not.raise(ArgumentError)
    end

    it 'should require a filename' do
      lambda { @flac2mp3.flac_command }.should.raise(ArgumentError)
    end

    it 'should safequote the filename' do
      @flac2mp3.should.receive(:safequote).with(@filename)
      @flac2mp3.flac_command(@filename)
    end

    it 'should check if the command should be silent' do
      @flac2mp3.should.receive(:silent?)
      @flac2mp3.flac_command(@filename)
    end

    describe 'when the command should be silent' do
      before do
        @flac2mp3.stub!(:silent?).and_return(true)
      end

      it 'should provide a flac shell command that will be silent' do
        @flac2mp3.flac_command(@filename).should == "flac --silent --stdout --decode #{@safe_filename}"
      end
    end

    describe 'when the command should not be silent' do
      before do
        @flac2mp3.stub!(:silent?).and_return(false)
      end

      it 'should provide a flac shell command that will not be silent' do
        @flac2mp3.flac_command(@filename).should == "flac --stdout --decode #{@safe_filename}"
      end
    end
  end

  it 'should provide an mp3 command' do
    @flac2mp3.should.respond_to(:mp3_command)
  end

  describe 'when providing an mp3 command' do
    before do
      @filename = 'test.mp3'
      @safe_filename = 'safetest.safemp3'
      @flac2mp3.stub!(:safequote).and_return(@safe_filename)
      @flac2mp3.stub!(:silent?)
      @encoding = '--VAWESOME'
      @flac2mp3.stub!(:encoding).and_return(@encoding)
    end

    it 'should accept a filename' do
      lambda { @flac2mp3.mp3_command(@filename) }.should.not.raise(ArgumentError)
    end

    it 'should require a filename' do
      lambda { @flac2mp3.mp3_command }.should.raise(ArgumentError)
    end

    it 'should safequote the filename' do
      @flac2mp3.should.receive(:safequote).with(@filename)
      @flac2mp3.mp3_command(@filename)
    end

    it 'should check if the command should be silent' do
      @flac2mp3.should.receive(:silent?)
      @flac2mp3.mp3_command(@filename)
    end

    it 'should check the encoding to use' do
      @flac2mp3.should.receive(:encoding)
      @flac2mp3.mp3_command(@filename)
    end

    describe 'when the command should be silent' do
      before do
        @flac2mp3.stub!(:silent?).and_return(true)
      end

      it 'should provide an mp3 shell command that will be silent' do
        @flac2mp3.mp3_command(@filename).should == "lame --silent #{@encoding} - #{@safe_filename}"
      end
    end

    describe 'when the command should not be silent' do
      before do
        @flac2mp3.stub!(:silent?).and_return(false)
      end

      it 'should provide an mp3 shell command that will not be silent' do
        @flac2mp3.mp3_command(@filename).should == "lame #{@encoding} - #{@safe_filename}"
      end
    end
  end

  it 'should quote filenames safely' do
    @flac2mp3.should.respond_to(:safequote)
  end

  describe 'when quoting a filename safely' do
    it 'should accept a filename' do
      lambda { @flac2mp3.safequote('test.flac') }.should.not.raise(ArgumentError)
    end

    it 'should require a filename' do
      lambda { @flac2mp3.safequote }.should.raise(ArgumentError)
    end

    it 'should leave alphanumeric characters alone' do
      @flac2mp3.safequote('abc_123').should == 'abc_123'
    end

    it 'should escape non-alphanumeric characters' do
      @flac2mp3.safequote(%q[a-b"c 12'3]).should == %q[a\-b\"c\ 12\'3]
    end
  end

  it 'should convert metadata' do
    @flac2mp3.should.respond_to(:convert_metadata)
  end

  describe 'when converting metadata' do
    before do
      @filename     = 'test.flac'
      @out_filename = 'test.mp3'
      @flacdata = mock('flac data')
      @flac2mp3.stub!(:get_flacdata).and_return(@flacdata)
      @flac2mp3.stub!(:set_mp3data)
    end

    it 'should accept a filename and an output filename' do
      lambda { @flac2mp3.convert_metadata(@filename, @out_filename) }.should.not.raise(ArgumentError)
    end

    it 'should require an output filename' do
      lambda { @flac2mp3.convert_metadata(@filename) }.should.raise(ArgumentError)
    end

    it 'should require a filename' do
      lambda { @flac2mp3.convert_metadata }.should.raise(ArgumentError)
    end

    it 'should get the flac metadata' do
      @flac2mp3.should.receive(:get_flacdata).with(@filename)
      @flac2mp3.convert_metadata(@filename, @out_filename)
    end

    it 'should set the mp3 metadata with the flac metadata' do
      @flac2mp3.should.receive(:set_mp3data).with(@out_filename, @flacdata)
      @flac2mp3.convert_metadata(@filename, @out_filename)
    end
  end

  it 'should get flac metadata' do
    @flac2mp3.should.respond_to(:get_flacdata)
  end

  describe 'when getting flac metadata' do
    before do
      @filename = 'test.flac'
      @tags = {}
      @flacinfo = mock('flac info', :tags => @tags)
      FlacInfo.stub!(:new).and_return(@flacinfo)
    end

    it 'should accept a filename' do
      lambda { @flac2mp3.get_flacdata(@filename) }.should.not.raise(ArgumentError)
    end

    it 'should require a filename' do
      lambda { @flac2mp3.get_flacdata }.should.raise(ArgumentError)
    end

    it 'should create a FlacInfo object' do
      FlacInfo.should.receive(:new).with(@filename).and_return(@flacinfo)
      @flac2mp3.get_flacdata(@filename)
    end

    it 'should use the FlacInfo object tags' do
      @flacinfo.should.receive(:tags).and_return(@tags)
      @flac2mp3.get_flacdata(@filename)
    end

    it 'should return a hash of the tag data' do
      @tags[:artist] = 'blah'
      @tags[:blah] = 'boo'
      @tags[:comment] = 'hey'

      data = @flac2mp3.get_flacdata(@filename)
      data[:artist].should == 'blah'
      data[:blah].should == 'boo'
      data[:comment].should == 'hey'
    end

    it 'should convert tags to symbols' do
      @tags['artist'] = 'blah'
      @tags['blah'] = 'boo'
      @tags['comment'] = 'hey'

      data = @flac2mp3.get_flacdata(@filename)
      data[:artist].should == 'blah'
      data[:blah].should == 'boo'
      data[:comment].should == 'hey'

      data.should.not.include('artist')
      data.should.not.include('blah')
      data.should.not.include('comment')
    end

    it 'should convert tags to lowercase' do
      @tags['Artist'] = 'blah'
      @tags[:BLAH] = 'boo'
      @tags['cOmMeNt'] = 'hey'

      data = @flac2mp3.get_flacdata(@filename)
      data[:artist].should == 'blah'
      data[:blah].should == 'boo'
      data[:comment].should == 'hey'

      data.should.not.include('Artist')
      data.should.not.include(:BLAH)
      data.should.not.include('cOmMeNt')
    end

    it 'should convert values consisting only of digits to actual numbers' do
      @tags[:track] = '12'

      data = @flac2mp3.get_flacdata(@filename)
      data[:track].should == 12
    end

    it 'should leave numeric values as numbers' do
      @tags[:track] = 12

      data = @flac2mp3.get_flacdata(@filename)
      data[:track].should == 12
    end

    it 'should leave numeric titles as strings' do
      @tags[:title] = '45'  # This was my first run-in with this problem, the opening track on Elvis Costello's /When I Was Cruel/

      data = @flac2mp3.get_flacdata(@filename)
      data[:title].should == '45'
    end

    it 'should leave numeric titles as strings even if the title key is not a simple downcased symbol' do
      @tags['TITLE'] = '45'

      data = @flac2mp3.get_flacdata(@filename)
      data[:title].should == '45'
    end

    it 'should leave numeric descriptions as strings' do
      @tags[:description] = '1938'  # This was my first run-in with this problem, from the Boilermakers' version of "Minor Swing" where for the description all I had was the year of the original

      data = @flac2mp3.get_flacdata(@filename)
      data[:description].should == '1938'
    end

    it 'should leave numeric descriptions as strings even if the description key is not a simple downcased symbol' do
      @tags['DESCRIPTION'] = '1938'

      data = @flac2mp3.get_flacdata(@filename)
      data[:description].should == '1938'
    end

    # iTunes wants ISO-8859-1, and I want my MP3s to display well in iTunes
    it 'should convert UTF-8 titles to ISO-8859-1' do
      @tags[:title] = "L\303\251gende"

      data = @flac2mp3.get_flacdata(@filename)
      data[:title].should == "L\351gende"
    end

    it 'should convert UTF-8 titles to ISO-8859-1 even if the title key is not a simple downcased symbol' do
      @tags['TITLE'] = "L\303\251gende"

      data = @flac2mp3.get_flacdata(@filename)
      data[:title].should == "L\351gende"
    end

    it 'should convert UTF-8 artist names to ISO-8859-1' do
      @tags[:artist] = "St\303\251phane Grappelli"

      data = @flac2mp3.get_flacdata(@filename)
      data[:artist].should == "St\351phane Grappelli"
    end

    it 'should convert UTF-8 artist names to ISO-8859-1 even if the artist key is not a simple downcased symbol' do
      @tags['ARTIST'] = "St\303\251phane Grappelli"

      data = @flac2mp3.get_flacdata(@filename)
      data[:artist].should == "St\351phane Grappelli"
    end

    it 'should convert UTF-8 album titles to ISO-8859-1' do
      @tags[:album] = "Still on Top \342\200\224 The Greatest Hits"

      data = @flac2mp3.get_flacdata(@filename)
      data[:album].should == "Still on Top - The Greatest Hits"  # not a strict conversion, but a transliteration
    end

    it 'should convert UTF-8 album titles to ISO-8859-1 even if the album key is not a simple downcased symbol' do
      @tags['ALBUM'] = "Still on Top \342\200\224 The Greatest Hits"

      data = @flac2mp3.get_flacdata(@filename)
      data[:album].should == "Still on Top - The Greatest Hits"  # not a strict conversion, but a transliteration
    end
  end

  it 'should set mp3 metadata' do
    @flac2mp3.should.respond_to(:set_mp3data)
  end

  describe 'when setting mp3 metadata' do
    before do
      @filename = 'test.mp3'
      @tags = {}
      @mp3tags  = mock('mp3 tags')
      @mp3tags2 = mock('mp3 tags 2')
      @mp3info  = mock('mp3 info', :tag => @mp3tags, :tag2 => @mp3tags2)
      Mp3Info.stub!(:open).and_yield(@mp3info)
    end

    it 'should accept a filename and tag data' do
      lambda { @flac2mp3.set_mp3data(@filename, {}) }.should.not.raise(ArgumentError)
    end

    it 'should require tag data' do
      lambda { @flac2mp3.set_mp3data(@filename) }.should.raise(ArgumentError)
    end

    it 'should require a filename' do
      lambda { @flac2mp3.set_mp3data }.should.raise(ArgumentError)
    end

    it 'should accept a hash of tag data' do
      lambda { @flac2mp3.set_mp3data(@filename, 'tag data') }.should.raise(TypeError)
    end

    it 'should require a hash of tag data' do
      lambda { @flac2mp3.set_mp3data(@filename, {}) }.should.not.raise(TypeError)
    end

    it 'should use an Mp3Info object' do
      Mp3Info.should.receive(:open).with(@filename)
      @flac2mp3.set_mp3data(@filename, @tags)
    end

    it 'should set tags in the Mp3Info object' do
      @tags[:album] = 'blah'
      @tags[:artist] = 'boo'
      @tags[:genre] = 'bang'

      @mp3tags.should.receive(:album=).with(@tags[:album])
      @mp3tags.should.receive(:artist=).with(@tags[:artist])
      @mp3tags.should.receive(:genre_s=).with(@tags[:genre])

      @flac2mp3.set_mp3data(@filename, @tags)
    end

    it 'should not set tags not given' do
      @tags[:album] = 'blah'
      @tags[:artist] = 'boo'
      @tags[:genre] = 'bang'

      @mp3tags.stub!(:album=)
      @mp3tags.stub!(:artist=)
      @mp3tags.stub!(:genre_s=)

      @mp3tags.should.receive(:comments=).never
      @mp3tags.should.receive(:year=).never

      @flac2mp3.set_mp3data(@filename, @tags)
    end

    it 'should not set tags not known' do
      @tags[:blah] = 'blah'
      @tags[:bang] = 'bang'

      @mp3tags.should.receive(:blah=).never
      @mp3tags.should.receive(:bang=).never

      @flac2mp3.set_mp3data(@filename, @tags)
    end

    it 'should use tag2 for bpm' do
      @tags[:bpm] = '5'

      @mp3tags2.should.receive(:TBPM=).with(@tags[:bpm])

      @flac2mp3.set_mp3data(@filename, @tags)
    end

    it 'should use tag2 for composer' do
      @tags[:composer] = 'Il Maestro'

      @mp3tags2.should.receive(:TCOM=).with(@tags[:composer])

      @flac2mp3.set_mp3data(@filename, @tags)
    end

    it 'should use tag2 for compilation' do
      @tags[:compilation] = '1'

      @mp3tags2.should.receive(:TCMP=).with(@tags[:compilation])

      @flac2mp3.set_mp3data(@filename, @tags)
    end

    it "should use tag2 for 'tag' ('grouping')" do
      @tags[:tag] = 'one, two, three, oclock'

      @mp3tags2.should.receive(:TIT1=).with(@tags[:tag])

      @flac2mp3.set_mp3data(@filename, @tags)
    end

    it 'should set tag2 track to be a combination of tracknumber and tracktotal' do
      @tags[:tracknumber] = 4
      @tags[:tracktotal]  = 15

      @mp3tags2.should.receive(:TRCK=).with('4/15')

      @flac2mp3.set_mp3data(@filename, @tags)
    end

    it "should set tag2 'pos' to be a combination of discnumber and disctotal" do
      @tags[:discnumber] = 1
      @tags[:disctotal]  = 2

      @mp3tags2.should.receive(:TPOS=).with('1/2')

      @flac2mp3.set_mp3data(@filename, @tags)
    end
  end

  describe 'as a class' do
    it 'should convert' do
      Flac2mp3.should.respond_to(:convert)
    end

    describe 'when converting' do
      before do
        @filename = 'test.flac'
        @options  = { :silent => true, :delete => false, :fish => :flat }
        @flac2mp3 = mock('flac2mp3', :convert => nil)
        Flac2mp3.stub!(:new).and_return(@flac2mp3)
      end

      it 'should accept a filename and a hash of options' do
        lambda { Flac2mp3.convert(@filename, @options) }.should.not.raise(ArgumentError)
      end

      it 'should not require options' do
        lambda { Flac2mp3.convert(@filename) }.should.not.raise(ArgumentError)
      end

      it 'should require a filename' do
        lambda { Flac2mp3.convert }.should.raise(ArgumentError)
      end

      it 'should instantiate a new Flac2mp3 object' do
        Flac2mp3.should.receive(:new).and_return(@flac2mp3)
        Flac2mp3.convert(@filename)
      end

      it 'should pass the options when instantiating the Flac2mp3 object' do
        Flac2mp3.should.receive(:new).with(@options).and_return(@flac2mp3)
        Flac2mp3.convert(@filename, @options)
      end

      it 'should use the Flac2mp3 object to convert the given file' do
        @flac2mp3.should.receive(:convert).with(@filename)
        Flac2mp3.convert(@filename)
      end
    end

    it 'should convert metadata' do
      Flac2mp3.should.respond_to(:convert_metadata)
    end

    describe 'when converting metadata' do
      before do
        @infile  = 'test.flac'
        @outfile = 'some.mp3'
        @flac2mp3 = mock('flac2mp3', :convert_metadata => nil)
        Flac2mp3.stub!(:new).and_return(@flac2mp3)
      end

      it 'should accept two filenames' do
        lambda { Flac2mp3.convert_metadata(@infile, @outfile) }.should.not.raise(ArgumentError)
      end

      it 'should require two filenames' do
        lambda { Flac2mp3.convert_metadata(@infile) }.should.raise(ArgumentError)
      end

      it 'should instantiate a new Flac2mp3 object' do
        Flac2mp3.should.receive(:new).and_return(@flac2mp3)
        Flac2mp3.convert_metadata(@infile, @outfile)
      end

      it 'should use the Flac2mp3 object to convert the metadata between the given files' do
        @flac2mp3.should.receive(:convert_metadata).with(@infile, @outfile)
        Flac2mp3.convert_metadata(@infile, @outfile)
      end
    end

    it 'should provide a tag mapping' do
      Flac2mp3.should.respond_to(:tag_mapping)
    end

    describe 'providing a tag mapping' do
      it 'should return a hash' do
        Flac2mp3.tag_mapping.should.be.kind_of(Hash)
      end

      it "should map 'album' to 'album'" do
        Flac2mp3.tag_mapping[:album].should == :album
      end

      it "should map 'artist' to 'artist'" do
        Flac2mp3.tag_mapping[:artist].should == :artist
      end

      it "should map 'bpm' to 'TBPM'" do
        Flac2mp3.tag_mapping[:bpm].should == :TBPM
      end

      it "should map 'description' to 'comments'" do
        Flac2mp3.tag_mapping[:description].should == :comments
      end

      it "should map 'composer' to 'TCOM'" do
        Flac2mp3.tag_mapping[:composer].should == :TCOM
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

      it "should map 'tracknumber' to 'TRCK'" do
        Flac2mp3.tag_mapping[:tracknumber].should == :TRCK
      end

      it "should map 'tracktotal' to 'TRCK'" do
        Flac2mp3.tag_mapping[:tracktotal].should == :TRCK
      end

      it "should map 'discnumber' to 'TPOS'" do
        Flac2mp3.tag_mapping[:discnumber].should == :TPOS
      end

      it "should map 'disctotal' to 'TPOS'" do
        Flac2mp3.tag_mapping[:disctotal].should == :TPOS
      end

      it "should map 'compilation' to 'TCMP'" do
        Flac2mp3.tag_mapping[:compilation].should == :TCMP
      end

      it "should map 'tag' to 'TIT1'" do
        Flac2mp3.tag_mapping[:tag].should == :TIT1
      end
    end
  end
end
