extends Node2D

# TODO: scale camera zoom with player velocity

const METER: float = 128.0
const Player: = preload("res://assets/actors/player/player.gd")
const SwingSet: = preload("res://assets/props/swing_set/swing_set.gd")

signal player_stopped()

@export
var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

@export
var player_freeze_time: float = 1.0
var _player_freeze_time: float = 0.0

@onready
var _player: Player = $player as Player
@onready
var _swing_set: SwingSet = $swing_set as SwingSet
@onready
var _camera: Camera2D = $camera_2d as Camera2D

var _camera_remote_transform: RemoteTransform2D = null

var _player_distance_max: float = 0.0
func get_player_distance_max() -> float:
	return _player_distance_max

var _player_altitude_max: float = 0.0
func get_player_altitude_max() -> float:
	return _player_altitude_max

var _player_velocity_max: float = 0.0
func get_player_velocity_max() -> float:
	return _player_velocity_max

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_player.swing = _swing_set.get_swing()
	
	_camera_remote_transform = RemoteTransform2D.new()
	_camera_remote_transform.update_position = true
	_camera_remote_transform.update_rotation = false
	_camera_remote_transform.update_scale = false
	_player.add_child(_camera_remote_transform)

var _tween_camera: Tween = null
var _tween_camera_toggle: bool = false

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _player.is_swinging():
		_tween_camera_toggle = false
		
		var camera_zoom: float = clampf(remap(_swing_set.get_swing().length, 256.0, 1024.0, 0.5, 0.25), 0.125, 0.5)
		_camera.zoom = Vector2(camera_zoom, camera_zoom)
	else:
		_camera_remote_transform.remote_path = _camera_remote_transform.get_path_to(_camera)
		if !_tween_camera_toggle:
			_tween_camera_toggle = true
			
			_tween_camera = create_tween()
			_tween_camera.set_parallel(true)
			_tween_camera.set_ease(Tween.EASE_IN_OUT)
			_tween_camera.tween_property(_camera, "zoom", Vector2(0.5, 0.5), 2.0)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var player_distance: float = _player.global_position.x / METER
	var player_altitude: float = -_player.global_position.y / METER
	var player_velocity: float = _player.linear_velocity.length() / METER
	
	_player_distance_max = maxf(_player_distance_max, player_distance)
	_player_velocity_max = maxf(_player_velocity_max, player_velocity)
	_player_altitude_max = maxf(_player_altitude_max, player_altitude)
	
	if _player.is_swinging():
		_player_freeze_time = 0.0
	elif player_velocity < 1.0:
		if _player_freeze_time < player_freeze_time:
			_player_freeze_time += delta
			if _player_freeze_time >= player_freeze_time:
				player_stopped.emit()
	else:
		_player_freeze_time = 0.0
	
