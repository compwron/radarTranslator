require 'date'
p `pwd`
require_relative 'items'


class RadarDynamo
	attr_accessor :data_dir, :recommendations, :items

	def initialize data_dir
		@data_dir = data_dir
		
		@items = Items.new(data_dir)
	end


end
