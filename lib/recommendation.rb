class Recommendation
	attr_reader :number, :rec, :date

  def initialize number, rec, date
    @number, @rec, @date = number, rec, date
  end

  def to_s
  	"#{rec} #{date} #{number}"
  end

  def <=> other
  	number == other.number
  	rec == other.rec
  	date == other.date
  end
end