@tool
extends CharacterBody2D
class_name Swing2D

@export_range(0.0, 1.0, 0.01, "or_greater", "hide_slider")
var length: float = 128.0:
	get:
		return length
	set(value):
		length = maxf(value, 0.0)
		queue_redraw()

@export_range(0.0, 1.0, 0.01, "or_greater", "hide_slider")
var correction_speed: float = 128.0:
	get:
		return correction_speed
	set(value):
		correction_speed = maxf(value, 0.0)

var _anchor_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_anchor_position = global_position + Vector2(0.0, -length)

func _process(delta: float) -> void:
	queue_redraw()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# Apply gravity.
	velocity += get_gravity() * delta
	
	# Get radius vector from hook to position.
	var radius: Vector2 = global_position - _anchor_position
	# Get radius after one velocity step, used for 'snapping' to length.
	var radius_step: Vector2 = radius + (velocity * delta)
	if radius_step.length_squared() >= (length ** 2.0):
		var theta: float = radius.angle_to(velocity)
		# Calculate tension as the component of velocity projected onto radius vector.
		var tension: Vector2 = velocity.length() * cos(theta) * -radius.normalized()
		velocity += tension
		# Right now tension modifies velocity to be tangential to the radius.
		# This causes the next stepped position to shift outside the radius.
		# Need to correct tension so that next velocity step is instead snapped to the radius.
		radius_step = radius + (velocity * delta)
		var correction: float = maxf(radius_step.length() - length, 0.0)
		velocity += correction_speed * correction * -radius_step.normalized()
	
	move_and_slide()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2(0.0, -length), 8.0, Color.RED, true, -1.0, true)
		draw_line(Vector2.ZERO, Vector2(0.0, -length), Color.SKY_BLUE, -1.0, true)
		draw_circle(Vector2.ZERO, 8.0, Color.GREEN, true, -1.0, true)
	else:
		draw_circle(_anchor_position - global_position, 8.0, Color.RED, true, -1.0, true)
		draw_line(Vector2.ZERO, _anchor_position - global_position, Color.SKY_BLUE, -1.0, true)
		draw_circle(Vector2.ZERO, 8.0, Color.GREEN, true, -1.0, true)
