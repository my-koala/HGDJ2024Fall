@tool
extends Node2D

# all configuration needs to be done through game data
# complete "reload" functionality without reinstantiating is too much work
# 

const MAP: PackedScene = preload("res://assets/map/map.tscn")
const Map: = preload("res://assets/map/map.gd")
const Player: = preload("res://assets/actors/player/player.gd")

signal exit()

@export
var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

@onready
var _gui: CanvasLayer = $gui as CanvasLayer

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

@onready
var _altimeter_player: TextureRect = $gui/altimeter/nine_patch_rect/player as TextureRect

@onready
var _info: Label = $gui/info as Label

var _map: Map = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_gui.visible = false
	
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
	
	_attempt_stopped = false
	_gui.visible = true

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if !_attempt_stopped && is_instance_valid(_map):
		_info.text = "Attempt #%d\nDistance: %.2f" % [_game_data.get_attempt(), _map.get_player_distance()]
		# hacky hacky need to done!
		_altimeter_player.position.y = clampf(remap(_map.get_player_altitude(), 0.0, 2000.0, 167.0, -55.0), -55.0, 167.0)
		# TODO: update altitude display

func scene_stop() -> void:
	_scene_active = false
	
	if is_instance_valid(_map):
		_map.player_stopped.disconnect(_on_map_player_stopped)
		remove_child(_map)
		_map.queue_free()
	
	_attempt_stopped = false
	_gui.visible = false
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
	
	var money_distance_cents: int = floori(absf(distance) * 8.0)
	var money_altitude_cents: int = floori(absf(altitude) * 7.0)
	var money_velocity_cents: int = floori(absf(velocity) * 4.0)
	
	var money_total_cents: int = money_distance_cents + money_altitude_cents + money_velocity_cents
	
	var money_injury_penalty: float = 0.0
	var injuries: String = "Nothing Hurts"
	match _map.get_player_injury():
		Player.Injury.NONE:
			money_injury_penalty = 0.0
			injuries = "Nothing Hurts (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.SPRAINED_ANKLES:
			money_injury_penalty = 0.1
			injuries = "Sprained Ankles (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.BROKEN_RIBS:
			money_injury_penalty = 0.3
			injuries = "Broken Ribs (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.SLIPPED_DISK:
			money_injury_penalty = 0.4
			injuries = "Slipped Disk (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.CONCUSSION:
			money_injury_penalty = 0.6
			injuries = "Concussion (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.BROKEN_LEGS:
			money_injury_penalty = 0.6
			injuries = "Broken Legs (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.BROKEN_BACK:
			money_injury_penalty = 0.7
			injuries = "Broken Back (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.HEART_FAILURE:
			money_injury_penalty = 0.75
			injuries = "Heart Failure (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.COMATOSE:
			money_injury_penalty = 0.8
			injuries = "Comatose (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.BROKEN_FEMUR:
			money_injury_penalty = 0.9
			injuries = "Broken Femur (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.PARAPLEGIC:
			money_injury_penalty = 0.95
			injuries = "Paraplegic (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.COMATOSE_PARAPLEGIC:
			money_injury_penalty = 0.99
			injuries = "Comatose Paraplegic (-%.1f%%)" % [money_injury_penalty * 100.0]
		Player.Injury.DEAD:
			money_injury_penalty = 1.0
			injuries = "Dead (-%.1f%%)" % [money_injury_penalty * 100.0]
	
	var money_injuries_cents: int = int(float(money_total_cents) * money_injury_penalty)
	money_total_cents -= money_injuries_cents
	
	_game_data.money_deposit(0, money_total_cents)
	
	_results_stats_middle.text = "%.2f meters\n%.2f meters\n%.2f meters/second\n%s\n" % [distance, altitude, velocity, injuries]
	_results_stats_right.text = "+$%d.%02d\n+$%d.%02d\n+$%d.%02d\n-$%d.%02d\n+$%d.%02d\n" % [
		money_distance_cents / 100, money_distance_cents % 100,
		money_altitude_cents / 100, money_altitude_cents % 100,
		money_velocity_cents / 100, money_velocity_cents % 100,
		money_injuries_cents / 100, money_injuries_cents % 100,
		0, 0
		]
	
	_results_total_right.text = "$%d.%02d" % [money_total_cents / 100, money_total_cents % 100]
	
	_game_data.attempt_add()
