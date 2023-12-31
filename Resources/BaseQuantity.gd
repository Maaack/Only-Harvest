extends BaseUnit
class_name BaseQuantity

@export var quantity = 1.0 :
	set = set_quantity

func _to_string():
	return "%s, %f" % [super._to_string(), quantity]

func set_quantity(value:float):
	quantity = _discrete_unit_check(value)

func _discrete_unit_check(new_quantity : float):
	if new_quantity != null && numerical_unit == NumericalUnitSetting.DISCRETE:
		var lt_zero = new_quantity < 0
		new_quantity = floor(abs(new_quantity))
		if lt_zero:
			new_quantity *= -1
	return new_quantity

func add_quantity(value:float):
	if value == null or value == 0.0:
		return
	quantity += _discrete_unit_check(value)

func split(value:float) -> BaseQuantity:
	if quantity <= 0 or value <= 0:
		print("Error: Splitting only supports positive quantities.")
	var split_quantity = duplicate()
	if value == null or value == 0.0:
		split_quantity.quantity = 0
		return split_quantity
	value = min(value, quantity)
	add_quantity(-value)
	split_quantity.quantity = value
	return split_quantity

func copy_from(value:BaseUnit):
	if value == null:
		return
	if value.has_method('set_quantity'):
		quantity = value.quantity
	super.copy_from(value)

func add(value, conserve_quantities:bool=true):
	if not is_instance_valid(value):
		return
	if not value.has_method('set_quantity'):
		print("Error: Adding incompatible types ", str(value), " and ", str(self))
		return
	if value.name != name:
		print("Error: Adding incompatible quantities ", str(value), " and ", str(self))
		return
	add_quantity(value.quantity)
	if conserve_quantities:
		value.quantity = 0

