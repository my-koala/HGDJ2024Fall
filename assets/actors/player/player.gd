@tool
extends ProjectileBody2D

const ITEM_SAFETY: Array[Item] = [
	preload("res://assets/item/items/item_safety_0.tres"),
	preload("res://assets/item/items/item_safety_1.tres"),
	preload("res://assets/item/items/item_safety_2.tres"),
	preload("res://assets/item/items/item_safety_3.tres"),
]

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

var _linear_velocity: Vector2 = Vector2.ZERO

@onready
var _swing_thruster: SwingThruster2D = $swing_thruster_2d as SwingThruster2D
@onready
var _particles_gore: GPUParticles2D = $particles/particles_gore as GPUParticles2D
@onready
var _particles_afterimage: GPUParticles2D = $particles/particles_afterimage as GPUParticles2D
@onready
var _particles_afterimage_material: ParticleProcessMaterial = _particles_afterimage.process_material as ParticleProcessMaterial
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

@onready
var _safety_umbrella: ProjectileBody2D = $safety/umbrella as ProjectileBody2D
@onready
var _safety_kite: ProjectileBody2D = $safety/kite as ProjectileBody2D
@onready
var _safety_kite_catenary: Catenary2D = $safety/kite/catenary_2d as Catenary2D
@onready
var _safety_parachute: ProjectileBody2D = $safety/parachute as ProjectileBody2D
@onready
var _safety_parachute_catenary_a: Catenary2D = $safety/parachute/catenary_a as Catenary2D
@onready
var _safety_parachute_catenary_b: Catenary2D = $safety/parachute/catenary_b as Catenary2D
@onready
var _safety_parachute_catenary_c: Catenary2D = $safety/parachute/catenary_c as Catenary2D
@onready
var _safety_parachute_catenary_d: Catenary2D = $safety/parachute/catenary_d as Catenary2D
@onready
var _safety_parachute_catenary_e: Catenary2D = $safety/parachute/catenary_e as Catenary2D
@onready
var _safety_parachute_catenary_f: Catenary2D = $safety/parachute/catenary_f as Catenary2D

var _safety: ProjectileBody2D = null

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
	
	_particles_afterimage.emitting = false
	_particles_afterimage.amount_ratio = 0.0
	
	contact_monitor = true
	max_contacts_reported = 4
	
	_safety_umbrella.freeze = true
	_safety_umbrella.visible = false
	_safety_kite.freeze = true
	_safety_kite.visible = false
	_safety_parachute.freeze = true
	_safety_parachute.visible = false
	
	if _game_data.is_item_equipped(ITEM_SAFETY[0]):
		_safety = null
	elif _game_data.is_item_equipped(ITEM_SAFETY[1]):
		_safety = _safety_umbrella
	elif _game_data.is_item_equipped(ITEM_SAFETY[2]):
		_safety = _safety_kite
	elif _game_data.is_item_equipped(ITEM_SAFETY[3]):
		_safety = _safety_parachute
	else:
		_safety = null
	
	var groove_joint: GrooveJoint2D = _safety_parachute.get_node_or_null("groove_joint_2d") as GrooveJoint2D
	groove_joint.node_b = NodePath("")
	
	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)

enum Injury {
	NONE,
	# small impacts
	SPRAINED_ANKLES,
	BROKEN_RIBS,
	SLIPPED_DISK,
	CONCUSSION,
	# medium impacts
	BROKEN_LEGS,
	BROKEN_BACK,
	HEART_FAILURE,
	COMATOSE,
	# large impacts
	BROKEN_FEMUR,
	PARAPLEGIC,
	COMATOSE_PARAPLEGIC,
	# you're fucked
	DEAD,
}
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
			if !_colliding_body_parts.has(BodyPart.HEAD):
				_colliding_body_parts.append(BodyPart.HEAD)
		_collision_front:
			if !_colliding_body_parts.has(BodyPart.FRONT):
				_colliding_body_parts.append(BodyPart.FRONT)
		_collision_back:
			if !_colliding_body_parts.has(BodyPart.BACK):
				_colliding_body_parts.append(BodyPart.BACK)
		_collision_legs:
			if !_colliding_body_parts.has(BodyPart.LEGS):
				_colliding_body_parts.append(BodyPart.LEGS)

func _on_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	match shape_owner_get_owner(local_shape_index):
		_collision_head:
			if _colliding_body_parts.has(BodyPart.HEAD):
				_colliding_body_parts.erase(BodyPart.HEAD)
		_collision_front:
			if _colliding_body_parts.has(BodyPart.FRONT):
				_colliding_body_parts.erase(BodyPart.FRONT)
		_collision_back:
			if _colliding_body_parts.has(BodyPart.BACK):
				_colliding_body_parts.erase(BodyPart.BACK)
		_collision_legs:
			if _colliding_body_parts.has(BodyPart.LEGS):
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

