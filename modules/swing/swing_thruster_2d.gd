@tool
extends Node2D
class_name SwingThruster2D

# TODO: Animate thrust with tween
@export
var thrust: float = 0.0

# Local thrust direction (affected by transform rotation).
@export
var thrust_direction: Vector2 = Vector2.RIGHT:
	get:
		return thrust_direction
	set(value):
		thrust_direction = value.normalized()

var _active: bool = false
func is_active() -> bool:
	return _active

func activate() -> void:
	_active  = true

func get_thrust() -> Vector2:
	return thrust * thrust_direction
