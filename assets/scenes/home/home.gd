@tool
extends Control

signal exit_play()
signal exit_quit()

@onready
var _button_play: Button = $buttons/play as Button
@onready
var _button_tutorial: Button = $buttons/tutorial as Button
@onready
var _button_credits: Button = $buttons/credits as Button
@onready
var _button_quit: Button = $buttons/quit as Button

func _ready() -> void:
	_button_play.pressed.connect(_on_button_play_pressed)
	_button_quit.pressed.connect(_on_button_quit_pressed)

func _on_button_play_pressed() -> void:
	exit_play.emit()

func _on_button_quit_pressed() -> void:
	exit_quit.emit()

var _scene_active: bool = false
func scene_start() -> void:
	_scene_active = true
	_button_play.grab_focus.call_deferred()

func scene_stop() -> void:
	_scene_active = false
	_button_play.release_focus.call_deferred()
