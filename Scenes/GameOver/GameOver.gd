extends Node

const CREDITS_GOAL = 100
const CRYPTOS_GOAL = 1000

@export var days_passed : int = 7
@export var earnings : Array :
	set(value):
		earnings = value
		for quantity in earnings:
			match(quantity.name):
				Constants.CREDIT_NAME:
					credits += quantity.quantity
				Constants.CRYPTO_NAME:
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
	if credits < CREDITS_GOAL and cryptos < CRYPTOS_GOAL:
		%Meaning.text = "You lose the family farm!\nWhat you have left is not much to go on."
	elif credits >= CREDITS_GOAL and cryptos < CRYPTOS_GOAL:
		%Meaning.text = "You pay the mortgage and keep the family farm!\nFor this week."
	elif credits < CREDITS_GOAL and cryptos >= CRYPTOS_GOAL:
		%Meaning.text = "You successfully start your data mining enterprise!\nYou live in the office."
	elif credits > CREDITS_GOAL and cryptos >= CRYPTOS_GOAL:
		%Meaning.text = "You keep your family farm,\nand start your enterprise!\nWay to show the world!"
		

func refresh_text():
	_display_time_passed()
	_display_earnings()
	_display_reward()
