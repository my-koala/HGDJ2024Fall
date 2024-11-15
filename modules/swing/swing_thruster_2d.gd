@tool
extends Node2D
class_name SwingThruster2D

@export
var active: bool = false

# TODO: Animate thrust in AnimationPlayer
@export
var thrust: float = 0.0

# Local thrust direction (affected by transform rotation).
@export
var thrust_direction: Vector2 = Vector2.RIGHT:
	get:
		return thrust_direction
	set(value):
		if !value.is_zero_approx():
			thrust_direction = value.normalized()
