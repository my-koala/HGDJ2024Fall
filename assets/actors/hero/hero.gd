@tool
extends RigidBody2D

const MG_TO_KG: float = 10 ** 6.0

@export
var swing: Swing2D = null
@export
var swing_offset: Vector2 = Vector2.ZERO
@export
var swing_move_acceleration: float = 1.5

@export
var drag_size: Vector2 = Vector2(16.0, 24.0)
@export
var drag_coefficient: Vector2 = Vector2(0.5, 0.75)
@export
var drag_density: float = 0.572204589844# Milligrams per cubic pixel.
# TODO: Air density should be calculated as a function of altitude.
# NOTE: Default value is equivalent to air density of 1.2 kg per cubic meter.

# Use acceleration rather than fixed speed because it feels more correct.
@export_range(0.0, 360.0, 0.01, "or_greater", "hide_slider", "radians_as_degrees")
var air_turn_acceleration: float = PI

var _input_move: float = 0.0
var _input_jump: bool = false

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	_input_move = 0.0
	_input_move += float(Input.is_action_pressed(&"move_x+"))
	_input_move -= float(Input.is_action_pressed(&"move_x-"))
	
	_input_jump = Input.is_action_pressed(&"jump")

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if is_instance_valid(swing):
		# Hero is in swing movement.
		swing.velocity.x += swing_move_acceleration * _input_move
		
		if _input_move > 0.0:
			pass# Play lean forward animation.
		else:
			pass# Play lean backward animation.
		
		velocity = ((swing.global_position + swing_offset) - global_position) / delta
		
		if _input_jump:
			# Jump off swing, retaining swing velocity.
			velocity = swing.velocity
			swing = null
	else:
		# Hero is in free movement.
		
		# Apply gravity.
		velocity += get_gravity() * delta
		
		# Calculate drag.
		if !velocity.is_zero_approx():
			var drag_direction: Vector2 = -velocity.normalized()
			
			# Calculate surface area "visible" to drag by dotting edge normals with drag direction.
			var edge_x_normal: Vector2 = Vector2(drag_size.x, 0.0).rotated(global_rotation + (PI / 2.0)).normalized()
			var edge_x_fraction: float = absf(drag_direction.dot(edge_x_normal))
			var edge_y_normal: Vector2 = Vector2(0.0, drag_size.y).rotated(global_rotation + (PI / 2.0)).normalized()
			var edge_y_fraction: float = absf(drag_direction.dot(edge_y_normal))
			
			var area: float = (edge_x_fraction * drag_size.x) + (edge_y_fraction * drag_size.y)
			var coeff: float = (edge_x_fraction * drag_coefficient.x) + (edge_y_fraction * drag_coefficient.y)
			
			var density_kg: float = (drag_density / MG_TO_KG)
			
			var drag: Vector2 = drag_direction * (0.5 * coeff * density_kg * linear_velocity.length_squared() * area)
			
			
			velocity += drag * delta
		
		# TODO: Ground friction. Also, bouncing.
	
	move_and_slide()
