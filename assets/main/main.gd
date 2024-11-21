extends Node

# TODO: shader precompilation
# transition animation between states
# 

const Play: = preload("res://assets/play/play.gd")
const PLAY_SCENE: PackedScene = preload("res://assets/play/play.tscn")
const GuiShop: = preload("res://assets/gui/gui_shop.gd")
const HOME_SCENE: PackedScene = preload("")
const GuiHome: = preload("res://assets/gui/gui_home.gd")

@export
var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

@onready
var _gui_shop: GuiShop = $gui/gui_shop as GuiShop
@onready
var _gui_home: GuiHome = $gui/gui_home as GuiHome
@onready
var _transition: ColorRect = $gui/transition as ColorRect

enum State { NONE, HOME, PLAY, SHOP }
var _state: State = State.HOME

var _play: Play = null

func _ready() -> void:
	set_state(State.HOME)

var _state_transition: bool = false
var _state_transition_tween: Tween = null
func set_state(state: State) -> void:
	if _state_transition:
		return
	
	if _state == state:
		return
	
	_state = state
	_state_transition = true
	_transition.visible = true
	_state_transition_tween = create_tween()
	_state_transition_tween.set_ease(Tween.EASE_IN_OUT)
	_state_transition_tween.set_trans(Tween.TRANS_CUBIC)
	_state_transition_tween.set_parallel(true)
	_state_transition_tween.tween_property(_transition, "modulate:a", 1.0, 1.0)
	
	await _state_transition_tween.finished
	
	match _state:
		State.HOME:
			if is_instance_valid(_play):
				remove_child(_play)
				_play.queue_free()
		State.PLAY:
			pass
		State.SHOP:
			if is_instance_valid(_play):
				remove_child(_play)
				_play.queue_free()
			_gui_shop.queue_refresh()
	
	_state_transition_tween.tween_property(_transition, "modulate:a", 0.0, 1.0)
	
	await _state_transition_tween.finished
	
	_transition.visible = false
	_state_transition = false

func _on_map_exit() -> void:
	set_state(State.SHOP)

func _on_gui_shop_exit_home() -> void:
	set_state(State.HOME)

func _on_gui_shop_exit_play() -> void:
	set_state(State.PLAY)
