require_relative "../lib/parser"

describe Parser do

  subject { Parser.new }
  radar_date = Date.new(2010, 01, 01)

  it "should get current rec name from current and possible rec names" do
    subject.get_rec_name("Trial", nil).should == "Trial"
    subject.get_rec_name("foo", nil).should == nil
    subject.get_rec_name("Trial", "Adopt").should == "Trial"
  end
  describe "#is_range? and #is_number?" do
    it "should see valid rec number" do
      subject.is_number?("1").should == "1"
    end

    it "should see valid multidigit rec number" do
      subject.is_number?("100").should == "100"
    end

    it "should see valid rec range" do
      subject.is_range?("1-3").should == "1-3"
    end

    it "should not match item string" do
      subject.is_range?("Tools\n10. Visualization & metrics").should == nil
      subject.is_number?("Tools\n10. Visualization & metrics").should == "10" # have to prevent this at a higher level
    end
  end
  
  it 'gets date from filename' do
    subject.date_of("2010-01.txt").should == radar_date
  end

  describe "#item_name" do
    it 'gets item name from datum' do
      subject.item_name("1. Ruby").should == "Ruby"
    end

    it 'does not keep commas in item name' do
      subject.item_name("1. Ruby, Python, and Clojure").should == "Ruby Python and Clojure"
    end
  end

  describe "#item_number" do
    it 'gets item number from datum' do
      subject.item_number("1. Ruby")
    end

    it 'sees item number from datum' do
      whole_file_text = "Languages\n1. Ruby"
      subject.item_number(whole_file_text).should == "1"
    end

    it 'understands multidigit item number' do
      subject.item_number("Languages\n100. Ruby").should == "100"
    end
  end
  
  describe "#get_recommendations_from_string" do
    adopt_1 = Recommendation.new("1", "Adopt", radar_date)
    
    it "sees recommendation in string" do
      subject.get_recommendations_from_string("Adopt 1", radar_date).should include adopt_1
    end

    it "sees more than one recommendation in file contents" do
      recs_from_two_rec_string = subject.get_recommendations_from_string("Adopt 1\nHold 2", radar_date)

      recs_from_two_rec_string.should include adopt_1
      recs_from_two_rec_string.should include Recommendation.new("2", "Hold", radar_date)
      recs_from_two_rec_string.size.should == 2
    end

    it "sees no recommendation in item string" do
      puts "hopefully-invalid recs #{subject.get_recommendations_from_string("Tools\n10. Visualization & metrics", radar_date)}"
      subject.get_recommendations_from_string("Tools\n10. Visualization & metrics", radar_date).size.should == 0
    end

    it "sees ranges of recs" do
      subject.get_recommendations_from_string("Adopt 1-3", radar_date).size.should == 3
      subject.get_recommendations_from_string("Adopt 1-3", radar_date).should include Recommendation.new("2", "Adopt", radar_date)
    end

    it "picks up rec from bug case 2012-01 #25" do
      filename = "2010-01.txt"
      date = Date.new(2010,1,1)
      string = subject.get_data_from_file("spec/end_to_end", filename)
      trial_android_platform = Recommendation.new("25", "Trial", date)
      subject.get_recommendations_from_string(string, date).should include trial_android_platform
    end
  end

  it "should get recs from range" do
    adopt_1 = Recommendation.new("1", "Adopt", radar_date)
    subject.get_range_recs("1-3", "Adopt", radar_date).size.should == 3
    subject.get_range_recs("1-3", "Adopt", radar_date).should include adopt_1 
  end

  it "should get raw data from files" do
    subject.get_data_from_file("spec/radars", "2010-01.txt").should == "Adopt 1\n\nLanguages\n1. Ruby"
  end

  it 'gets filenames from data dir' do
    data_dir = 'spec/radars'
    subject.get_filenames(data_dir).should include "2010-01.txt"
    subject.get_filenames(data_dir).should include "2012-03.txt"
    subject.get_filenames(data_dir).should_not include "2010-08.txt"
    subject.get_filenames(data_dir).should_not include "."
  end

  
end