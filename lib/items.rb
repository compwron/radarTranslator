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
		items.select {|item| !item.recommendation.nil? }
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

	def to_json
		items.map { |item|
			item.to_json
		}
	end

	def to_s
		"#{data_dir}: #{items}"
	end

	def get_recommendations
		get_filenames(data_dir).map { |filename|
			[get_data_from_file(filename), date_of(filename)]
		}.map { |file_content, date| 
			get_recommendations_from_string(file_content, date)
		}
	end

	def get_recommendations_from_string file_text, date
		file_text.split("\n").map { |datum|
			line_components = datum.split(" ").map { |component| component.split(",") }.flatten
			p line_components
			current_recommendation = line_components.first
			line_components.delete current_recommendation

			line_components.map{ |number|
				if (recommendation_types.include?(current_recommendation)) then 
					Recommendation.new(number, current_recommendation, date)
				end
		  	}
		}.flatten
	end

		def get_recommendations file_text, radar_date
		file_text.split("\n").map { |datum|
			line_components = datum.split(" ").map { |component|
																							component.split(",")
																						}.flatten
			current_recommendation = line_components.first
			{current_recommendation => [rec_item_numbers(current_recommendation, line_components), radar_date] }
		}.reject {|rec|
			!(recommendation_types.include? rec.keys.first)
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
		recommendations.map { |rec| 
			items.each {|item|
				if item.matches(rec) then
					item.add_rec(rec.name)
				end
			}
		}
	end

	def rec_items_with_matching_dates item_date, rec_date, rec_numbers, item_number, item, rec_type
		modified_items = []
		if (item_date == rec_date) then
			rec_numbers.each { |rec_numbers| 
				if (rec_numbers.include? item_number) then
					modified_items += [add_recommendation_value_to_item(item, rec_type)]
				end
			}
		end
		modified_items
	end

	def add_recommendation_value_to_item item, rec_type
		item.add_rec rec_type
		item
	end

	def for_date(date)
		get_items(data_dir).select { |item|
			item.date == date
		}
	end


end
