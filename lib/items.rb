require_relative 'item'
require_relative 'recommendation'

class Items
	include Enumerable

	attr_reader :items, :data_dir, :item_types, :recommendation_types

	def initialize data_dir
		@data_dir = data_dir
		@items = get_items(data_dir)
		@recommendation_types = ["Adopt", "Trial", "Assess", "Hold"]
		@item_types = ["Languages", "Tools", "Techniques", "Platforms"]
	end

	def get_items_from_string file_text, radar_date
		most_recent_header = ""

		file_text.split("\n").map { |datum| 
			most_recent_header = datum if (["Languages", "Tools", "Techniques", "Platforms"].include?(datum)) 
			most_recent_header == datum ? nil : Item.new(item_name(datum), radar_date, most_recent_header, item_number(datum))
		}.compact.reject { |item|
			item.name.nil?
		}
	end

	def get_items data_dir
		get_filenames(data_dir).map { |filename|
			[get_data_from_file(filename), date_of(filename)]
		}.map { |file_content, date|
			get_items_from_string(file_content, date)
		}.inject(:+)
	end

	def with_recs
    add_recs_to_items(get_recommendations_in_dir)
	end

  def with_recs_json
    with_recs.map {|item| item.to_json}
  end

  def with_recs_csv
  	with_recs.map {|item| item.to_csv}
  end

	def date_of filename
		matcher = filename.match /(\d{4})-(\d{2})\.txt/
		Date.new(matcher[1].to_i, matcher[2].to_i, 1)
	end

	def get_filenames data_dir
		Dir.entries(data_dir).reject { |filename|
			filename.match /^\..*/
		}
	end

	def get_data_from_file filename
		all_text_in_file = ""
		File.open(data_dir + "/" + filename).each_line { |line| 
			all_text_in_file += line
		}
		all_text_in_file
	end

	def item_number datum
		regex = /(\d*)\..*/
		matcher = datum.match(regex)
		(matcher.nil? ? nil : (datum.match regex)[1] )
	end

	def item_name datum
		regex = /\d*\. (.*)/
		matcher = datum.match(regex)
		(matcher.nil? ? nil : (datum.match regex)[1] )
	end

	def get_recommendations_in_dir
		get_filenames(data_dir).map { |filename|
			[get_data_from_file(filename), date_of(filename)]
		}.map { |file_content, date| 
			get_recommendations_from_string(file_content, date)
		}.flatten
	end

  def get_range_recs range_string, current_recommendation, date
    range_endpoints = range_string.split("-")
    (range_endpoints.first..range_endpoints.last).map {|number|
      Recommendation.new(number, current_recommendation, date)
    }
  end

	def get_recommendations_from_string file_text, date
    file_text.split("\n").map {|line|
      line_components = line.split(" ")
      possible_rec_name = line_components.first
      if recommendation_types.include?(possible_rec_name) then 
        make_recs_from_datums possible_rec_name, line_components, date
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
        Recommendation.new(item_number(number_item_or_range), current_recommendation, date)
      end
    }
	end

	def rec_item_numbers current_recommendation, line_components
		line_components.delete(current_recommendation)

		line_components.reject { |component|
			recommendation_types.include? component
		}.map { |range_string|
			range = range_string.split("-")
			(range.first.to_i..range.last.to_i).map {|number|
				number.to_s
			}
		}.flatten
	end

	def add_recs_to_items *recommendations
    recommendations.flatten.map { |rec| 
			items.map {|item|
				if item.matches(rec) then
					item.add_rec(rec.name)
				end
			}
		}
    items
	end
end