var _parachute_deployed: bool = false
var ground_time: float = 0.5
var _ground_time: float = 0.0
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if !player:
		return
	
	_safety_kite_catenary.end_position = (global_position - _safety_kite_catenary.global_position).rotated(-_safety_kite_catenary.global_rotation)
	
	_safety_parachute_catenary_a.end_position = (global_position - _safety_parachute_catenary_a.global_position).rotated(-_safety_parachute_catenary_a.global_rotation)
	_safety_parachute_catenary_b.end_position = (global_position - _safety_parachute_catenary_b.global_position).rotated(-_safety_parachute_catenary_b.global_rotation)
	_safety_parachute_catenary_c.end_position = (global_position - _safety_parachute_catenary_c.global_position).rotated(-_safety_parachute_catenary_c.global_rotation)
	_safety_parachute_catenary_d.end_position = (global_position - _safety_parachute_catenary_d.global_position).rotated(-_safety_parachute_catenary_d.global_rotation)
	_safety_parachute_catenary_e.end_position = (global_position - _safety_parachute_catenary_e.global_position).rotated(-_safety_parachute_catenary_e.global_rotation)
	_safety_parachute_catenary_f.end_position = (global_position - _safety_parachute_catenary_f.global_position).rotated(-_safety_parachute_catenary_f.global_rotation)
	
	if !is_swinging():
		_turn_direction = signf(_input_move)
		
		_particles_afterimage.emitting = true
		_particles_afterimage.amount_ratio = clampf(remap(linear_velocity.length(), 2000.0, 10000.0, 0.0, 1.0), 0.0, 1.0)
		if _particles_afterimage.amount_ratio < 0.5:
			_particles_afterimage.amount_ratio = 0.0
		_particles_afterimage_material.angle_min = -(180.0 / PI) * global_rotation
		_particles_afterimage_material.angle_max = -(180.0 / PI) * global_rotation
		
		if _input_jump:
			_input_jump = false
			if !_parachute_deployed:
				_parachute_deployed = true
				if is_instance_valid(_safety):
					_safety.freeze = false
					_safety.visible = true
					var groove_joint: GrooveJoint2D = _safety.get_node_or_null("groove_joint_2d") as GrooveJoint2D
					groove_joint.node_b = groove_joint.get_path_to(self)
		
		if _colliding_body_parts.is_empty():
			if _ground_time < ground_time:
				_ground_time += delta
			else:
				_sprite.frame = 3
		else:
			_ground_time = 0.0
			_check_injury(linear_velocity.distance_to(_linear_velocity))
			_sprite.frame = 4
			#print(_colliding_body_parts)
	else:
		_particles_afterimage.emitting = false
		
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
				_sprite.frame = 3
	
	_linear_velocity = linear_velocity

func _check_injury(acceleration: float) -> void:
	if _injury == Injury.DEAD:
		return
	
	if acceleration > 3000.0:
		print("huge impact - death")
		_set_injury(Injury.DEAD)
		_particles_gore.emitting = true
		_sprite.visible = false
	
	if acceleration > 2000.0:
		for body_part: BodyPart in _colliding_body_parts:
			if body_part == BodyPart.HEAD:
				print("large impact - head")
				_set_injury(Injury.COMATOSE_PARAPLEGIC)
			if body_part == BodyPart.FRONT:
				print("large impact - front")
				_set_injury(Injury.PARAPLEGIC)
			if body_part == BodyPart.BACK:
				print("large impact - back")
				_set_injury(Injury.PARAPLEGIC)
			if body_part == BodyPart.LEGS:
				print("large impact - legs")
				_set_injury(Injury.BROKEN_FEMUR)
	
	if acceleration > 1200.0:
		for body_part: BodyPart in _colliding_body_parts:
			if body_part == BodyPart.HEAD:
				print("medium impact - head")
				_set_injury(Injury.COMATOSE)
			if body_part == BodyPart.FRONT:
				print("medium impact - front")
				_set_injury(Injury.HEART_FAILURE)
			if body_part == BodyPart.BACK:
				print("medium impact - back")
				_set_injury(Injury.BROKEN_BACK)
			if body_part == BodyPart.LEGS:
				print("medium impact - legs")
				_set_injury(Injury.BROKEN_LEGS)
	
	if acceleration > 500.0:
		for body_part: BodyPart in _colliding_body_parts:
			if body_part == BodyPart.HEAD:
				print("small impact - head")
				_set_injury(Injury.CONCUSSION)
			if body_part == BodyPart.FRONT:
				print("small impact - front")
				_set_injury(Injury.BROKEN_RIBS)
			if body_part == BodyPart.BACK:
				print("small impact - back")
				_set_injury(Injury.SLIPPED_DISK)
			if body_part == BodyPart.LEGS:
				print("small impact - legs")
				_set_injury(Injury.SPRAINED_ANKLES)
	
