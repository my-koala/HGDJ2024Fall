@tool
extends StaticBody2D

# TODO: modify to generate on ready instead

const TetherSegment2D: = preload("tether_segment_2d.gd")

# Helper script to generate series of tether segments connected by pin joints.

@export
var tether_segment_scene: PackedScene = null

@export
var clear: bool = false:
	get:
		return false
	set(value):
		clear = false
		if Engine.is_editor_hint():
			_clear()

@export
var generate: bool = false:
	get:
		return false
	set(value):
		generate = false
		if Engine.is_editor_hint():
			_clear()
			_generate()

@export
var segments: int = 16

@export
var pin_joint: PinJoint2D = null

@export
var anchor: PhysicsBody2D = null

func _clear() -> void:
	pin_joint.node_b = NodePath()
	
	var segment_container: Node = get_node_or_null("segment_container")
	if is_instance_valid(segment_container):
		remove_child(segment_container)
		segment_container.queue_free()

func _generate() -> void:
	if !is_instance_valid(tether_segment_scene):
		return
	
	if is_instance_valid(owner):
		owner.set_editable_instance(self, true)
	
	var segment_container: Node2D = Node2D.new()
	segment_container.name = "segment_container"
	add_child(segment_container, true)
	segment_container.owner = get_tree().edited_scene_root
	if segment_container.name != &"segment_container":
		remove_child(segment_container)
		segment_container.queue_free()
		return
	
	var anchor_pin_joint: PinJoint2D = pin_joint
	for segment: int in segments:
		var scene: Node = tether_segment_scene.instantiate()
		if !is_instance_valid(scene):
			return
		
		var tether_segment: TetherSegment2D = scene as TetherSegment2D
		if !is_instance_valid(tether_segment):
			scene.queue_free()
			return
		
		segment_container.add_child(tether_segment, true)
		tether_segment.owner = get_tree().edited_scene_root
		
		set_editable_instance(tether_segment, true)
		
		tether_segment.global_position = anchor_pin_joint.global_position
		anchor_pin_joint.node_b = anchor_pin_joint.get_path_to(tether_segment.physics_body)
		anchor_pin_joint = tether_segment.pin_joint
	
	if is_instance_valid(anchor):
		anchor_pin_joint.node_b = anchor_pin_joint.get_path_to(anchor)
