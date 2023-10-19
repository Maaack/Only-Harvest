extends Node

@export var days_passed : int = 7
@export var earnings : Array :
	set(value):
		earnings = value
		for quantity in earnings:
			match(quantity.name):
				"Credit":
					credits += quantity.quantity
				"Dark Crypto":
					cryptos += quantity.quantity

var credits : int
var cryptos : int

func _display_time_passed():
	%TimePassed.text = "After %d days you earned:" % days_passed

func _display_earnings():
	var earnings_string = ""
	if credits > 0:
		earnings_string += "%d Citizen Credits\n" % credits
	if cryptos > 0:
		earnings_string += "%d Darko Cryptos\n" % cryptos
	if credits == 0 and cryptos == 0:
		earnings_string = "Nothing"
	%Earnings.text = earnings_string

func _display_reward():
	if credits < 100 and cryptos < 100:
		%Meaning.text = "You lose the family farm!\nWhat you have left is not much to go on."
	elif credits >= 100 and cryptos < 100:
		%Meaning.text = "You pay mortgage and keep your family farm!\nFor this week."
	elif credits < 100 and cryptos >= 100:
		%Meaning.text = "You lose the farm, but you are a king among thieves.\nStill homeless though."
	elif credits > 100 and cryptos >= 100:
		%Meaning.text = "You keep your family farm,\nand have earned \"honor\" among thieves."
		

func refresh_text():
	_display_time_passed()
	_display_earnings()
	_display_reward()
