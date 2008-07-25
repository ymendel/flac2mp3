require File.dirname(__FILE__) + '/spec_helper.rb'

describe Flac2mp3 do
  before :each do
    @flac2mp3 = Flac2mp3.new
  end
  
  describe 'when initialized' do
    before :each do
      @options = { :silent => true, :delete => false }
    end
    
    it 'should accept options' do
      lambda { Flac2mp3.new(@options) }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { Flac2mp3.new }.should_not raise_error(ArgumentError)
    end
    
    it 'should store the options' do
      Flac2mp3.new(@options).options.should == @options
    end
    
    it 'should not allow changes to the options' do
      flac2mp3 = Flac2mp3.new(@options.dup)
      flac2mp3.options[:some_key] = 'some value'
      flac2mp3.options.should == @options
    end
    
    it 'should indicate the original file should be deleted when a true option is given' do
      Flac2mp3.new(:delete => true).delete?.should be(true)
    end
    
    it 'should indicate the original file should not be deleted when a false option is given' do
      Flac2mp3.new(:delete => false).delete?.should be(false)
    end
    
    it 'should indicate the original file should not be deleted when no option is given' do
      Flac2mp3.new.delete?.should be(false)
    end
    
    it 'should indicate the conversion should be silent when a true option is given' do
      Flac2mp3.new(:silent => true).silent?.should be(true)
    end
    
    it 'should indicate the conversion should not be silent when a false option is given' do
      Flac2mp3.new(:silent => false).silent?.should be(false)
    end
    
    it 'should indicate the conversion should not be silent when no option is given' do
      Flac2mp3.new.silent?.should be(false)
    end
    
    it 'should store the given encoding' do
      encoding = '-VAWESOME'
      Flac2mp3.new(:encoding => encoding).encoding.should == encoding
    end
    
    it 'should default the encoding to --preset standard' do
      Flac2mp3.new.encoding.should == '--preset standard'
    end
  end
  
  it 'should convert' do
    @flac2mp3.should respond_to(:convert)
  end
  
  describe 'when converting' do
    before :each do
      @filename = 'test.flac'
      @flac2mp3.stubs(:process_conversion)
    end
    
    it 'should accept a filename' do
      lambda { @flac2mp3.convert(@filename) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a filename' do
      lambda { @flac2mp3.convert }.should raise_error(ArgumentError)
    end
    
    it 'should check if the filename belongs to a regular file' do
      FileTest.expects(:file?).with(@filename).returns(true)
      @flac2mp3.convert(@filename)
    end
    
    describe 'when given a filename belonging to a regular file' do
      before :each do
        FileTest.stubs(:file?).returns(true)
      end
      
      it 'should not error' do
        lambda { @flac2mp3.convert(@filename) }.should_not raise_error(TypeError)
      end
            
      it 'should process the conversion' do
        @flac2mp3.expects(:process_conversion).with(@filename)
        @flac2mp3.convert(@filename)
      end
      
      it 'should check if the original file should be deleted' do
        @flac2mp3.expects(:delete?)
        @flac2mp3.convert(@filename)
      end
      
      describe 'when the original file should be deleted' do
        before :each do
          @flac2mp3.stubs(:delete?).returns(true)
        end
        
        it 'should delete the original file' do
          File.expects(:delete).with(@filename)
          @flac2mp3.convert(@filename)
        end
      end
      
      describe 'when the original file should not be deleted' do
        before :each do
          @flac2mp3.stubs(:delete?).returns(false)
        end
        
        it 'should not delete the original file' do
          File.expects(:delete).never
          @flac2mp3.convert(@filename)
        end
      end
    end
    
    describe 'when given a filename not belonging to a regular file' do
      before :each do
        FileTest.stubs(:file?).returns(false)
      end
      
      it 'should error' do
        lambda { @flac2mp3.convert(@filename) }.should raise_error(TypeError)
      end
    end
  end
  
  it 'should process conversion' do
    @flac2mp3.should respond_to(:process_conversion)
  end
  
  describe 'when processing conversion' do
    before :each do
      @filename     = 'test.flac'
      @out_filename = 'test.mp3'
      @flac2mp3.stubs(:output_filename).returns(@out_filename)
      @flac2mp3.stubs(:convert_data)
      @flac2mp3.stubs(:convert_metadata)
    end
    
    it 'should accept a filename' do
      lambda { @flac2mp3.process_conversion(@filename) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a filename' do
      lambda { @flac2mp3.process_conversion }.should raise_error(ArgumentError)
    end
    
    it 'get the output filename from the given filename' do
      @flac2mp3.expects(:output_filename).with(@filename)
      @flac2mp3.process_conversion(@filename)
    end
    
    it 'should convert data' do
      @flac2mp3.expects(:convert_data).with(@filename, @out_filename)
      @flac2mp3.process_conversion(@filename)
    end
    
    it 'should convert metadata' do
      @flac2mp3.expects(:convert_metadata).with(@filename, @out_filename)
      @flac2mp3.process_conversion(@filename)
    end
  end
  
  it 'should provide an output filename' do
    @flac2mp3.should respond_to(:output_filename)
  end
  
  describe 'providing an output filename' do
    it 'should accept a filename' do
      lambda { @flac2mp3.output_filename('blah.flac') }.should_not raise_error(ArgumentError)
    end

    it 'should require a filename' do
      lambda { @flac2mp3.output_filename }.should raise_error(ArgumentError)
    end

    it 'should convert a .flac extension to an .mp3 extension' do
      @flac2mp3.output_filename('blah.flac').should == 'blah.mp3'
    end

    it 'should append an .mp3 extension if no .flac extension exists' do
      @flac2mp3.output_filename('blah').should == 'blah.mp3'
    end
  end
  
  it 'should convert data' do
    @flac2mp3.should respond_to(:convert_data)
  end
  
  describe 'when converting data' do
    before :each do
      @filename     = 'test.flac'
      @out_filename = 'test.mp3'
      @flac_command = 'flac command'
      @mp3_command  = 'mp3 command'
      @flac2mp3.stubs(:flac_command).returns(@flac_command)
      @flac2mp3.stubs(:mp3_command).returns(@mp3_command)
      @flac2mp3.stubs(:system)
    end
    
    it 'should accept a filename and an output filename' do
      lambda { @flac2mp3.convert_data(@filename, @out_filename) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require an output filename' do
      lambda { @flac2mp3.convert_data(@filename) }.should raise_error(ArgumentError)
    end
    
    it 'should require a filename' do
      lambda { @flac2mp3.convert_data }.should raise_error(ArgumentError)
    end
    
    it 'should call the flac command with the given filename' do
      @flac2mp3.expects(:flac_command).with(@filename)
      @flac2mp3.convert_data(@filename, @out_filename)
    end
    
    it 'should call the mp3 command with the given output filename' do
      @flac2mp3.expects(:mp3_command).with(@out_filename)
      @flac2mp3.convert_data(@filename, @out_filename)
    end
    
    it 'should shell out to the system with the flac and mp3 commands' do
      @flac2mp3.expects(:system).with("#{@flac_command} | #{@mp3_command}")
      @flac2mp3.convert_data(@filename, @out_filename)
    end
  end
  
  it 'should provide a flac command' do
    @flac2mp3.should respond_to(:flac_command)
  end
  
  describe 'when providing a flac command' do
    before :each do
      @filename = 'test.flac'
      @safe_filename = 'safetest.safeflac'
      @flac2mp3.stubs(:safequote).returns(@safe_filename)
      @flac2mp3.stubs(:silent?)
    end
    
    it 'should accept a filename' do
      lambda { @flac2mp3.flac_command(@filename) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a filename' do
      lambda { @flac2mp3.flac_command }.should raise_error(ArgumentError)
    end
    
    it 'should safequote the filename' do
      @flac2mp3.expects(:safequote).with(@filename)
      @flac2mp3.flac_command(@filename)
    end
    
    it 'should check if the command should be silent' do
      @flac2mp3.expects(:silent?)
      @flac2mp3.flac_command(@filename)
    end
    
    describe 'when the command should be silent' do
      before :each do
        @flac2mp3.stubs(:silent?).returns(true)
      end
      
      it 'should provide a flac shell command that will be silent' do
        @flac2mp3.flac_command(@filename).should == "flac --silent --stdout --decode #{@safe_filename}"
      end
    end
    
    describe 'when the command should not be silent' do
      before :each do
        @flac2mp3.stubs(:silent?).returns(false)
      end
      
      it 'should provide a flac shell command that will not be silent' do
        @flac2mp3.flac_command(@filename).should == "flac --stdout --decode #{@safe_filename}"
      end
    end
  end
  
  it 'should provide an mp3 command' do
    @flac2mp3.should respond_to(:mp3_command)
  end
  
  describe 'when providing an mp3 command' do
    before :each do
      @filename = 'test.mp3'
      @safe_filename = 'safetest.safemp3'
      @flac2mp3.stubs(:safequote).returns(@safe_filename)
      @flac2mp3.stubs(:silent?)
      @encoding = '--VAWESOME'
      @flac2mp3.stubs(:encoding).returns(@encoding)
    end
    
    it 'should accept a filename' do
      lambda { @flac2mp3.mp3_command(@filename) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a filename' do
      lambda { @flac2mp3.mp3_command }.should raise_error(ArgumentError)
    end
    
    it 'should safequote the filename' do
      @flac2mp3.expects(:safequote).with(@filename)
      @flac2mp3.mp3_command(@filename)
    end
    
    it 'should check if the command should be silent' do
      @flac2mp3.expects(:silent?)
      @flac2mp3.mp3_command(@filename)
    end
    
    it 'should check the encoding to use' do
      @flac2mp3.expects(:encoding)
      @flac2mp3.mp3_command(@filename)
    end
    
    describe 'when the command should be silent' do
      before :each do
        @flac2mp3.stubs(:silent?).returns(true)
      end
      
      it 'should provide an mp3 shell command that will be silent' do
        @flac2mp3.mp3_command(@filename).should == "lame --silent #{@encoding} - #{@safe_filename}"
      end
    end
    
    describe 'when the command should not be silent' do
      before :each do
        @flac2mp3.stubs(:silent?).returns(false)
      end
      
      it 'should provide an mp3 shell command that will not be silent' do
        @flac2mp3.mp3_command(@filename).should == "lame #{@encoding} - #{@safe_filename}"
      end
    end
  end
  
  it 'should quote filenames safely' do
    @flac2mp3.should respond_to(:safequote)
  end
  
  describe 'when quoting a filename safely' do
    it 'should accept a filename' do
      lambda { @flac2mp3.safequote('test.flac') }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a filename' do
      lambda { @flac2mp3.safequote }.should raise_error(ArgumentError)
    end
    
    it 'should leave alphanumeric characters alone' do
      @flac2mp3.safequote('abc_123').should == 'abc_123'
    end

    it 'should escape non-alphanumeric characters' do
      @flac2mp3.safequote(%q[a-b"c 12'3]).should == %q[a\-b\"c\ 12\'3]
    end
  end
  
  it 'should convert metadata' do
    @flac2mp3.should respond_to(:convert_metadata)
  end
  
  describe 'when converting metadata' do
    before :each do
      @filename     = 'test.flac'
      @out_filename = 'test.mp3'
      @flacdata = stub('flacdata')
      @flac2mp3.stubs(:get_flacdata).returns(@flacdata)
      @flac2mp3.stubs(:set_mp3data)
    end
    
    it 'should accept a filename and an output filename' do
      lambda { @flac2mp3.convert_metadata(@filename, @out_filename) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require an output filename' do
      lambda { @flac2mp3.convert_metadata(@filename) }.should raise_error(ArgumentError)
    end
    
    it 'should require a filename' do
      lambda { @flac2mp3.convert_metadata }.should raise_error(ArgumentError)
    end
    
    it 'should get the flac metadata' do
      @flac2mp3.expects(:get_flacdata).with(@filename)
      @flac2mp3.convert_metadata(@filename, @out_filename)
    end
    
    it 'should set the mp3 metadata with the flac metadata' do
      @flac2mp3.expects(:set_mp3data).with(@out_filename, @flacdata)
      @flac2mp3.convert_metadata(@filename, @out_filename)
    end
  end
end

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
  
  it 'should get FLAC tag data' do
    Flac2mp3.should respond_to(:flacdata)
  end
  
  it 'should set MP3 tag data' do
    Flac2mp3.should respond_to(:mp3data)
  end
end

describe Flac2mp3, 'when converting' do
  before :each do
    Flac2mp3.stubs(:system)
    Flac2mp3.stubs(:flacdata)
    Flac2mp3.stubs(:mp3data)
    File.stubs(:delete)
  end

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
    @output_filename = 'blah.mp3'
    Flac2mp3.stubs(:output_filename).with(@filename).returns(@output_filename)
    Flac2mp3.stubs(:system)
    
    @filename.stubs(:safequote).returns('-blah-flac-')
    @output_filename.stubs(:safequote).returns('-blah-mp3-')
    
    @flacdata = {}
    Flac2mp3.stubs(:flacdata).with(@filename).returns(@flacdata)
    Flac2mp3.stubs(:mp3data)
  end
  
  it 'should not error' do
    lambda { Flac2mp3.convert(@filename) }.should_not raise_error(TypeError)
  end
  
  it 'should extend the filename with the string extensions' do
    @filename.expects(:extend).with(Flac2mp3::StringExtensions).returns(@filename)
    Flac2mp3.convert(@filename)
  end
  
  it 'should get the output filename' do
    Flac2mp3.expects(:output_filename).with(@filename).returns('outfile')
    Flac2mp3.convert(@filename)
  end
  
  it 'should extend the output filename with the string extensions' do
    @output_filename.expects(:extend).with(Flac2mp3::StringExtensions).returns(@output_filename)
    Flac2mp3.convert(@filename)
  end
  
  it 'should use system commands to convert the FLAC to an MP3' do
    Flac2mp3.expects(:system).with("flac --stdout --decode #{@filename.safequote} | lame --preset standard - #{@output_filename.safequote}")
    Flac2mp3.convert(@filename)
  end
  
  it 'should set the MP3 tags from the FLAC data' do
    Flac2mp3.expects(:mp3data).with(@output_filename, @flacdata)
    Flac2mp3.convert(@filename)
  end
  
  it 'should accept an option to delete the flac' do
    lambda { Flac2mp3.convert(@filename, :delete => true) }.should_not raise_error(ArgumentError)
  end
  
  it 'should delete the original file if given a true value for the option' do
    File.expects(:delete).with(@filename)
    Flac2mp3.convert(@filename, :delete => true)
  end
  
  it 'should not delete the original file if given a false value for the option' do
    File.expects(:delete).never
    Flac2mp3.convert(@filename, :delete => false)
  end
  
  it 'should not delete the original file by default' do
    File.expects(:delete).never
    Flac2mp3.convert(@filename)
  end
  
  it 'should accept an option to run silently' do
    lambda { Flac2mp3.convert(@filename, :silent => true) }.should_not raise_error(ArgumentError)
  end
  
  it 'should tell the system commands to be silent if given a true value for the option' do
    Flac2mp3.expects(:system).with("flac --silent --stdout --decode #{@filename.safequote} | lame --silent --preset standard - #{@output_filename.safequote}")
    Flac2mp3.convert(@filename, :silent => true)
  end
  
  it 'should not tell the system commands to be silent if given a true value for the option' do
    Flac2mp3.expects(:system).with("flac --stdout --decode #{@filename.safequote} | lame --preset standard - #{@output_filename.safequote}")
    Flac2mp3.convert(@filename, :silent => false)
  end
  
  it 'should not tell the system commands to be silent by default' do
    Flac2mp3.expects(:system).with("flac --stdout --decode #{@filename.safequote} | lame --preset standard - #{@output_filename.safequote}")
    Flac2mp3.convert(@filename)
  end
  
  it 'should accept an option for encoding options' do
    lambda { Flac2mp3.convert(@filename, :encoding => '--preset fast standard') }.should_not raise_error(ArgumentError)
  end
  
  it 'should use the encoding options if given' do
    Flac2mp3.expects(:system).with("flac --stdout --decode #{@filename.safequote} | lame --vbr-new -V2 -h - #{@output_filename.safequote}")
    Flac2mp3.convert(@filename, :encoding => '--vbr-new -V2 -h')
  end
  
  it 'should default the encoding to --preset standard if no encoding options given' do
    Flac2mp3.expects(:system).with("flac --stdout --decode #{@filename.safequote} | lame --preset standard - #{@output_filename.safequote}")
    Flac2mp3.convert(@filename)
  end
  
  it 'should default the encoding to --preset standard if nil encoding options given' do
    Flac2mp3.expects(:system).with("flac --stdout --decode #{@filename.safequote} | lame --preset standard - #{@output_filename.safequote}")
    Flac2mp3.convert(@filename, :encoding => nil)
  end
  
  it 'should default the encoding to --preset standard if blank encoding options given' do
    Flac2mp3.expects(:system).with("flac --stdout --decode #{@filename.safequote} | lame --preset standard - #{@output_filename.safequote}")
    Flac2mp3.convert(@filename, :encoding => ' ')
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
end

describe Flac2mp3, 'when getting FLAC tag data' do
  before :each do
    @filename = 'blah.flac'
    @tags = {}
    @flacinfo = stub('flacinfo', :tags => @tags)
    FlacInfo.stubs(:new).with(@filename).returns(@flacinfo)
  end
  
  it 'should require a filename' do
    lambda { Flac2mp3.flacdata }.should raise_error(ArgumentError)
  end
  
  it 'should accept a filename' do
    lambda { Flac2mp3.flacdata('blah.flac') }.should_not raise_error(ArgumentError)
  end
  
  it 'should create a FlacInfo object' do
    FlacInfo.expects(:new).with(@filename).returns(@flacinfo)
    Flac2mp3.flacdata(@filename)
  end
  
  it 'should use the FlacInfo object tags' do
    @flacinfo.expects(:tags).returns(@tags)
    Flac2mp3.flacdata(@filename)
  end
  
  it 'should return a hash of the tag data' do
    @tags[:artist] = 'blah'
    @tags[:blah] = 'boo'
    @tags[:comment] = 'hey'
    
    data = Flac2mp3.flacdata(@filename)
    data[:artist].should == 'blah'
    data[:blah].should == 'boo'
    data[:comment].should == 'hey'
  end
  
  it 'should convert tags to symbols' do
    @tags['artist'] = 'blah'
    @tags['blah'] = 'boo'
    @tags['comment'] = 'hey'
    
    data = Flac2mp3.flacdata(@filename)
    data[:artist].should == 'blah'
    data[:blah].should == 'boo'
    data[:comment].should == 'hey'
    
    data.should_not have_key('artist')
    data.should_not have_key('blah')
    data.should_not have_key('comment')
  end
  
  it 'should convert tags to lowercase' do
    @tags['Artist'] = 'blah'
    @tags[:BLAH] = 'boo'
    @tags['cOmMeNt'] = 'hey'
    
    data = Flac2mp3.flacdata(@filename)
    data[:artist].should == 'blah'
    data[:blah].should == 'boo'
    data[:comment].should == 'hey'
    
    data.should_not have_key('Artist')
    data.should_not have_key(:BLAH)
    data.should_not have_key('cOmMeNt')
  end
  
  it 'should convert values consisting only of digits to actual numbers' do
    @tags[:track] = '12'
    
    data = Flac2mp3.flacdata(@filename)
    data[:track].should == 12
  end
  
  it 'should leave numeric titles as strings' do
    @tags[:title] = '45'  # This was my first run-in with this problem, the opening track on Elvis Costello's /When I Was Cruel/
    
    data = Flac2mp3.flacdata(@filename)
    data[:title].should == '45'
  end
  
  it 'should leave numeric titles as strings even if the title key is not a simple downcased symbol' do
    @tags['TITLE'] = '45'
    
    data = Flac2mp3.flacdata(@filename)
    data[:title].should == '45'
  end
  
  it 'should leave numeric descriptions as strings' do
    @tags[:description] = '1938'  # This was my first run-in with this problem, from the Boilermakers' version of "Minor Swing" where for the description all I had was the year of the original
    
    data = Flac2mp3.flacdata(@filename)
    data[:description].should == '1938'
  end
  
  it 'should leave numeric descriptions as strings even if the description key is not a simple downcased symbol' do
    @tags['DESCRIPTION'] = '1938'
    
    data = Flac2mp3.flacdata(@filename)
    data[:description].should == '1938'
  end
end

describe Flac2mp3, 'when setting MP3 tag data' do
  before :each do
    @filename = 'blah.mp3'
    @tags = {}
    @mp3tags = stub('mp3info tags')
    @mp3tags2 = stub('mp3info tags 2')
    @mp3info = stub('mp3info obj', :tag => @mp3tags, :tag2 => @mp3tags2)
    Mp3Info.stubs(:open).with(@filename).yields(@mp3info)
  end
  
  it 'should require a filename' do
    lambda { Flac2mp3.mp3data }.should raise_error(ArgumentError)
  end
  
  it 'should require tag data' do
    lambda { Flac2mp3.mp3data('blah.mp3') }.should raise_error(ArgumentError)
  end
  
  it 'should accept a filename and tag data' do
    lambda { Flac2mp3.mp3data('blah.mp3', 'tags') }.should_not raise_error(ArgumentError)
  end
  
  it 'should require a hash of tags' do
    lambda { Flac2mp3.mp3data('blah.mp3', 'blah') }.should raise_error(TypeError)
  end
  
  it 'should accept a hash of tags' do
    lambda { Flac2mp3.mp3data('blah.mp3', {}) }.should_not raise_error(TypeError)
  end
  
  it 'should use an Mp3Info object' do
    Mp3Info.expects(:open).with(@filename).yields(@mp3info)
    Flac2mp3.mp3data(@filename, @tags)
  end
  
  it 'should set tags in the Mp3Info object' do
    @tags[:album] = 'blah'
    @tags[:artist] = 'boo'
    @tags[:genre] = 'bang'
    
    @mp3tags.expects(:album=).with(@tags[:album])
    @mp3tags.expects(:artist=).with(@tags[:artist])
    @mp3tags.expects(:genre_s=).with(@tags[:genre])
    
    Flac2mp3.mp3data(@filename, @tags)
  end
  
  it 'should not set tags not given' do
    @tags[:album] = 'blah'
    @tags[:artist] = 'boo'
    @tags[:genre] = 'bang'
    
    @mp3tags.stubs(:album=)
    @mp3tags.stubs(:artist=)
    @mp3tags.stubs(:genre_s=)
    
    @mp3tags.expects(:comments=).never
    @mp3tags.expects(:year=).never
    
    Flac2mp3.mp3data(@filename, @tags)
  end
  
  it 'should not set tags not known' do
    @tags[:blah] = 'blah'
    @tags[:bang] = 'bang'
    
    @mp3tags.expects(:blah=).never
    @mp3tags.expects(:bang=).never
    
    Flac2mp3.mp3data(@filename, @tags)
  end
  
  it 'should use tag2 for bpm' do
    @tags[:bpm] = '5'
    
    @mp3tags2.expects(:TBPM=).with(@tags[:bpm])
    
    Flac2mp3.mp3data(@filename, @tags)
  end
  
  it 'should use tag2 for composer' do
    @tags[:composer] = 'Il Maestro'
    
    @mp3tags2.expects(:TCOM=).with(@tags[:composer])
    
    Flac2mp3.mp3data(@filename, @tags)
  end
  
  it 'should use tag2 for compilation' do
    @tags[:compilation] = '1'
    
    @mp3tags2.expects(:TCMP=).with(@tags[:compilation])
    
    Flac2mp3.mp3data(@filename, @tags)
  end
  
  it 'should set tag2 track to be a combination of tracknumber and tracktotal' do
    @tags[:tracknumber] = 4
    @tags[:tracktotal]  = 15
    
    @mp3tags2.expects(:TRCK=).with('4/15')
    
    Flac2mp3.mp3data(@filename, @tags)
  end
  
  it "should set tag2 'pos' to be a combination of discnumber and disctotal" do
    @tags[:discnumber] = 1
    @tags[:disctotal]  = 2
    
    @mp3tags2.expects(:TPOS=).with('1/2')
    
    Flac2mp3.mp3data(@filename, @tags)
  end
end
