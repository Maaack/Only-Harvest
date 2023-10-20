extends Area2D
class_name DialogueTrigger

signal dialogue_triggered(title)

@export var dialogue_title : String
@export_enum("Instant", "Action") var trigger_mode : int = 0
@export_enum("Single", "Multiple") var trigger_count : int = 0

var interactions = 0

func start_dialogue():
	if interactions > 0 and trigger_count == 0:
		return
	emit_signal("dialogue_triggered", dialogue_title)
	interactions += 1

func _on_body_entered(body):
	if body is PlayerCharacter:
		if trigger_mode == 0:
			start_dialogue()
		else:
			body.offer_dialogue(self)

func _on_body_exited(body):
	if body is PlayerCharacter:
		if trigger_mode != 0:
			body.revoke_dialogue()