class Recommendation
	attr_reader :number, :name, :date

  def initialize number, name, date
    @number, @name, @date = number, name, date
  end

  def to_s
  	"#{name} #{date} #{number}"
  end

  def == other
  	number == other.number
  	name == other.name
  	date == other.date
  end
end