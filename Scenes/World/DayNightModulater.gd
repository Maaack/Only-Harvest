extends CanvasModulate

@export var day_length : int = 24
@export var source_color: Color = Color.WHITE
@export var target_color: Color = Color.DARK_SLATE_BLUE
@export var enabled : bool = false

var _time : int = 0

func increment_time(time_increment : int) -> void:
	if not enabled:
		return
	var value : float
	_time += time_increment 
	value = 1 - clamp((cos(float(_time) * PI / float(day_length * 0.5)) + 0.5), 0, 1)
	color = source_color.lerp(target_color, value)

func reset_time() -> void:
	_time = 0
