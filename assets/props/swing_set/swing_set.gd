@tool
extends Node2D

var game_data: GameData = preload("res://assets/game_data/game_data.tres")

@onready
var _swing: Swing2D = $swing as Swing2D
@onready
var _swing_top: Node2D = $swing_top as Node2D
@onready
var _catenary_temp: Catenary2D = $swing_top/catenary_temp as Catenary2D

func get_swing() -> Swing2D:
	return _swing

func _init() -> void:
	if Engine.is_editor_hint():
		return
	
	

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	match game_data.swing_length:
		GameData.SwingLength.A:
			const HEIGHT: float = 256.0
			_swing_top.position = Vector2(0.0, -HEIGHT)
			_swing.length = _swing.global_position.distance_to(_swing_top.global_position)
			_swing.set_anchor_position()
			_catenary_temp.length = _swing.length
			_catenary_temp.end_position = _swing.global_position - _catenary_temp.global_position
		GameData.SwingLength.B:
			pass
		GameData.SwingLength.C:
			pass
		GameData.SwingLength.D:
			pass
	
	match game_data.swing_tether:
		GameData.SwingTether.A:
			pass
		GameData.SwingTether.B:
			pass
		GameData.SwingTether.C:
			pass
		GameData.SwingTether.D:
			pass
	
	match game_data.swing_thrust:
		GameData.SwingThrust.A:
			pass
		GameData.SwingThrust.B:
			pass
		GameData.SwingThrust.C:
			pass
		GameData.SwingThrust.D:
			pass
	

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_catenary_temp.length = _swing.length
	_catenary_temp.end_position = _swing.global_position - _catenary_temp.global_position

# swing upgrades:

# swing length
# - modifies sprite frame, top position, 
# swing material
# swing thruster
