require_relative "../lib/parser"

describe Parser do

  subject { Parser.new }
  radar_date = Date.new(2010, 01, 01)
  
  it 'gets date from filename' do
    subject.date_of("2010-01.txt").should == radar_date
  end

  it 'gets item name from datum' do
    subject.item_name("1. Ruby")
  end
end