class Item
  attr_reader :name, :date, :category, :number, :recommendation

  def initialize name, date, category, number, recommendation=nil
    if (name.nil? || date.nil? || category.nil? || number.nil?)
      puts "tried to create an item with nil values. name #{name} | date #{date} | category #{category} | number #{number}"
      raise
    end

    @name, @date, @category, @number, @recommendation = name, date, category, number, recommendation
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

  def matches recommendation
    @date == recommendation.date && @number == recommendation.number
  end

  def add_rec recommendation
    @recommendation = recommendation
  end

  def to_s
    "#{name} #{date} #{category} #{number} #{recommendation}"
  end

  def to_csv
    "#{name},#{date},#{category},#{number},#{recommendation}"
  end

  def == item
    name == item.name
    date == item.date
    category == item.category
    number == item.number
    recommendation == item.recommendation
  end
end