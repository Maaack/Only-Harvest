extends Node

@export var quickslots_available : int = 10
var slot_array = []
var selected_slot = 0

func _ready():
	var quickslot_range = range(quickslots_available)
	slot_array = quickslot_range.duplicate()
	for i in quickslot_range:
		slot_array[i] = null

func get_next_empty_index():
	for i in range(slot_array.size()):
		if slot_array[i] == null:
			return i

func find(name_query:String):
	for quantity in slot_array:
		if is_instance_valid(quantity) and quantity is BaseQuantity:
			if quantity.name == name_query:
				return quantity

func get_slot_quantity_by_mod_id(slot_id : int):
	while slot_id < 0:
		slot_id += slot_array.size()
	slot_id %= slot_array.size()
	return slot_array[slot_id]

func get_next_slot_by_taxonomy(taxonomy_query : String):
	for iter in slot_array.size():
		var check_slot : int = selected_slot + (iter + 1)
		var quantity = get_slot_quantity_by_mod_id(check_slot)
		if is_instance_valid(quantity) and quantity is BaseQuantity:
			if quantity.taxonomy == taxonomy_query:
				return check_slot

func get_prev_slot_by_taxonomy(taxonomy_query : String):
	for iter in slot_array.size():
		var check_slot : int = selected_slot - (iter + 1)
		var quantity = get_slot_quantity_by_mod_id(check_slot)
		if is_instance_valid(quantity) and quantity is BaseQuantity:
			if quantity.taxonomy == taxonomy_query:
				if check_slot < 0:
					check_slot += slot_array.size()
				return check_slot

func add_quantity(quantity:BaseQuantity):
	if quantity == null:
		return
	var found_quantity = find(quantity.name)
	if is_instance_valid(found_quantity):
		return
	var index = get_next_empty_index()
	if index == null:
		return
	slot_array[index] = quantity

func select_slot(value:int):
	if value < 0 or value >= slot_array.size():
		return
	selected_slot = value

func get_selected_quantity():
	return slot_array[selected_slot]
