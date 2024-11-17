@tool
extends Node2D

var game_data: GameData = preload("res://assets/game_data/game_data.tres")

@onready
var _top: Node2D = $top as Node2D
@onready
var _swing: Swing2D = $top/swing as Swing2D
@onready
var _catenary: Catenary2D = $top/catenary as Catenary2D

func get_swing() -> Swing2D:
	return _swing

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	set_height(1024.0)

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
