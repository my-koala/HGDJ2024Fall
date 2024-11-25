extends Node2D

# TODO: scale camera zoom with player velocity

const METER: float = 64.0
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

@onready
var _sound_suburbs: AudioStreamPlayer = $sounds/suburbs as AudioStreamPlayer

var _camera_remote_transform: RemoteTransform2D = null

func get_player_distance() -> float:
	return _player.global_position.x / METER

func get_player_altitude() -> float:
	return -_player.global_position.y / METER

func get_player_velocity() -> float:
	return _player.linear_velocity.length() / METER

var _player_distance_max: float = 0.0
func get_player_distance_max() -> float:
	return _player_distance_max

var _player_altitude_max: float = 0.0
func get_player_altitude_max() -> float:
	return _player_altitude_max

var _player_velocity_max: float = 0.0
func get_player_velocity_max() -> float:
	return _player_velocity_max

func get_player_injury() -> Player.Injury:
	return _player.get_injury()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_player.swing = _swing_set.get_swing()
	
	_camera_remote_transform = RemoteTransform2D.new()
	_camera_remote_transform.update_position = true
	_camera_remote_transform.update_rotation = false
	_camera_remote_transform.update_scale = false
	_player.add_child(_camera_remote_transform)
	
	_player.exploded.connect(_on_player_exploded)
	
	_sound_suburbs.play()

var _camera_shake: float = 0.0
func _on_player_exploded() -> void:
	_camera_shake = 1.0

var _tween_camera: Tween = null
var _tween_camera_toggle: bool = false

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_camera.offset = Vector2(randf_range(-_camera_shake * 24.0, _camera_shake * 24.0), randf_range(-_camera_shake * 24.0, _camera_shake * 24.0))
	_camera_shake = lerpf(_camera_shake, 0.0, 3.0 * delta)
	
	_sound_suburbs.volume_db = clampf(remap(-_camera.global_position.y, 2000.0, 4000.0, -16.0, -80.0), -80.0, -16.0)
	
	if _player.is_swinging():
		_tween_camera_toggle = false
		
		var x: float = remap(_swing_set.get_height(), 0.0, 2048.0, 0.0, 1.0)
		var zoom: float = (-5.10476 * (x ** 3.0)) + (9.8 * (x ** 2.0)) - (5.91167 * x) + 1.34643
		_camera.zoom = Vector2(zoom, zoom)
	else:
		_camera_remote_transform.remote_path = _camera_remote_transform.get_path_to(_camera)
		var zoom: float = clampf(remap(_player.linear_velocity.length(), 1000.0, 10000.0, 0.75, 0.25), 0.25, 0.75)
		#var zoom_lerp: float = 
		_camera.zoom = _camera.zoom.move_toward(Vector2(zoom, zoom), 0.375 * delta)
		#_camera.zoom = Vector2(0.125, 0.125)
		#if !_tween_camera_toggle:
			#_tween_camera_toggle = true
			#
			#_tween_camera = create_tween()
			#_tween_camera.set_parallel(true)
			#_tween_camera.set_ease(Tween.EASE_IN_OUT)
			#var zoom: float = remap(_player.linear_velocity.length(), 0.0, 100.0, 0.75, 0.125)
			#_tween_camera.tween_property(_camera, "zoom", Vector2(zoom, zoom), 2.0)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _player.is_swinging():
		return
	
	var player_distance: float = get_player_distance()
	var player_altitude: float = get_player_altitude()
	var player_velocity: float = get_player_velocity()
	
	_player_distance_max = maxf(_player_distance_max, player_distance)
	_player_velocity_max = maxf(_player_velocity_max, player_velocity)
	_player_altitude_max = maxf(_player_altitude_max, player_altitude)
	
	if player_velocity < 0.5 && absf(_player.angular_velocity) < 0.5:
		if _player_freeze_time < player_freeze_time:
			_player_freeze_time += delta
			if _player_freeze_time >= player_freeze_time:
				player_stopped.emit()
	else:
		_player_freeze_time = 0.0
	
