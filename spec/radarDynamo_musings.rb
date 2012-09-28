{ "Adopt"=>
	[["1"], date]
}

{ "Ruby"=>
	{ date =>
		{
			"category"=>"Languages", 
			"number"=>"1"
		}
	}
}

for each recommendation type
	for each date set of recommendations
		rec_date = rec_date
		rec_numbers = rec_number
		items_for_date(rec_date).each
			items.values.each |hash_with_item_date_as_key|
				if hash_with_item_date_as_key.keys.first == rec_date
					rec_numbers.each |rec_number|
					if hash_with_item_date_as_key.values.includes rec_numbers
						add recommendation value to item

