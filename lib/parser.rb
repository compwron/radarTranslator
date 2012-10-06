class Parser

attr_reader

  def date_of filename
    matcher = filename.match /(\d{4})-(\d{2})\.txt/
    Date.new(matcher[1].to_i, matcher[2].to_i, 1)
  end

  def item_number datum
    regex = /(\d*)\..*/
    matcher = datum.match(regex)
    (matcher.nil? ? nil : (datum.match regex)[1] )
  end

  def item_name datum
    regex = /\d*\. (.*)/
    matcher = datum.match(regex)
    (matcher.nil? ? nil : (datum.match regex)[1] )
  end
end