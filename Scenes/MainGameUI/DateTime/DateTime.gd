extends HBoxContainer

func set_day(day : int):
	pass
	$Day.text = "Day %d" % (day + 1)

func set_hour(hour : int):
	$Time.text = "%02d:00" % hour
