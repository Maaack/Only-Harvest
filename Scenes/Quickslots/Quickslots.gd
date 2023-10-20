extends HBoxContainer


@export var quickslots_available : int = 10

var quickslot_scene = preload("res://Scenes/Quickslots/Quickslot/Quickslot.tscn")
var slot_array : Array = []

func setup_quickslots(slots:Array):
	slot_array = slots.duplicate()
	for i in range(slot_array.size()):
		var instance = quickslot_scene.instantiate()
		add_child(instance)
		instance.slot = i+1
		slot_array[i] = instance

func update_quickslots(slots:Array):
	if slot_array.size() <  slots.size():
		setup_quickslots(slots)
	for i in range(slots.size()):
		var quickslot = slot_array[i]
		if not is_instance_valid(quickslot):
			continue
		quickslot.quantity = slots[i]

func select_slot(index:int):
	if index < 0 or index >= slot_array.size():
		return
	for quickslot in slot_array:
		quickslot.selected = false
	slot_array[index].selected = true
