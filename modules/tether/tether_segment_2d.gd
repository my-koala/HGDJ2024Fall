@tool
extends RigidBody2D
class_name TetherSegment2D

@onready
var _pin_joint: PinJoint2D = $pin_joint_2d as PinJoint2D

func get_length() -> float:
	return global_position.distance_to(_pin_joint.global_position)
