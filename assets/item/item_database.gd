@tool
extends Resource
class_name ItemDatabase

@export
var _items: Array[Item] = []

func get_types() -> Array[StringName]:
	var types: Array[StringName] = []
	for item: Item in _items:
		if !types.has(item.type):
			types.append(item.type)
	return types

func get_type_items(type: StringName) -> Array[Item]:
	var items: Array[Item]
	for item: Item in _items:
		if item.type == type:
			items.append(item)
	return items


