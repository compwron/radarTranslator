require_relative "../lib/radar_dynamo"

describe RadarDynamo do

  subject { RadarDynamo.new 'spec/radars' }

  # it "should parse file contents" do
  #   one_file_one_language_no_recommendation = {
  #     "Python" => { }
  #   } 

  #   subject.parse_file(["Languages\n1. Ruby  "]).should == one_file_one_language_no_recommendation
  # end

  it 'knows whether item is a language' do
    radar_date = Date.new(2010,1,1)
    language_item = {"Ruby"=>{radar_date =>{"category"=>"Languages"}}}
    whole_file_text = "Languages\n1. Ruby"
    subject.get_items(whole_file_text, radar_date).should include language_item
  end

  it "should see files in dir" do
  	subject.filenames.should == ["2010-01.txt", "2012-03.txt"]
  end

  # it "should get raw data from files" do
  # 	subject.get_data_from_files.should == ["Languages\n1. Ruby", "Languages\n1. Python"]
  # end

  # describe "#data" do
  #   let(:data) { subject.data_output }

  #   it "has all data in tech -> radar -> classification, type, number" do
  #         desired_data = {
		# 	"Python" => {
		# 		"2010-01" => {
		# 			"category" => "languages",
		# 			"recommendation" => "trial"
		# 		},
		# 		"2012-03" => {
		# 			"category" => "languages",
		# 			"recommendation" => "adopt"
		# 		}
		# 	}
		# }

      # data.should == desired_data
    # end
  # end
end



