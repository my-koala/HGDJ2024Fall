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

@export
var anchor: Node2D = null
@export
var anchor_offset: Vector2 = Vector2.ZERO

var _input_move: float = 0.0
var _input_jump: bool = false

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	_input_move = 0.0
	_input_move += float(Input.is_action_pressed(&"move_x+"))
	_input_move -= float(Input.is_action_pressed(&"move_x-"))
	
	_input_jump = Input.is_action_pressed(&"jump")

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if Engine.is_editor_hint():
		return
	
	if is_instance_valid(anchor):
		var anchor_transform: Transform2D = Transform2D(anchor.global_rotation, anchor.global_position + anchor_offset.rotated(anchor.global_rotation))
		state.transform = anchor_transform
		state.linear_velocity = Vector2.ZERO
		return

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if is_instance_valid(swing):
		# Hero is in swing movement.
		swing.apply_central_force(Vector2(swing_move_acceleration * _input_move, 0.0))
		#swing.velocity.x += swing_move_acceleration * _input_move
		print(swing_move_acceleration * _input_move)
		if _input_move > 0.0:
			pass# Play lean forward animation.
		else:
			pass# Play lean backward animation.
		
		#velocity = ((swing.global_position + swing_offset) - global_position) / delta
		
		if _input_jump:
			# Jump off swing, retaining swing velocity.
			#velocity = swing.velocity
			swing = null
			anchor = null
		# Hero is in free movement.
	
	
