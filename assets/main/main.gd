@tool
extends Node

# BUG: looks like a bug with swing tension not properly retaining velocity?
# it's definitely noticeable with huge velocity discrepancy between small vs big swing


# DONE
# finish catenary texture drawing
# add thruster functionality
# finish thrusters art - need sprites, particles
# redo character art - need leaning animations, freefall, and landing - animations
# balance drag, gravity, etc.
# add injuries, child safety items - still unsure how to do this lolololol
# add safety items e.g. parachute, umbrella, and tier-ize injuries
# add altitude and velocity indicators (need velocity direction too, perhaps drag line particles)
# finish swing height art, use sprite frames, correspond to heights - do after balancing - super easy
# shader precompilation because dumb lag
# add land mines
# add education
# make firework explode
# add credits screen to menu - super easy

# TODO stuff to finish for final deliverable
# toggle deployment of floater (cuz descending can take too long)??? maybe?
# add sounds
# finally balance the prices - quadratic money scaling
# then add more art
# fix controller on web (square is being read?)

const SCENE_HOME: PackedScene = preload("res://assets/scenes/home/home.tscn")
const SceneHome: = preload("res://assets/scenes/home/home.gd")
const SCENE_PLAY: PackedScene = preload("res://assets/scenes/play/play.tscn")
const ScenePlay: = preload("res://assets/scenes/play/play.gd")
const SCENE_SHOP: PackedScene = preload("res://assets/scenes/shop/shop.tscn")
const SceneShop: = preload("res://assets/scenes/shop/shop.gd")

const ParticleShaderPrecompile: = preload("particle_shader_precompile.gd")

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

@onready
var _precompile: CanvasLayer = $precompile as CanvasLayer
@onready
var _particle_shader_precompile: ParticleShaderPrecompile = $precompile/particle_shader_precompile as ParticleShaderPrecompile

enum Scene { NONE, HOME, PLAY, SHOP }
var _scene: Scene = Scene.NONE

@onready
var _splash: CanvasLayer = $splash as CanvasLayer
@onready
var _splash_over: ColorRect = $splash/splash/color_rect_2 as ColorRect
var _splash_tween: Tween = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	set_scene(Scene.NONE)
	
	_precompile.visible = false
	_splash.visible = true
	_splash_tween = create_tween()
	_splash_tween.set_ease(Tween.EASE_IN_OUT)
	_splash_tween.set_trans(Tween.TRANS_LINEAR)
	_splash_tween.set_parallel(false)
	_splash_tween.tween_property(_splash_over, "modulate:a", 0.0, 1.0)
	await _splash_tween.finished
	_splash_tween.stop()
	_splash_tween.tween_property(_splash_over, "modulate:a", 1.0, 0.5)
	_splash_tween.tween_interval(0.5)
	_splash_tween.play()
	await _splash_tween.finished
	
	_splash.visible = false
	_precompile.visible = true
	
	_particle_shader_precompile.start()
	await _particle_shader_precompile.finished
	_precompile.visible = false
	
	set_scene(Scene.HOME, true)
	
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
func set_scene(scene: Scene, force: bool = false) -> void:
	if _scene_transition && !force:
		return
	
	var duration: float = 0.0
	
	_scene = scene
	_scene_transition = true
	_transition.visible = true
	
	
	if is_instance_valid(_scene_transition_tween) && _scene_transition_tween.is_valid():
		_scene_transition_tween.kill()
	_scene_transition_tween = create_tween()
	_scene_transition_tween.set_ease(Tween.EASE_IN_OUT)
	_scene_transition_tween.set_trans(Tween.TRANS_LINEAR)
	_scene_transition_tween.set_parallel(true)
	duration = 0.25 * (1.0 - (_transition.modulate.a / 1.0))
	_scene_transition_tween.tween_property(_transition, "modulate:a", 1.0, duration)
	
	_scene_transition_tween.play()
	await _scene_transition_tween.finished
	_scene_transition_tween.stop()
	
	match _scene:
		Scene.NONE:
			_scene_home_layer.visible = false
			_scene_play_layer.visible = false
			_scene_shop_layer.visible = false
			
			_scene_home_layer.process_mode = Node.PROCESS_MODE_DISABLED
			_scene_play_layer.process_mode = Node.PROCESS_MODE_DISABLED
			_scene_shop_layer.process_mode = Node.PROCESS_MODE_DISABLED
			
			_scene_home.scene_stop()
			_scene_play.scene_stop()
			_scene_shop.scene_stop()
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
	
	duration = 0.25 * (_transition.modulate.a / 1.0)
	_scene_transition_tween.tween_property(_transition, "modulate:a", 0.0, duration)
	
	_scene_transition_tween.play()
	await _scene_transition_tween.finished
	_scene_transition_tween.stop()
	
	_scene_transition = false
	
	_transition.visible = false
