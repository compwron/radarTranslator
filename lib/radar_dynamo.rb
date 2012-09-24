# assume that vanishing means staying still (i.e. if in trial and then hold, assume stays in hold)
# desired output: all data in json format. and/or report of everything that has stayed still in adopt (or x section) for x years?
require 'date'

class RadarDynamo
	attr_accessor :filenames, :data_dir, :types

	def initialize data_dir
		@data_dir = data_dir
		@filenames = []
		Dir.foreach(data_dir) { |f| @filenames += [f] }
		@filenames -= [".", ".."]
		@types = ["Languages", "Tools", "Techniques", "Platforms"]
	end

	# def get_data_from_files
	# 	lines = []
	# 	filenames.map { |f| 
	# 		File.open(data_dir + "/" + f).each_line { |line|
	# 			lines += [line] 
	# 		}
	# 		lines.join("")
	# 	}
	# end

	def get_items file_text, radar_date
		most_recent_header = ""
		file_text.split("\n").select { |item| 
			!item.nil? 
		}.map { |item| 
			most_recent_header = item if (types.include?(item)) 
			most_recent_header == item ? nil : tech_object(item_name(item), radar_date, most_recent_header)
		}.compact
	end

	def item_name item
		matcher = item.match(/\d*\. (.*)/)
		(matcher.nil? ? nil : (item.match /\d*\. (.*)/)[1] )
	end

	def tech_object item_name, radar_date, most_recent_header
		{ item_name => { 
				radar_date => {
					"category" => most_recent_header
				}
			}
		}
	end

	# def parse_file file_contents
	# 	items = file_contents.map { |file_content| file_content.split("\n") }
	# 	puts "items #{items}"
	# 	list_of_types = ["Languages", "Tools", "Techniques", "Platforms"]
		
	# 	{}
	# end

	# def data_output
	# 	{
	# 		"Python" => {
	# 			"2010-01" => {
	# 				"category" => "languages",
	# 				"recommendation" => "trial"
	# 			},
	# 			"2012-03" => {
	# 				"category" => "languages",
	# 				"recommendation" => "adopt"
	# 			}
	# 		}
	# 	}
	# end
end