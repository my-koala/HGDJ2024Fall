@tool
extends Node2D
class_name Hook2D

# hold right click -> "swinging" hook in circle
# also previews hookable distance (and maybe hookable surfaces)
# release right click -> instantly shoot hook
# if attaches in same frame (instant raycast), then hooked
# distance from attach point is then used as the hook length
# 

@export
var hook_chain_scene: PackedScene = preload("hook_chain_2d.tscn")

@export
var enable_draw: bool = false

@export_range(0.0, 1.0, 0.01, "or_greater", "hide_slider")
var length_max: float = 192.0:
	get:
		return length_max
	set(value):
		length_max = maxf(value, 0.0)

@export_flags_2d_physics
var collision_mask: int = 1 << 0
@export_flags_2d_physics
var collision_mask_attachable: int = 1 << 0

var _hooked_length: float = 0.0
var _hooked_collision_object: CollisionObject2D = null
var _hooked_collision_object_offset: Vector2 = Vector2.ZERO
func is_hooked() -> bool:
	return is_instance_valid(_hooked_collision_object)

func get_hooked_position() -> Vector2:
	if !is_hooked():
		return Vector2.ZERO
	return _hooked_collision_object.global_position + _hooked_collision_object_offset

func get_hooked_length() -> float:
	return _hooked_length

func add_length(length: float) -> void:
	if !is_hooked():
		return
	_hooked_length = clampf(_hooked_length + length, 0.0, length_max)

func fire(direction: Vector2) -> void:
	if is_hooked():
		return
	
	var dss: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query_ray: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
	query_ray.collide_with_areas = false
	query_ray.collide_with_bodies = true
	query_ray.collision_mask = collision_mask & collision_mask_attachable
	query_ray.hit_from_inside = false
	query_ray.exclude = []
	query_ray.from = global_position
	query_ray.to = global_position + (direction * length_max)
	
	var result: Dictionary = dss.intersect_ray(query_ray)
	if result.is_empty():
		return
	
	var collision_object: CollisionObject2D = result["collider"] as CollisionObject2D
	var collision_position: Vector2 = result["position"] as Vector2
	if is_instance_valid(collision_object):
		if collision_object.collision_layer & collision_mask_attachable > 0:
			# Attached!
			#_hooked_length = length_max
			_hooked_length = global_position.distance_to(collision_position)
			_hooked_collision_object = collision_object
			_hooked_collision_object_offset = collision_position - collision_object.global_position

func detach() -> void:
	_hooked_collision_object = null

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	queue_redraw()

func _draw() -> void:
	if is_hooked():
		draw_line(Vector2.ZERO, get_hooked_position() - global_position, Color.AQUA)
	
	if !enable_draw:
		return
	
	draw_circle(Vector2.ZERO, length_max, Color.WHITE, false, 1.0)
	
