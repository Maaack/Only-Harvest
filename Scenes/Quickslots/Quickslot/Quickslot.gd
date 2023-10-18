extends Control


@onready var inventory_slot_node = $InventorySlot
@onready var selected_node = $Selected
@onready var label_node = $Label

@export var slot : int :
	set = set_slot
@export var quantity : BaseQuantity :
	set = set_quantity
@export var selected : bool :
	set = set_selected

func set_slot(value:int):
	slot = value
	if is_instance_valid(label_node):
		label_node.text = str(slot)

func set_quantity(value:BaseQuantity):
	quantity = value
	if is_instance_valid(inventory_slot_node):
		inventory_slot_node.quantity = quantity

func set_selected(value:bool):
	selected = value
	if is_instance_valid(selected_node):
		selected_node.visible = selected
