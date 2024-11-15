@tool
extends ProjectileBody2D

@export
var swing: Swing2D = null
@export
var swing_offset: Vector2 = Vector2.ZERO

# Rotations per second.
@export
var turn_speed: float = 12.0
@export
var turn_acceleration: float = 4.0
var _turn_direction: float = 0.0

@onready
var _swing_thruster: SwingThruster2D = $swing_thruster_2d as SwingThruster2D

func is_swinging() -> bool:
	return is_instance_valid(swing)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if is_instance_valid(swing):
		swing.add_swing_thruster(_swing_thruster)

var _input_move: float = 0.0
var _input_jump: bool = false

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	_input_move = 0.0
	_input_move += float(Input.is_action_pressed(&"move_x+"))
	_input_move -= float(Input.is_action_pressed(&"move_x-"))
	
	_input_jump = _input_jump || Input.is_action_pressed(&"jump")

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if Engine.is_editor_hint():
		return
	
	super(state)
	
	if !is_swinging():
		var turn_velocity: float = _turn_direction * turn_speed
		state.angular_velocity = move_toward(state.angular_velocity, turn_velocity, turn_acceleration * state.step)
	else:
		state.linear_velocity = swing.linear_velocity
		state.angular_velocity = 0.0# TODO?
		state.transform = swing.global_transform.translated(swing_offset.rotated(swing.rotation))# - state.linear_velocity * state.step)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if !is_swinging():
		_turn_direction = signf(_input_move)
	else:
		if !is_zero_approx(_input_move):
			_swing_thruster.active = true
			_swing_thruster.thrust_direction = Vector2.RIGHT * _input_move
		else:
			if _input_move > 0.0:
				pass# Play lean forward animation.
			else:
				pass# Play lean backward animation.
			_swing_thruster.active = false
			_swing_thruster.thrust_direction = Vector2.RIGHT * _input_move
	
		if _input_jump:
			_input_jump = false
			# Jump off swing, retaining swing velocity.
			swing.remove_swing_thruster(_swing_thruster)
			swing = null
