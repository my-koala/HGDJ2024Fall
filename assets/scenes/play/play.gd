@tool
extends Node2D

# all configuration needs to be done through game data
# complete "reload" functionality without reinstantiating is too much work
# 

const MAP: PackedScene = preload("res://assets/map/map.tscn")
const Map: = preload("res://assets/map/map.gd")

signal exit()

@export
var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

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

var _map: Map = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_results_container.visible = false
	_results_container.position.y = _results_container.size.y
	_results_overlay.visible = false
	_results_overlay.modulate.a = 0.0
	_results_continue.release_focus()
	
	_results_continue.pressed.connect(_on_results_continue_pressed)

func _on_results_continue_pressed() -> void:
	exit.emit()

var _scene_active: bool = false
func scene_start() -> void:
	_scene_active = true
	if !is_instance_valid(_map):
		_map = MAP.instantiate() as Map
		add_child(_map, true)
		_map.player_stopped.connect(_on_map_player_stopped)

func scene_stop() -> void:
	_scene_active = false
	if is_instance_valid(_map):
		_map.player_stopped.disconnect(_on_map_player_stopped)
		remove_child(_map)
		_map.queue_free()
	
	_results_container.visible = false
	_results_container.position.y = _results_container.size.y
	_results_overlay.visible = false
	_results_overlay.modulate.a = 0.0
	_results_continue.release_focus.call_deferred()

var _results_tween: Tween = null
var _attempt_stopped: bool = false
func _on_map_player_stopped() -> void:
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
	
	var distance: float = _map.get_player_distance_max()
	var altitude: float = _map.get_player_altitude_max()
	var velocity: float = _map.get_player_velocity_max()
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
	money_total_dollars += money_total_cents / 100
	money_total_cents = money_total_cents % 100
	
	_game_data.money_deposit(money_total_dollars, money_total_cents)
	
	_results_stats_middle.text = "%.2f meters\n%.2f meters\n%.2f meters/second\n%s\n" % [distance, altitude, velocity, "Nothing Hurts"]
	_results_stats_right.text = "+$%d.%02d\n+$%d.%02d\n+$%d.%02d\n-$%d.%02d\n+$%d.%02d\n" % [money_distance_dollars, money_distance_cents, money_altitude_dollars, money_altitude_cents, money_velocity_dollars, money_velocity_cents, money_injuries_dollars, money_injuries_cents, 0, 0]
	_results_total_right.text = "$%d.%02d" % [money_total_dollars, money_total_cents]
	