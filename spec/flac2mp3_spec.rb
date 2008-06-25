require File.dirname(__FILE__) + '/spec_helper.rb'

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
    File.stubs(:delete)
    @output_filename = 'blah.mp3'
    Flac2mp3.stubs(:output_filename).with(@filename).returns(@output_filename)
    Flac2mp3.stubs(:system)
    
    @flacdata = {}
    Flac2mp3.stubs(:flacdata).with(@filename).returns(@flacdata)
    Flac2mp3.stubs(:mp3data)
  end
  
  it 'should not error' do
    lambda { Flac2mp3.convert(@filename) }.should_not raise_error(TypeError)
  end
  
  it 'should extend the filename with the string extensions' do
    @filename.expects(:extend).with(Flac2mp3::StringExtensions).returns(@filename)
    @filename.stubs(:safequote)
    Flac2mp3.convert(@filename)
  end
  
  it 'should get the output filename' do
    Flac2mp3.expects(:output_filename).with(@filename).returns('outfile')
    Flac2mp3.convert(@filename)
  end
  
  it 'should extend the output filename with the string extensions' do
    @output_filename.expects(:extend).with(Flac2mp3::StringExtensions).returns(@output_filename)
    @output_filename.stubs(:safequote)
    Flac2mp3.convert(@filename)
  end
  
  it 'should use system commands to convert the FLAC to an MP3' do
    @filename.stubs(:safequote).returns('-blah-flac-')
    @output_filename.stubs(:safequote).returns('-blah-mp3-')
    Flac2mp3.expects(:system).with("flac -c -d #{@filename.safequote} | lame --preset standard - #{@output_filename.safequote}")
    
    Flac2mp3.convert(@filename)
  end
  
  it 'should set the MP3 tags from the FLAC data' do
    Flac2mp3.expects(:mp3data).with(@output_filename, @flacdata)
    Flac2mp3.convert(@filename)
  end
  
  it 'should accept an option to delete the flac' do
    lambda { Flac2mp3.convert('blah.flac', true) }.should_not raise_error(ArgumentError)
  end
  
  it 'should delete the original file if given a true value for the option' do
    File.expects(:delete).with(@filename)
    Flac2mp3.convert(@filename, true)
  end
  
  it 'should not delete the original file if given a false value for the option' do
    File.expects(:delete).never
    Flac2mp3.convert(@filename, false)
  end
  
  it 'should not delete the original file by default' do
    File.expects(:delete).never
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
