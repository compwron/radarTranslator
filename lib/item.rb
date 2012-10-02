class Item
  attr_reader :name, :date, :category, :number, :recommendation

  def initialize name, date, category, number
  	@name, @date, @category, @number = name, date, category, number
  end

  def to_json
  	json_item = 
    { name => { 
  				date => {
  					"category" => category,
  					"number" => number
  				}
  			}
  		}

    json_item_with_rec = 
    { name => { 
        date => {
          "category" => category,
          "number" => number,
          "recommendation" => recommendation
        }
      }
    }

    !recommendation.nil? ? json_item_with_rec : json_item
  end

  def add_rec recommendation
  	@recommendation = recommendation
  end

  def to_s
  	"#{name} #{date} #{category} #{number} #{recommendation}"
  end
end