require 'date'
p `pwd`
require_relative 'items'


class RadarDynamo
	attr_accessor :data_dir, :recommendations, :items

	def initialize data_dir
		@data_dir = data_dir
		@recommendations = ["Adopt", "Trial", "Assess", "Hold"]
		@items = Items.new(data_dir)
	end

	def get_recommendations file_text, radar_date
		file_text.split("\n").map { |datum|
			line_components = datum.split(" ").map { |component|
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

	def add_recs_to_items file_text, radar_date
		get_recommendations(file_text, radar_date).map { |rec_type_hash|
			rec_type = rec_type_hash.first.first
			rec_number_and_date = rec_type_hash.values.first
			rec_numbers = rec_number_and_date.first
			rec_date = rec_number_and_date.last

			items.for_date(rec_date).map { |item|
				rec_items_with_matching_dates(item.date, rec_date, rec_numbers, item.number, item, rec_type)
			}
		}.flatten.map { |item|
			item.to_json
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
end
