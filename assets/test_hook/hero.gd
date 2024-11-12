@tool
extends CharacterBody2D

# TODO today:
# finish sliding, hero state machine, general movement mechanics
# add shooting, enemies, health
# maybe add dynamic chain

# i think i'll just make sliding automatic
# if the player wants to stop, just hold opposite direction

@export
var ground_move_speed: float = 16.0

@export
var ground_move_acceleration: float = 32.0

@export
var ground_jump_speed: float = 256.0

@export
var slide_friction_acceleration: float = 16.0

@export
var slide_brake_acceleration: float = 64.0

@export
var air_friction: float = 0.75

@export
var air_move_acceleration: float = 16.0

@export
var air_jump_speed: float = 256.0

@export
var hook_move_speed: float = 4.0

@export
var hook_pull_speed: float = 512.0
@export
var hook_pull_time: float = 0.125
var _hook_pull_time: float = 0.0

@export
var hook_swing_speed: float = 8.0

@export
var hook_climb_speed: float = 3.0

@export
var hook_correction_speed: float = 16.0

@onready
var _hook: Hook2D = $hook_2d as Hook2D

var _jump_once: bool = false

var _input_move: Vector2 = Vector2.ZERO
var _input_jump: bool = false
var _input_hook: bool = false
var _input_hook_position: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	_input_move = Vector2.ZERO
	_input_move.x += float(Input.is_action_pressed(&"move_x+"))
	_input_move.x -= float(Input.is_action_pressed(&"move_x-"))
	_input_move.y += float(Input.is_action_pressed(&"move_y+"))
	_input_move.y -= float(Input.is_action_pressed(&"move_y-"))
	
	if Input.is_action_just_pressed(&"jump"):
		_input_jump = true
	
	if Input.is_action_just_pressed(&"hook"):
		_input_hook = true
		_input_hook_position = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _input_hook:
		if _hook.is_hooked():
			_hook.detach()
		else:
			_hook.fire(global_position.direction_to(_input_hook_position))
	
	#$label.set(&"text", "move")
	
	# Apply gravity acceleration.
	var gravity: Vector2 = get_gravity()
	velocity += gravity * delta
	
	# NOTE: Applicable to both unhooked and hooked state.
	if is_on_floor():
		_jump_once = false
		var move_axis: Vector2 = get_gravity().orthogonal().normalized()
		if velocity.length_squared() <= (ground_move_speed ** 2.0):
			# Walk.
			velocity = velocity.move_toward(_input_move * move_axis * ground_move_speed, ground_move_acceleration * delta)
		else:
			# Slide.
			velocity = velocity.move_toward(Vector2.ZERO, slide_friction_acceleration * delta)
			# Apply slide brake acceleration on opposite input direction.
			if velocity.dot(_input_move) <= 0.0:
				velocity = velocity.move_toward(Vector2.ZERO, slide_brake_acceleration * delta)
	
	if !_hook.is_hooked():
		if is_on_floor():
			if _input_jump && !_jump_once:
				_jump_once = true
				var jump_axis: Vector2 = -get_gravity().normalized()
				if (velocity * jump_axis).dot(jump_axis) > 0.0:
					velocity.y += -ground_jump_speed
				else:
					velocity.y = -ground_jump_speed
		else:
			if _input_jump && !_jump_once:
				_jump_once = true
				var jump_axis: Vector2 = -get_gravity().normalized()
				if (velocity * jump_axis).dot(jump_axis) > 0.0:
					velocity.y += -air_jump_speed
				else:
					velocity.y = -air_jump_speed
	else:
		_jump_once = false
		
		var swing_axis: Vector2 = Vector2.RIGHT
		var climb_axis: Vector2 = Vector2.DOWN
		
		var climb: float = roundf(clampf(climb_axis.dot(_input_move), -1.0, 1.0))
		var swing: float = roundf(clampf(swing_axis.dot(_input_move), -1.0, 1.0))
		if !is_zero_approx(climb):
			_hook.add_length(-climb * hook_climb_speed)
			if climb < 0.0:
				pass# Play pulling chain animation
			elif climb > 0.0:
				pass# Play loosing chain animation
		elif !is_zero_approx(swing):
			velocity += swing_axis * swing * hook_swing_speed
			velocity
			# Play swinging animation depending on face direction and velocity
		
		# Get radius vector from hook to position.
		var radius: Vector2 = global_position - _hook.get_hooked_position()
		# Get radius after one velocity step, used for 'snapping' to hook length.
		var radius_step: Vector2 = radius + (velocity * delta)
		if radius_step.length_squared() >= (_hook.get_hooked_length() ** 2.0):
			# TODO: Movement in hook space.
			# Dash on tangential?
			
			var theta: float = radius.angle_to(velocity)
			# Calculate tension as the component of velocity projected onto radius vector.
			var tension: Vector2 = velocity.length() * cos(theta) * -radius.normalized()
			velocity += tension
			# Right now tension modifies velocity to be tangential to hook radius.
			# This causes the next velocity stepped position to shift away from the hook radius.
			# Need to correct tension so that next velocity step is snapped to the hook radius.
			radius_step = radius + (velocity * delta)
			var correction: float = maxf(radius_step.length() - _hook.get_hooked_length(), 0.0)
			velocity += hook_correction_speed * correction * -radius_step.normalized()
		#
		#if input_jump && !_jump_once:
			#_jump_once = true
			#_hook.detach()
			#velocity.y = -jump_speed
	#
	move_and_slide()
