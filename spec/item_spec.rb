require_relative "../lib/item"
require 'date'

describe Item do

  radar_date = Date.new(2010,1,1)
  subject { Item.new "Ruby", radar_date, "Languages", "1"}
  
  it 'should have a to_json option' do
    subject.to_json.should == {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>nil}}}
  end

  it 'can have a recommendation added to it' do
    subject.add_rec("Adopt")
    subject.to_json.should == {"Ruby"=>{radar_date =>{"category"=>"Languages", "number" => "1", "recommendation"=>"Adopt"}}}
  end

  it 'should have an intelligible string form' do
    subject.add_rec("Adopt")
    subject.to_s.should == "Ruby 2010-01-01 Languages 1 Adopt"
  end
end
