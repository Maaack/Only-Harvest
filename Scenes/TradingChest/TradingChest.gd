extends Node2D


func _on_area_2d_body_entered(body):
	if body is PlayerCharacter:
		$AnimationPlayer.play("Opening")


func _on_area_2d_body_exited(body):
	if body is PlayerCharacter:
		$AnimationPlayer.play_backwards("Opening")
