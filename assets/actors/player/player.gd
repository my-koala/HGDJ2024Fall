@tool
extends ProjectileBody2D

@export
var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

@export
var player: bool = false

@export
var swing: Swing2D = null:
	get:
		return swing
	set(value):
		if is_instance_valid(swing):
			swing.remove_swing_thruster(_swing_thruster)
		swing = value
		if is_instance_valid(swing):
			swing.add_swing_thruster(_swing_thruster)
		reset_physics_interpolation()

@export
var swing_offset: Vector2 = Vector2.ZERO

# Rotations per second.
@export
var turn_speed: float = 12.0
@export
var turn_acceleration: float = 4.0
var _turn_direction: float = 0.0

@export
var acceleration_death: float = 128.0
var _linear_velocity: Vector2 = Vector2.ZERO

@onready
var _swing_thruster: SwingThruster2D = $swing_thruster_2d as SwingThruster2D
@onready
var _particles_gore: GPUParticles2D = $particles/particles_gore as GPUParticles2D
@onready
var _sprite: Sprite2D = $sprite_2d as Sprite2D

@onready
var _collision_head: CollisionShape2D = $head as CollisionShape2D
@onready
var _collision_front: CollisionShape2D = $front as CollisionShape2D
@onready
var _collision_back: CollisionShape2D = $back as CollisionShape2D
@onready
var _collision_legs: CollisionShape2D = $legs as CollisionShape2D

func is_swinging() -> bool:
	return is_instance_valid(swing)

var _input_move: float = 0.0
var _input_jump: bool = false

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	_input_move = 0.0
	_input_move += float(Input.is_action_pressed(&"move_x+"))
	_input_move -= float(Input.is_action_pressed(&"move_x-"))
	
	_input_jump = _input_jump || Input.is_action_just_pressed(&"jump")

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	contact_monitor = true
	max_contacts_reported = 4
	
	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)

enum Injury { NONE, BROKEN_RIBS, CONCUSSION, BROKEN_LEGS, BROKEN_BACK, COMATOSE, PARAPLEGIC, COMATOSE_PARAPLEGIC, DEAD }
var _injury: Injury = Injury.NONE

func _set_injury(injury: Injury) -> void:
	if injury > _injury:
		_injury = injury

func get_injury() -> Injury:
	return _injury

enum BodyPart { HEAD, FRONT, BACK, LEGS }
var _colliding_body_parts: Array[BodyPart] = []

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	match shape_owner_get_owner(local_shape_index):
		_collision_head:
			_colliding_body_parts.append(BodyPart.HEAD)
		_collision_front:
			_colliding_body_parts.append(BodyPart.FRONT)
		_collision_back:
			_colliding_body_parts.append(BodyPart.BACK)
		_collision_legs:
			_colliding_body_parts.append(BodyPart.LEGS)

func _on_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	match shape_owner_get_owner(local_shape_index):
		_collision_head:
			_colliding_body_parts.erase(BodyPart.HEAD)
		_collision_front:
			_colliding_body_parts.erase(BodyPart.FRONT)
		_collision_back:
			_colliding_body_parts.erase(BodyPart.BACK)
		_collision_legs:
			_colliding_body_parts.erase(BodyPart.LEGS)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if Engine.is_editor_hint():
		return
	
	if _injury == Injury.DEAD:
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
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
	
	if !player:
		return
	
	if !is_swinging():
		_turn_direction = signf(_input_move)
		
		if _colliding_body_parts.is_empty():
			_sprite.frame = 3
		else:
			_check_injury(linear_velocity.distance_to(_linear_velocity))
			_sprite.frame = 4
	else:
		if _input_move > 0.0:
			_sprite.frame = 1
		elif _input_move < 0.0:
			_sprite.frame = 2
		else:
			_sprite.frame = 0
		
		_swing_thruster.activate()
		_swing_thruster.thrust_direction = Vector2.RIGHT * _input_move
		
		if _input_jump:
			_input_jump = false
			# Check for swing thrusters and activate them.
			var jump: bool = true
			for swing_thruster: SwingThruster2D in swing.get_swing_thrusters():
				if swing_thruster != _swing_thruster && !swing_thruster.is_active():
					swing_thruster.activate()
					jump = false
			# Jump off swing, retaining swing velocity.
			if jump:
				swing = null
	
	_linear_velocity = linear_velocity

func _check_injury(acceleration: float) -> void:
	if _injury == Injury.DEAD:
		return
	
	if acceleration > 3000.0:
		_set_injury(Injury.DEAD)
		_particles_gore.emitting = true
		_sprite.visible = false
	
	if acceleration > 2000.0:
		for body_part: BodyPart in _colliding_body_parts:
			if body_part == BodyPart.HEAD:
				print("head hit hard - comatose paraplegic")
				_set_injury(Injury.COMATOSE_PARAPLEGIC)
			if body_part == BodyPart.BACK:
				print("back hit hard - paraplegic")
				_set_injury(Injury.PARAPLEGIC)
	
	if acceleration > 1200.0:
		for body_part: BodyPart in _colliding_body_parts:
			if body_part == BodyPart.HEAD:
				print("head hit - comatose")
				_set_injury(Injury.COMATOSE)
			if body_part == BodyPart.FRONT:
				print("front hit - broken ribs")
				_set_injury(Injury.BROKEN_RIBS)
			if body_part == BodyPart.BACK:
				print("back hit - broken back")
				_set_injury(Injury.BROKEN_BACK)
			if body_part == BodyPart.LEGS:
				print("legs hit - broken legs")
				_set_injury(Injury.BROKEN_LEGS)
	
	if acceleration > 500.0:
		for body_part: BodyPart in _colliding_body_parts:
			if body_part == BodyPart.HEAD:
				print("head hit softly - concussion")
				_set_injury(Injury.CONCUSSION)
	
