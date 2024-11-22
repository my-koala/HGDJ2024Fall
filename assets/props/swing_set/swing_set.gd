@tool
extends Node2D

const ITEM_HEIGHT: Array[Item] = [
	preload("res://assets/item/items/item_height_0.tres"),
	preload("res://assets/item/items/item_height_1.tres"),
	preload("res://assets/item/items/item_height_2.tres"),
	preload("res://assets/item/items/item_height_3.tres"),
]

const ITEM_THRUST: Array[Item] = [
	preload("res://assets/item/items/item_thrust_0.tres"),
	preload("res://assets/item/items/item_thrust_1.tres"),
	preload("res://assets/item/items/item_thrust_2.tres"),
	preload("res://assets/item/items/item_thrust_3.tres"),
]

@export
var game_data: GameData = preload("res://assets/game_data/game_data.tres")

@onready
var _top: Node2D = $top as Node2D
@onready
var _swing: Swing2D = $top/swing as Swing2D
@onready
var _catenary: Catenary2D = $top/catenary as Catenary2D

@onready
var _thruster_a: SwingThruster2D = $top/swing/swing_set_thruster_a as SwingThruster2D
@onready
var _thruster_b: SwingThruster2D = $top/swing/swing_set_thruster_b as SwingThruster2D
@onready
var _thruster_c: SwingThruster2D = $top/swing/swing_set_thruster_c as SwingThruster2D

func get_swing() -> Swing2D:
	return _swing

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if game_data.is_item_equipped(ITEM_HEIGHT[0]):
		set_height(256.0)
	elif game_data.is_item_equipped(ITEM_HEIGHT[1]):
		set_height(386.0)
	elif game_data.is_item_equipped(ITEM_HEIGHT[2]):
		set_height(512.0)
	elif game_data.is_item_equipped(ITEM_HEIGHT[3]):
		set_height(1024.0)
	else:
		set_height(256.0)
	
	if game_data.is_item_equipped(ITEM_THRUST[0]):
		_thruster_a.visible = false
		_thruster_b.visible = false
		_thruster_c.visible = false
		
		_swing.remove_swing_thruster(_thruster_a)
		_swing.remove_swing_thruster(_thruster_b)
		_swing.remove_swing_thruster(_thruster_c)
	elif game_data.is_item_equipped(ITEM_THRUST[1]):
		_thruster_a.visible = true
		_thruster_b.visible = false
		_thruster_c.visible = false
		
		_swing.add_swing_thruster(_thruster_a)
		_swing.remove_swing_thruster(_thruster_b)
		_swing.remove_swing_thruster(_thruster_c)
	elif game_data.is_item_equipped(ITEM_THRUST[2]):
		_thruster_a.visible = false
		_thruster_b.visible = true
		_thruster_c.visible = false
		
		_swing.remove_swing_thruster(_thruster_a)
		_swing.add_swing_thruster(_thruster_b)
		_swing.remove_swing_thruster(_thruster_c)
	elif game_data.is_item_equipped(ITEM_THRUST[3]):
		_thruster_a.visible = false
		_thruster_b.visible = false
		_thruster_c.visible = true
		
		_swing.remove_swing_thruster(_thruster_a)
		_swing.remove_swing_thruster(_thruster_b)
		_swing.add_swing_thruster(_thruster_c)

func set_height(height: float) -> void:
	height = maxf(height, 0.0)
	_top.position = Vector2(0.0, -height)
	_swing.length = height - 24.0
	_swing.set_anchor_position(_top.global_position)
	_catenary.length = _swing.length
	_catenary.end_position = _swing.global_position - _catenary.global_position

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_catenary.length = _swing.length
	_catenary.end_position = _swing.global_position - _catenary.global_position

# swing upgrades:

# swing length
# - modifies sprite frame, top position, 
# swing material
# swing thruster
