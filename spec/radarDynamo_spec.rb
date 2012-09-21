require_relative "../lib/radar_dynamo"

describe RadarDynamo do

  subject { RadarDynamo.new 'spec/radars' }

  it "should see files in dir" do
  	subject.filenames.should == ["2010-01.txt", "2012-03.txt"]
  end

  describe "#data" do
    let(:data) { subject.data_output }

    it "has all data in tech -> radar -> classification, type, number" do
      test_hash = { "Python" => { [Date.new(2012, 3, 1)] => ['Adopt', 'Language', 1] }, "Ruby" => { [Date.new(2012, 3, 1), Date.new(2010, 1, 1)] => ['Adopt', 'Language', 1] } }
      data.should == test_hash
    end
  end
end



