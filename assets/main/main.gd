@tool
extends Node

# BUG: looks like a bug with swing tension not properly retaining velocity?
# it's definitely noticeable with huge velocity discrepancy between small vs big swing

# DONE
# finish catenary texture drawing
# add thruster functionality

# TODO stuff to finish for final deliverable
# finish thrusters art - need sprites, particles
# redo character art - need leaning animations, freefall, and landing - animations
# balance drag, gravity, etc.
# finish swing height art, use sprite frames, correspond to heights - do after balancing - super easy
# add sounds (when power comes back)
# add instructions and credits screen to menu
# shader precompilation
# add injuries, child safety items - still unsure how to do this lolololol
# - pillow: softer landing on landing - need some sort of spring force stuff?
#   - or could just increase impact threshold for injuries
# 
# add land mines
# add balloons?

const SCENE_HOME: PackedScene = preload("res://assets/scenes/home/home.tscn")
const SceneHome: = preload("res://assets/scenes/home/home.gd")
const SCENE_PLAY: PackedScene = preload("res://assets/scenes/play/play.tscn")
const ScenePlay: = preload("res://assets/scenes/play/play.gd")
const SCENE_SHOP: PackedScene = preload("res://assets/scenes/shop/shop.tscn")
const SceneShop: = preload("res://assets/scenes/shop/shop.gd")

@export
var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

@onready
var _scene_home_layer: CanvasLayer = $scene_home as CanvasLayer
@onready
var _scene_home: SceneHome = $scene_home/home as SceneHome
@onready
var _scene_play_layer: CanvasLayer = $scene_play as CanvasLayer
@onready
var _scene_play: ScenePlay = $scene_play/play as ScenePlay
@onready
var _scene_shop_layer: CanvasLayer = $scene_shop as CanvasLayer
@onready
var _scene_shop: SceneShop = $scene_shop/shop as SceneShop

@onready
var _transition: ColorRect = $overlay/transition as ColorRect

enum Scene { NONE, HOME, PLAY, SHOP }
var _scene: Scene = Scene.NONE

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	set_scene(Scene.HOME)
	
	_scene_home.exit_play.connect(_on_scene_home_exit_play)
	_scene_play.exit.connect(_on_scene_play_exit)
	_scene_shop.exit_home.connect(_on_scene_shop_exit_home)
	_scene_shop.exit_play.connect(_on_scene_shop_exit_play)

func _on_scene_home_exit_play() -> void:
	set_scene(Scene.PLAY)

func _on_scene_play_exit() -> void:
	set_scene(Scene.SHOP)

func _on_scene_shop_exit_home() -> void:
	set_scene(Scene.HOME)

func _on_scene_shop_exit_play() -> void:
	set_scene(Scene.PLAY)

var _scene_transition: bool = false
var _scene_transition_tween: Tween = null
func set_scene(scene: Scene) -> void:
	if _scene_transition:
		return
	
	if _scene == scene:
		return
	
	var duration: float = 0.0
	
	_scene = scene
	_scene_transition = true
	_transition.visible = true
	
	_scene_transition_tween = create_tween()
	_scene_transition_tween.set_ease(Tween.EASE_IN_OUT)
	_scene_transition_tween.set_trans(Tween.TRANS_CUBIC)
	_scene_transition_tween.set_parallel(true)
	duration = 0.5 * (1.0 - (_transition.modulate.a / 1.0))
	_scene_transition_tween.tween_property(_transition, "modulate:a", 1.0, duration)
	
	_scene_transition_tween.play()
	await _scene_transition_tween.finished
	_scene_transition_tween.stop()
	
	match _scene:
		Scene.HOME:
			_scene_home_layer.visible = true
			_scene_play_layer.visible = false
			_scene_shop_layer.visible = false
			
			_scene_home_layer.process_mode = Node.PROCESS_MODE_INHERIT
			_scene_play_layer.process_mode = Node.PROCESS_MODE_DISABLED
			_scene_shop_layer.process_mode = Node.PROCESS_MODE_DISABLED
			
			_scene_home.scene_start()
			_scene_play.scene_stop()
			_scene_shop.scene_stop()
		Scene.PLAY:
			_scene_home_layer.visible = false
			_scene_play_layer.visible = true
			_scene_shop_layer.visible = false
			
			_scene_home_layer.process_mode = Node.PROCESS_MODE_DISABLED
			_scene_play_layer.process_mode = Node.PROCESS_MODE_INHERIT
			_scene_shop_layer.process_mode = Node.PROCESS_MODE_DISABLED
			
			_scene_home.scene_stop()
			_scene_play.scene_start()
			_scene_shop.scene_stop()
		Scene.SHOP:
			_scene_home_layer.visible = false
			_scene_play_layer.visible = false
			_scene_shop_layer.visible = true
			
			_scene_home_layer.process_mode = Node.PROCESS_MODE_DISABLED
			_scene_play_layer.process_mode = Node.PROCESS_MODE_DISABLED
			_scene_shop_layer.process_mode = Node.PROCESS_MODE_INHERIT
			
			_scene_home.scene_stop()
			_scene_play.scene_stop()
			_scene_shop.scene_start()
	
	duration = 0.5 * (_transition.modulate.a / 1.0)
	_scene_transition_tween.tween_property(_transition, "modulate:a", 0.0, duration)
	
	_scene_transition_tween.play()
	await _scene_transition_tween.finished
	_scene_transition_tween.stop()
	
	_transition.visible = false
	_scene_transition = false
