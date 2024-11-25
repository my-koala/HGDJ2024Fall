@tool
extends Control

const GuiPopup: = preload("res://assets/gui/gui_popup.gd")

signal exit_play()

@export
var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

@onready
var _button_play: Button = $buttons/play as Button
@onready
var _button_credits: Button = $buttons/credits as Button
@onready
var _button_quit: Button = $buttons/quit as Button
@onready
var _popup_credits: GuiPopup = $instructions/popup_credits as GuiPopup
@onready
var _popup_quit: GuiPopup = $instructions/popup_quit as GuiPopup
@onready
var _popup_infinite: GuiPopup = $instructions/popup_infinite as GuiPopup

func _ready() -> void:
	_button_play.pressed.connect(_on_button_play_pressed)
	_button_credits.pressed.connect(_on_button_credits_pressed)
	_button_quit.pressed.connect(_on_button_quit_pressed)

func _on_button_credits_pressed() -> void:
	_popup_credits.set_active(true)

func _on_button_play_pressed() -> void:
	exit_play.emit()

func _on_button_quit_pressed() -> void:
	if OS.has_feature("web"):
		_popup_quit.set_active(true)
	else:
		get_tree().quit()

var _scene_active: bool = false
func scene_start() -> void:
	_scene_active = true
	_button_play.grab_focus.call_deferred()

func scene_stop() -> void:
	_scene_active = false
	_button_play.release_focus.call_deferred()

var _input_string: String = ""
func _input(event: InputEvent) -> void:
	if !_scene_active:
		return
	
	if _game_data._infinite_money:
		return
	
	if !event.is_pressed() || event.is_echo():
		return
	
	var event_key: InputEventKey = event as InputEventKey
	if is_instance_valid(event_key):
		var character: String = event_key.as_text()
		_input_string += character
	if !"KOALA".begins_with(_input_string.to_upper()):
		_input_string = ""
	elif _input_string.to_upper() == "KOALA":
		_game_data._infinite_money = true
		_popup_infinite.set_active(true)
