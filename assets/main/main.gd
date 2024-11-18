extends Node

const Precompile: = preload("precompile.gd")

@onready
var _precompile: Precompile = $precompile as Precompile

@onready
var _map: Node2D = $map as Node2D

@onready
var _canvas_layer: CanvasLayer = $canvas_layer as CanvasLayer

var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

func _ready() -> void:
	#_map.process_mode = Node.PROCESS_MODE_DISABLED
	_canvas_layer.visible = true
	await _precompile.done
	_map.process_mode = Node.PROCESS_MODE_INHERIT
	_canvas_layer.visible = false
