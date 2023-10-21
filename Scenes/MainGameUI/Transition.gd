extends ColorRect

signal transition_finished

func close():
	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/circle_size", 0, 1)
	await(tween.finished)
	emit_signal("transition_finished")

func open():
	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/circle_size", 1.1, 1)
	await(tween.finished)
	emit_signal("transition_finished")
