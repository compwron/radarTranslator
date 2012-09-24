# assume that vanishing means staying still (i.e. if in trial and then hold, assume stays in hold)
# desired output: all data in json format. and/or report of everything that has stayed still in adopt (or x section) for x years?
require 'date'

class RadarDynamo
	attr_accessor :filenames, :data_dir

	def initialize data_dir
		@data_dir = data_dir
		@filenames = []
		Dir.foreach(data_dir) { |f| @filenames += [f] }
		@filenames -= [".", ".."]
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
		items = file_text.split("\n")
		list_of_types = ["Languages", "Tools", "Techniques", "Platforms"]

		most_recent_header = ""
		items.map { |item| 
		most_recent_header = item if (list_of_types.include?(item)) 
		made_object = { 
								 		item.split(" ").last => { 
								 			radar_date => {
								 				"category" => most_recent_header
								 						}

								 				}
								 }
		 most_recent_header != item ? made_object : nil
		 		
		 }

		 # items.map { |string_item|
		 # 		if list_of_types.include?(string_item) 
		 # 			most_recent_header = string_item
		 # 		puts "most recent header #{most_recent_header}"
		 # 		1
		 # }
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