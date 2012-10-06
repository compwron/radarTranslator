class Parser

attr_reader

  def date_of filename
    matcher = filename.match /(\d{4})-(\d{2})\.txt/
    Date.new(matcher[1].to_i, matcher[2].to_i, 1)
  end
end