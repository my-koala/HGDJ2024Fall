@tool
extends ProjectileBody2D
class_name Swing2D

@export
var rigid: bool = false

@export
var length: float = 256.0:
	get:
		return length
	set(value):
		length = maxf(value, 0.0)
		if Engine.is_editor_hint():
			queue_redraw()

@export
var tension_max: float = 4096.0:
	get:
		return tension_max
	set(value):
		tension_max = maxf(value, 0.0)

@export
var torsion_friction: float = 0.75:
	get:
		return torsion_friction
	set(value):
		torsion_friction = clampf(value, 0.0, 1.0)

var _anchor_position: Vector2 = Vector2.ZERO

func set_anchor_position(anchor_position: Vector2) -> void:
	_anchor_position = anchor_position

var _broken: bool = false

func is_broken() -> bool:
	return _broken

var _correction: Vector2 = Vector2.ZERO

var _swing_thrusters: Array[SwingThruster2D] = []

func add_swing_thruster(swing_thruster: SwingThruster2D) -> void:
	if is_instance_valid(swing_thruster) && !_swing_thrusters.has(swing_thruster):
		_swing_thrusters.append(swing_thruster)

func remove_swing_thruster(swing_thruster: SwingThruster2D) -> void:
	if is_instance_valid(swing_thruster) && _swing_thrusters.has(swing_thruster):
		_swing_thrusters.erase(swing_thruster)

func get_swing_thrusters() -> Array[SwingThruster2D]:
	return _swing_thrusters.duplicate()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	set_anchor_position(global_position)
	global_position.y += length

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	
	draw_circle(Vector2.DOWN * length, 4.0, Color.RED, true)
	draw_line(Vector2.ZERO, Vector2.DOWN * length, Color.ORANGE_RED, 1.0)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if Engine.is_editor_hint():
		return
	
	# Reverse tether correction and zero it out.
	state.linear_velocity -= _correction
	_correction = Vector2.ZERO
	
	# Apply thruster forces.
	for swing_thruster: SwingThruster2D in _swing_thrusters:
		if swing_thruster.is_active():
			var thrust: Vector2 = swing_thruster.get_thrust().rotated(swing_thruster.global_rotation)
			state.linear_velocity += state.inverse_mass * thrust * state.step
	
	# Apply projectile forces (gravity, drag, etc.)
	super(state)
	
	if is_broken():
		return
	
	# Apply tether tension.
	# Get radius vector from anchor to position.
	var radius: Vector2 = global_position - _anchor_position
	# Get radius after one velocity step, used for snapping to tether length.
	var radius_step: Vector2 = radius + (state.linear_velocity * state.step)
	if rigid || (radius_step.length_squared() >= (length ** 2.0)):
		var theta: float = radius.angle_to(state.linear_velocity)
		# Calculate tension as the component of velocity projected onto radius vector.
		
		var tension: float = state.linear_velocity.length() * cos(theta)
		state.linear_velocity += tension * -radius.normalized()
		
		if (state.linear_velocity.length_squared() / length) > tension_max:
			_broken = true# Do some breaking and stuff
			return
		
		# Right now tension modifies velocity to be tangential to the tether radius.
		# This causes the next velocity stepped position to shift outside.
		# Modify velocity so that next velocity step is snapped to the tether radius.
		radius_step = radius + (state.linear_velocity * state.step)
		_correction = maxf(radius_step.length() - length, 0.0) * -radius_step.normalized() / state.step
	
	# Apply tether correction.
	state.linear_velocity += _correction
	
	state.transform = state.transform.looking_at(_anchor_position).rotated_local(PI / 2.0)
