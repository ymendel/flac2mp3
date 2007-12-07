require File.dirname(__FILE__) + '/spec_helper.rb'

describe String, 'in general' do
  it 'should not safequote' do
    String.new.should_not respond_to(:safequote)
  end
end

describe String, 'extended with string extensions' do
  it 'should safequote' do
    str = String.new
    str.extend(Flac2mp3::StringExtensions)
    str.should respond_to(:safequote)
  end
end

describe String, 'safequoting' do
  it 'should leave alphanumeric characters alone' do
    str = 'abc_123'
    str.extend(Flac2mp3::StringExtensions)
    str.safequote.should == 'abc_123'
  end
  
  it 'should escape non-alphanumeric characters' do
    str = %q[a-b"c 12'3]
    str.extend(Flac2mp3::StringExtensions)
    str.safequote.should == %q[a\-b\"c\ 12\'3]
  end
end
