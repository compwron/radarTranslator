require_relative "../lib/radar_dynamo"

describe RadarDynamo do

  subject { RadarDynamo.new 'spec/radars' }

  it "should see files in dir" do
  	subject.filenames.should == ["2010-01.txt", "2012-03.txt"]
  end

  it "should get raw data from files" do
  	subject.get_data_from_files.should == ["Languages\n1. Ruby  ", "Languages\n1. Ruby  Languages\n1. Python     "]
  end

  describe "#data" do
    let(:data) { subject.data_output }

    it "has all data in tech -> radar -> classification, type, number" do
          desired_data = {
			"Python" => {
				"2010-01" => {
					"category" => "languages",
					"recommendation" => "trial"
				},
				"2012-03" => {
					"category" => "languages",
					"recommendation" => "adopt"
				}
			}
		}

      data.should == desired_data
    end
  end
end



