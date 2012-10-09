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

  describe "#item_number" do
    it 'gets item number from datum' do
      subject.item_number("1. Ruby")
    end

    it 'sees item number from datum' do
      whole_file_text = "Languages\n1. Ruby"
      subject.item_number(whole_file_text).should == "1"
    end

    it 'understands multidigit items' do
      subject.item_number("Languages\n100. Ruby").should == "100"
    end
  end

  adopt_1 = Recommendation.new("1", "Adopt", radar_date)
  hold_2 = Recommendation.new("2", "Hold", radar_date)
  
  describe "#get_recommendations_from_string" do
    rec_string = "Adopt 1"
    two_rec_string = "Adopt 1\nHold 2"
    item_string = "Tools\n10. Visualization & metrics"

    it "sees recommendation in string" do
      subject.get_recommendations_from_string(rec_string, radar_date).should include adopt_1
    end

    it "sees several recommendations in string" do
      subject.get_recommendations_from_string(two_rec_string, radar_date).should include adopt_1
      subject.get_recommendations_from_string(two_rec_string, radar_date).should include hold_2
      subject.get_recommendations_from_string(two_rec_string, radar_date).size.should == 2
    end

    it "sees no recommendation in item string" do
      subject.get_recommendations_from_string(item_string, radar_date).size.should == 0
    end

    it "sees ranges of recs" do
      subject.get_recommendations_from_string("Adopt 1-3", radar_date).size.should == 3
    end
  end

  it "should get recs from range" do
    adopt_1 = Recommendation.new("1", "Adopt", radar_date)
    subject.get_range_recs("1-3", "Adopt", radar_date).size.should == 3
    subject.get_range_recs("1-3", "Adopt", radar_date).should include adopt_1 
  end
end