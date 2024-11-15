@tool
extends StaticBody2D
class_name Tether2D

# Generates at runtime tether segments using pin joints.

@export
var segment_scene: PackedScene = null

@export
var anchor: PhysicsBody2D = null

@onready
var _pin_joint: PinJoint2D = $pin_joint_2d as PinJoint2D

@onready
var _segment_container: Node2D = $segment_container as Node2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	regenerate()

func regenerate() -> void:
	for child: Node in _segment_container.get_children():
		_segment_container.remove_child(child)
		child.queue_free()
	
	if !is_instance_valid(segment_scene):
		return
	
	var node: Node = segment_scene.instantiate()
	if !is_instance_valid(node):
		return
	
	var segment_dummy: TetherSegment2D = node as TetherSegment2D
	if !is_instance_valid(segment_dummy):
		node.queue_free()
		return
	
	if !is_instance_valid(anchor):
		return
	
	var length: float = global_position.distance_to(anchor.global_position)
	#var segment_length: float = segment_dummy.get_length()
	#var segment_count: int = int(length / segment_length)
	
	var pin_joint_prev: PinJoint2D = _pin_joint
	while length > 0.0:
		var segment: TetherSegment2D = segment_scene.instantiate() as TetherSegment2D
		_segment_container.add_child(segment)
		segment.global_position = pin_joint_prev.global_position
		pin_joint_prev.node_b = pin_joint_prev.get_path_to(segment)
		pin_joint_prev = segment._pin_joint
		
		length -= segment.get_length()
	pin_joint_prev.node_b = pin_joint_prev.get_path_to(anchor)
	segment_dummy.queue_free()
