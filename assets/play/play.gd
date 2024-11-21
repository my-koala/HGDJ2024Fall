extends Node2D

const Player: = preload("res://assets/actors/player/player.gd")
const SwingSet: = preload("res://assets/props/swing_set/swing_set.gd")

signal exit()

@export
var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

@onready
var _map: Node2D = $map as Node2D
@onready
var _player: Player = $world/player as Player
@onready
var _swing_set: SwingSet = $world/swing_set as SwingSet
@onready
var _camera: Camera2D = $world/camera_2d as Camera2D
@onready
var _info: Label = $gui/info as Label
@onready
var _slider_thrust: HSlider = $gui/controls/slider_thrust as HSlider

@onready
var _results_overlay: ColorRect = $gui/results_overlay as ColorRect
@onready
var _results_container: Control = $gui/results_container as Control
@onready
var _results_stats_left: Label = $gui/results_container/panel/content/stats_left as Label
@onready
var _results_stats_middle: Label = $gui/results_container/panel/content/stats_middle as Label
@onready
var _results_stats_right: Label = $gui/results_container/panel/content/stats_right as Label
@onready
var _results_total_left: Label = $gui/results_container/panel/content/panel/total_left as Label
@onready
var _results_total_right: Label = $gui/results_container/panel/content/panel/total_right as Label
@onready
var _results_continue: Button = $gui/results_container/panel/continue as Button

var _camera_remote_transform: RemoteTransform2D = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_player.swing = _swing_set.get_swing()
	
	_camera_remote_transform = RemoteTransform2D.new()
	_camera_remote_transform.update_position = true
	_camera_remote_transform.update_rotation = false
	_camera_remote_transform.update_scale = false
	_player.add_child(_camera_remote_transform)
	
	_results_container.visible = false
	_results_container.position.y = _results_container.size.y
	_results_overlay.visible = false
	_results_overlay.modulate.a = 0.0
	
	_results_continue.pressed.connect(_on_results_continue_pressed)

@export
var player_freeze_time: float = 1.0
var _player_freeze_time: float = 0.0

var _player_velocity_max: float = 0.0
var _player_altitude_max: float = 0.0

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
	
	if _attempt_stopped:
		return
	
	var player_distance: float = _player.global_position.x / 128.0
	var player_altitude: float = -_player.global_position.y / 128.0
	var player_velocity: float = _player.linear_velocity.length() / 128.0
	
	_player_velocity_max = maxf(_player_velocity_max, player_velocity)
	_player_altitude_max = maxf(_player_altitude_max, player_altitude)
	
	if _player.is_swinging():
		_player_freeze_time = 0.0
	else:
		if player_velocity < 1.0:
			_player_freeze_time += delta
		else:
			_player_freeze_time = 0.0
	
	_player.get_node_or_null("swing_thruster_2d").set(&"thrust", _slider_thrust.value)
	
	if _player_freeze_time > player_freeze_time:
		_attempt_stop(maxf(player_distance, 0.0), _player_altitude_max, _player_velocity_max)

func _on_results_continue_pressed() -> void:
	exit.emit()

var _results_tween: Tween = null
var _attempt_stopped: bool = false
func _attempt_stop(distance: float, altitude: float, velocity: float) -> void:
	_attempt_stopped = true
	
	_results_continue.grab_focus.call_deferred()
	_map.process_mode = Node.PROCESS_MODE_DISABLED
	_results_overlay.visible = true
	_results_overlay.modulate.a = 0.0
	_results_container.visible = true
	_results_tween = create_tween()
	_results_tween.set_parallel(true)
	_results_tween.set_ease(Tween.EASE_IN_OUT)
	_results_tween.set_trans(Tween.TRANS_CUBIC)
	_results_tween.tween_property(_results_overlay, "modulate:a", 1.0, 0.5)
	_results_tween.tween_property(_results_container, "position:y", 0.0, 0.5)
	
	var money_distance_dollars: int = floori(absf(distance) * 0.08)
	var money_distance_cents: int = floori(100.0 * absf(distance) * 0.08) % 100
	var money_altitude_dollars: int = floori(absf(altitude) * 0.03)
	var money_altitude_cents: int = floori(100.0 * absf(altitude) * 0.03) % 100
	var money_velocity_dollars: int = floori(absf(altitude) * 0.04)
	var money_velocity_cents: int = floori(100.0 * absf(altitude) * 0.04) % 100
	var money_injuries_dollars: int = 0
	var money_injuries_cents: int = 0
	var money_total_dollars: int = money_distance_dollars + money_altitude_dollars + money_velocity_dollars - money_injuries_dollars
	var money_total_cents: int = money_distance_cents + money_altitude_cents + money_velocity_cents - money_injuries_cents
	
	_game_data.money_deposit(money_total_dollars, money_total_cents)
	
	_results_stats_middle.text = "%.2f meters\n%.2f meters\n%.2f meters/second\n%s\n" % [distance, altitude, velocity, "Nothing Hurts"]
	_results_stats_right.text = "+$%d.%02d\n+$%d.%02d\n+$%d.%02d\n-$%d.%02d\n+$%d.%02d\n" % [money_distance_dollars, money_distance_cents, money_altitude_dollars, money_altitude_cents, money_velocity_dollars, money_velocity_cents, money_injuries_dollars, money_injuries_cents, 0, 0]
	_results_total_right.text = "$%d.%02d" % [money_total_dollars, money_total_cents]
	
