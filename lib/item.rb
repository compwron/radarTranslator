class Item
  attr_reader :name, :date, :category, :number, :recommendation

  def initialize name, date, category, number
  	@name, @date, @category, @number = name, date, category, number
  end

  def to_json
  	{ name => { 
  				date => {
  					"category" => category,
  					"number" => number,
  					"recommendation" => recommendation
  				}
  			}
  		}
  end

  def add_rec recommendation
  	@recommendation = recommendation
  end

  def to_s
  	"#{name} #{date} #{category} #{number} #{recommendation}"
  end
end