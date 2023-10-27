extends Node

const CREDITS_GOAL = 100
const CRYPTOS_GOAL = 1000

@export_file("*.tscn") var main_menu_path : String
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
	var reward_text : String
	if credits == 0 and cryptos == 0:
		reward_text = "At the end of the week, you are completely broke. You reject the burdens of the past as well as the concerns of the future.\nYou live in the present!\n-and when someone opens that present and freaks out, you'll probably have to live elsewhere, but that's a future you problem. You live free in the now!"
	elif credits < CREDITS_GOAL / 2 and cryptos < CRYPTOS_GOAL / 2:
		reward_text = "It was just too hard to choose.\nThe house, the dream, neither. The third wasn't a stated goal, but this is your life, and you make it of what you want! Where two doors close, a window opens. In your mind!\nBeing broke is pretty lame though, and pretty soon you open your mind to regular employment."
	elif credits < CREDITS_GOAL and cryptos < CRYPTOS_GOAL / 2:
		reward_text = "You tried to pay off the mortgage, but you didn't have enough. While trying to negotiate a payment plan, the bank got robbed, and bank notes discretely landed in your lap.\nBeing the honest fellow you are, you returned them to the bank the next day, and they considered the mortgage payment made!\nThe same streak of luck gets you through next week, too."
	elif credits < CREDITS_GOAL / 2 and cryptos < CRYPTOS_GOAL:
		reward_text = "After a week, the bank repossessed the farm. No one wanted to let you crash on their couch either. It was ultra lame. So you left.\nYour Darko Cryptos eventually spiked in value, but so did your ambitions. Aiming for the moon, your eyes set on a new goal.\nTo harvest moon... dust."
	elif credits >= CREDITS_GOAL and cryptos < CRYPTOS_GOAL:
		reward_text = "You make the payment and keep the family farm! And with that, you preserve your family's past.\nFor this week... then the next... and the next...\nEventually, you pay off the mortgage. With your extra money, you buy the neighbors property. Now you have another mortgage, but a less annoying neighbor, and life is better."
	elif credits < CREDITS_GOAL and cryptos >= CRYPTOS_GOAL:
		reward_text = "You invest in your own future and leave the past behind. You lose the family farm, but you gain... the gains!\nYou harvest those gains to feed your data-mining venture. Weeks later, you get hacked and all the data is leaked. You decide you like harvesting gains more anyway. \nYou eventually buy a small Orwellian country... in cyberspace."
	elif credits > CREDITS_GOAL and cryptos >= CRYPTOS_GOAL:
		reward_text = "You beat the odds! You saved your family's past and secured your own future. You live to pursue your passion!\nAt your farm you harvest crops.\nAt your company you harvest data.\nAt the currency exchange you harvest gains.\nWhen you die, the reaper even let's you harvest your own soul."
	%Meaning.text = reward_text

func refresh_text():
	_display_time_passed()
	_display_earnings()
	_display_reward()
	if not main_menu_path.is_empty():
		%MainMenuButton.show()

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	SceneLoader.load_scene(main_menu_path)
