class Parser

attr_reader

	def initialize
	end

  def date_of filename
    matcher = filename.match /(\d{4})-(\d{2})\.txt/
    Date.new(matcher[1].to_i, matcher[2].to_i, 1)
  end

  def item_number datum
    regex = /(\d*)\..*/
    matcher = datum.match(regex)
    (matcher.nil? ? nil : (datum.match regex)[1] )
  end

  def item_name datum
    regex = /\d*\. (.*)/
    matcher = datum.match(regex)
    (matcher.nil? ? nil : (datum.match regex)[1].gsub(",","") )
  end

  def get_recommendations_from_string file_text, date
    file_text.split("\n").map {|line|
      line_components = line.split(" ")
      possible_rec_name = line_components.first
      if ["Adopt", "Trial", "Assess", "Hold"].include?(possible_rec_name) then 
        make_recs_from_datums(possible_rec_name, line_components, date)
      end
    }.flatten.compact
  end

  def make_recs_from_datums current_recommendation, line_components, date
    line_components.delete current_recommendation
    line_components.map {|number_item_or_range|
      if number_item_or_range.include?("-")
        number_item_or_range.gsub!(",", "")
        get_range_recs(number_item_or_range, current_recommendation, date)
      else
        number = Parser.new.item_number(number_item_or_range)
        puts "- - - -trying to build a rec: num #{number} current_recommendation #{current_recommendation} date #{date}"
        if !(number.nil? || current_recommendation.nil? || date.nil?) then
          Recommendation.new(number, current_recommendation, date)
        end
      end
    }
  end

  def get_range_recs range_string, current_recommendation, date
    range_endpoints = range_string.split("-")
    (range_endpoints.first..range_endpoints.last).map {|number|
      if !(number.nil? || current_recommendation.nil? || date.nil?) then
        Recommendation.new(number, current_recommendation, date)
      end
    }
  end

  def get_data_from_file data_dir, filename
    all_text_in_file = ""
    File.open(data_dir + "/" + filename).each_line { |line| 
      all_text_in_file += line
    }
    all_text_in_file
  end
end