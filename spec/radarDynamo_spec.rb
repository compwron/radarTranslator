require_relative "../lib/radar_dynamo"

describe RadarDynamo do

  subject { RadarDynamo.new 'spec/radars' }

  describe "#get_items" do

    # let(:items) { subject.get_items(whole_file_text, radar_date) }
    
    radar_date = Date.new(2010,1,1)
    
    it 'knows whether item is a language' do
      whole_file_text = "Languages\n1. Ruby"
      language_item = {"Ruby"=>{radar_date =>{"category"=>"Languages"}}}
      subject.get_items(whole_file_text, radar_date).should include language_item
    end

    it 'can see two language items in a file' do
      whole_file_text = "Languages\n1. Ruby\n2. Python"
      ruby_item = {"Ruby"=>{radar_date =>{"category"=>"Languages"}}}
      python_item = {"Python"=>{radar_date =>{"category"=>"Languages"}}}
      
      subject.get_items(whole_file_text, radar_date).should include ruby_item
      subject.get_items(whole_file_text, radar_date).should include python_item
    end

     it 'can see a language item and a tools item' do
       whole_file_text = "Languages\n1. Ruby\n\nTools\n14. Subversion"
       languages_item = {"Ruby"=>{radar_date =>{"category"=>"Languages"}}}
       tools_item = {"Subversion"=>{radar_date =>{"category"=>"Tools"}}}
      
        subject.get_items(whole_file_text, radar_date).should include tools_item
        subject.get_items(whole_file_text, radar_date).should include languages_item
        subject.get_items(whole_file_text, radar_date).should_not include nil
     end

     it 'can compose an item with spaces in the name' do
        whole_file_text = "Tools\n10. Visualization & metrics"
        tools_item = {"Visualization & metrics"=>{radar_date =>{"category"=>"Tools"}}}

        subject.get_items(whole_file_text, radar_date).should include tools_item
     end

    #  it 'can combine item with recommendation' do
    #   whole_file_text = "Adopt 1\n\nLanguages\n1. Ruby"
    #   item_with_recommendation = {"Ruby"=>{radar_date =>{"category"=>"Languages", "recommendation"=>"Adopt"}}}

    #   subject.get_items(whole_file_text, radar_date).should include item_with_recommendation
    # end
  end

  it 'can combine several items with recommendation list' do 
  end

  it "should get raw data from files" do
  	subject.get_data_from_files(["2010-01.txt", "2012-03.txt"]).should == ["Languages\n1. Ruby", "Languages\n1. Python"]
  end
end
