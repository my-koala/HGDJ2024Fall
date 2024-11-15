@tool
extends ProjectileBody2D
class_name Swing2D

@export
var tether_rigid: bool = false

@export
var tether_length: float = 32.0:
	get:
		return tether_length
	set(value):
		tether_length = maxf(value, 0.0)
		if Engine.is_editor_hint():
			queue_redraw()

@export
var tether_tension_max: float = 120.0:
	get:
		return tether_tension_max
	set(value):
		tether_tension_max = maxf(value, 0.0)

@export
var tether_torsion_friction: float = 0.75:
	get:
		return tether_torsion_friction
	set(value):
		tether_torsion_friction = clampf(value, 0.0, 1.0)

var _tether_anchor_position: Vector2 = Vector2.ZERO

func set_tether_anchor_position() -> void:
	_tether_anchor_position = global_position
	global_position = global_position + Vector2.DOWN * tether_length

var _tether_broken: bool = false

func is_tether_broken() -> bool:
	return _tether_broken

var _tether_correction: Vector2 = Vector2.ZERO

var _swing_thrusters: Array[SwingThruster2D] = []

func add_swing_thruster(swing_thruster: SwingThruster2D) -> void:
	if is_instance_valid(swing_thruster) && !_swing_thrusters.has(swing_thruster):
		_swing_thrusters.append(swing_thruster)

func remove_swing_thruster(swing_thruster: SwingThruster2D) -> void:
	if is_instance_valid(swing_thruster) && _swing_thrusters.has(swing_thruster):
		_swing_thrusters.erase(swing_thruster)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	set_tether_anchor_position()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	
	draw_circle(Vector2.DOWN * tether_length, 4.0, Color.RED, true)
	draw_line(Vector2.ZERO, Vector2.DOWN * tether_length, Color.ORANGE_RED, 1.0)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if Engine.is_editor_hint():
		return
	
	# Reverse tether correction and zero it out.
	state.linear_velocity -= _tether_correction
	_tether_correction = Vector2.ZERO
	
	# Apply thruster forces.
	for swing_thruster: SwingThruster2D in _swing_thrusters:
		if swing_thruster.active:
			var thrust_direction: Vector2 = swing_thruster.thrust_direction.rotated(swing_thruster.global_rotation)
			var thrust: Vector2 = swing_thruster.thrust * thrust_direction
			state.linear_velocity += state.inverse_mass * thrust * state.step
	
	# Apply projectile forces (gravity, drag, etc.)
	super(state)
	
	if is_tether_broken():
		return
	
	# Apply tether tension.
	# Get radius vector from anchor to position.
	var tether_radius: Vector2 = global_position - _tether_anchor_position
	# Get radius after one velocity step, used for snapping to tether length.
	var tether_radius_step: Vector2 = tether_radius + (state.linear_velocity * state.step)
	if tether_rigid || (tether_radius_step.length_squared() >= (tether_length ** 2.0)):
		var theta: float = tether_radius.angle_to(state.linear_velocity)
		# Calculate tension as the component of velocity projected onto radius vector.
		
		var tether_tension: float = state.linear_velocity.length() * cos(theta)
		state.linear_velocity += tether_tension * -tether_radius.normalized()
		
		if (state.linear_velocity.length_squared() / tether_length) > tether_tension_max:
			_tether_broken = true# Do some breaking and stuff
			return
		
		# Right now tension modifies velocity to be tangential to the tether radius.
		# This causes the next velocity stepped position to shift outside.
		# Modify velocity so that next velocity step is snapped to the tether radius.
		tether_radius_step = tether_radius + (state.linear_velocity * state.step)
		_tether_correction = maxf(tether_radius_step.length() - tether_length, 0.0) * -tether_radius_step.normalized() / state.step
	
	# Apply tether correction.
	state.linear_velocity += _tether_correction
	
	state.transform = state.transform.looking_at(_tether_anchor_position).rotated_local(PI / 2.0)
