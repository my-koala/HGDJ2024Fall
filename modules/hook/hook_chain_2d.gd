@tool
extends RigidBody2D
class_name HookChain2D

@export
var sprite_frame: int = false:
	get:
		return sprite_frame
	set(value):
		sprite_frame = value
		_sprite.frame = sprite_frame

@onready
var _sprite: Sprite2D = $sprite_2d as Sprite2D
@onready
var _pin_joint: PinJoint2D = $pin_joint_2d as PinJoint2D

func attach(hook_chain: HookChain2D) -> void:
	hook_chain.global_position = _pin_joint.global_position
	_pin_joint.node_b = _pin_joint.get_path_to(hook_chain)

func detach() -> void:
	_pin_joint.node_b = NodePath()
