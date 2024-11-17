@tool
extends Resource
class_name Item

enum Type { HEIGHT, THRUST, SAFETY }

@export
var type: Type = Type.HEIGHT

@export
var order: int = 0

@export
var name: StringName = &""

@export
var price_dollars: int = 0

@export
var price_cents: int = 0

@export
var icon: Texture2D = null
