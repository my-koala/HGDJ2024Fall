extends Node2D

const Player: = preload("res://assets/actors/player/player.gd")
const SwingSet: = preload("res://assets/props/swing_set/swing_set.gd")

@onready
var _player: Player = $player as Player
@onready
var _swing_set: SwingSet = $swing_set as SwingSet
@onready
var _camera: Camera2D = $camera_2d as Camera2D
@onready
var _info: Label = $canvas_layer/info as Label

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_player.swing = _swing_set.get_swing()

var _player_position: Vector2 = Vector2.ZERO
var _player_velocity: float = 0.0

@export
var player_freeze_time: float = 1.0
var _player_freeze_time: float = 0.0
var _player_freeze_threshold: float = 0.05

var _player_altitude_max: float = 0.0

func _physics_process(delta: float) -> void:
	var player_position: Vector2 = _player.global_position
	var player_distance: float = _player.global_position.x
	var player_altitude: float = -_player.global_position.y
	var player_velocity: float = player_position.distance_to(_player_position) / delta
	
	_player_altitude_max = maxf(player_altitude, _player_altitude_max)
	_info.text = "Distance: %.0f\nAltitude: %.0f\nMax Altitude: %.0f\nVelocity: %.0f\nAcceleration: %.0f\n" % [player_distance, player_altitude, _player_altitude_max, player_velocity, player_velocity - _player_velocity]
	
	if _player.is_swinging():
		_player_freeze_time = 0.0
	else:
		if _player_position.distance_squared_to(player_position) <= _player_freeze_threshold ** 2.0:
			_player_freeze_time += delta
		else:
			_player_freeze_time = 0.0
	
	_camera.global_position = _player.global_position
	
	if _player_freeze_time > player_freeze_time:
		get_tree().reload_current_scene()
	
	_player_position = player_position
	_player_velocity = player_velocity
