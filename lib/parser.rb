require_relative "recommendation"

class Parser

  @@valid_rec_names = ["Adopt", "Trial", "Assess", "Hold"]

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
    if matcher.nil? then
      nil 
    else
      (datum.match regex)[1].gsub(",","")
    end
  end

  def get_rec_name possible_rec_name, current_rec_name
    current_rec_name.nil? ? (@@valid_rec_names.include? possible_rec_name ? possible_rec_name : current_rec_name) : current_rec_name
  end

  def is_number_or_range datum
    regex = /(\d*)|(\d*\-\d*)/
    matcher = datum.match(regex)
    if matcher.nil? then 
      nil
    else
      (datum.match regex)[1]
    end
  end

  def make_recs number_item_or_range, recommendation, date
    puts "inside making recs using range #{number_item_or_range} and rec #{recommendation} and date #{date}"
    number_item_or_range.gsub!(",", "")
    if is_number_or_range(number_item_or_range) then
      if number_item_or_range.include?("-")
        get_range_recs(number_item_or_range, recommendation, date)
      else
        make_single_rec(number_item_or_range, recommendation, date)
      end
    end
  end

  def get_recommendations_from_string file_text, date
    file_text.split("\n").map { |line|
      line_components = line.split(" ")
      possible_rec_name = line_components.first
      current_rec_name = get_rec_name(possible_rec_name, current_rec_name)

      line_components.reject! { |line_component| 
        @@valid_rec_names.include? line_component 
      }

      line_components.map {|number_item_or_range|
        make_recs(number_item_or_range, current_rec_name, date)
      }
    }.flatten.compact
  end

  def make_single_rec number, rec_name, date
    if !(number.nil? || rec_name.nil? || date.nil?) then
      Recommendation.new(number, rec_name, date)
    end
  end

  def get_range_recs range_string, current_recommendation, date
    range_endpoints = range_string.split("-")
    (range_endpoints.first..range_endpoints.last).map {|number|
      make_single_rec(number, current_recommendation, date)
    }
  end

  def get_data_from_file data_dir, filename
    all_text_in_file = ""
    File.open(data_dir + "/" + filename).each_line { |line| 
      all_text_in_file += line
    }
    all_text_in_file
  end

  def get_filenames data_dir
    Dir.entries(data_dir).reject { |filename|
      filename.match /^\..*/
    }
  end
end