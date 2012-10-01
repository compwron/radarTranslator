# assume that vanishing means staying still (i.e. if in trial and then hold, assume stays in hold)
# desired output: all data in json format. and/or report of everything that has stayed still in adopt (or x section) for x years?
require 'date'

class RadarDynamo
	attr_accessor :data_dir, :item_types, :recommendations

	def initialize data_dir
		@data_dir = data_dir
		@item_types = ["Languages", "Tools", "Techniques", "Platforms"]
		@recommendations = ["Adopt", "Trial", "Assess", "Hold"]
	end

	def items_with_recs
		get_filenames(data_dir).map { |filename| 
			[get_data_from_file(filename), date_of(filename)]
		}.map { |file_text, date|
			get_items_with_recommendations(file_text, date)
		}.flatten
	end

	def get_filenames data_dir
		Dir.entries(data_dir).reject { |filename|
			filename == "." || filename == ".."
		}
	end

	def get_items data_dir
		get_filenames(data_dir).map { |filename|
			[get_data_from_file(filename), date_of(filename)]
		}.map { |file_content, date|
			get_items_from_string(file_content, date)
		}.inject(:+)
	end

	def date_of filename
		matcher = filename.match /(\d{4})-(\d{2})\.txt/
		Date.new(matcher[1].to_i, matcher[2].to_i, 1)
	end

	def get_data_from_file filename
			all_text_in_file = ""
			File.open(data_dir + "/" + filename).each_line { |line| 
				all_text_in_file += line
			}
			all_text_in_file
	end


	def get_items_from_string file_text, radar_date
		most_recent_header = ""

		file_text.split("\n").select { |item| 
			!item.nil? 
		}.map { |item| 
			most_recent_header = item if (item_types.include?(item)) 
			most_recent_header == item ? nil : tech_object(item_name(item), radar_date, most_recent_header, item_number(item))
		}.compact.reject { |item|
			item.keys.include? nil
		}
	end

	def item_number item
		regex = /(\d*)\..*/
		matcher = item.match(regex)
		(matcher.nil? ? nil : (item.match regex)[1] )
	end

	def item_name item
		regex = /\d*\. (.*)/
		matcher = item.match(regex)
		(matcher.nil? ? nil : (item.match regex)[1] )
	end

	def get_recommendations file_text, radar_date
		file_text.split("\n").map { |item|
			line_components = item.split(" ").map { |component|
																							component.split(",")
																						}.flatten
			current_recommendation = line_components.first
			{current_recommendation => [rec_item_numbers(current_recommendation, line_components), radar_date] }
		}.reject {|rec|
			!(recommendations.include? rec.keys.first)
		}
	end

	def rec_item_numbers current_recommendation, line_components
		line_components.delete(current_recommendation)

		line_components.reject { |component|
			recommendations.include? component
		}.map { |range_string|
			range = range_string.split("-")
			(range.first.to_i..range.last.to_i).map {|number|
				number.to_s
			}
		}.flatten
	end

	def get_items_with_recommendations file_text, radar_date
		get_recommendations(file_text, radar_date).map { |rec_type_hash|
			rec_type = rec_type_hash.first.first
			rec_number_and_date = rec_type_hash.values.first
			rec_numbers = rec_number_and_date.first
			rec_date = rec_number_and_date.last

			get_items_for_date(rec_date).map { |item|
				item_dates = item.values.first

				item_dates.map { |hash_with_item_date_as_key| 
					item_date = hash_with_item_date_as_key.first
					item_number = hash_with_item_date_as_key.last["number"]

					rec_items_with_matching_dates(item_date, rec_date, rec_numbers, item_number, item, rec_type)
				}
			}
		}.flatten
	end

	def rec_items_with_matching_dates item_date, rec_date, rec_numbers, item_number, item, rec_type
		modified_items = []
		if (item_date == rec_date) then
			rec_numbers.each { |rec_numbers| 
				if (rec_numbers.include? item_number) then
					modified_items += [add_recommendation_value_to_item(item, rec_type, item_date)]
				end
			}
		end
		modified_items
	end

	def add_recommendation_value_to_item item, rec_type, date
		rec = {"recommendation" => rec_type}
		item.first.last[date].merge! rec
		item
	end

	def get_items_for_date(date)
		get_items(data_dir).select { |item|
			dates_from_item = item.values.first.keys
			dates_from_item.include? date
		}
	end

	def tech_object item_name, radar_date, most_recent_header, item_number
		{ item_name => { 
				radar_date => {
					"category" => most_recent_header,
					"number" => item_number
				}
			}
		}
	end
end
