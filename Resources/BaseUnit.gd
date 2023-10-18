extends Resource
class_name BaseUnit

@export var name : String
@export var icon : Texture
@export var taxonomy : String

enum NumericalUnitSetting{ DISCRETE, CONTINUOUS }
@export var numerical_unit : NumericalUnitSetting = NumericalUnitSetting.DISCRETE

func _to_string():
	return "%s (%d)" % [name, get_instance_id()]

func copy_from(value:BaseUnit):
	if value == null:
		return
	name = value.name
	icon = value.icon
	taxonomy = value.taxonomy
