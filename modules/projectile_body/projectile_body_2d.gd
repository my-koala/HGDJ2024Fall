# code by my-koala ͼ•ᴥ•ͽ #
@tool
extends RigidBody2D
class_name ProjectileBody2D

const MG_TO_KG: float = 10 ** 6.0

@export
var drag_size: Vector2 = Vector2(16.0, 24.0)
@export
var drag_coefficient: Vector2 = Vector2(0.5, 0.75)
#@export
var drag_density: float = 1.0
#var drag_density: float = 0.572204589844# Milligrams per cubic pixel.
# TODO (Player): Air density should be calculated as a function of altitude.
# NOTE: Default value is equivalent to air density of 1.2 kg per cubic meter.
# TODO: drag coefficient should scale down with angle (normal check)
# a flat face should have higher coefficient than 45 degree angle

func _init() -> void:
	custom_integrator = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if Engine.is_editor_hint():
		return
	
	# Apply gravity.
	state.linear_velocity += get_gravity() * state.step
	
	# Apply drag.
	if !state.linear_velocity.is_zero_approx():
		var drag_direction: Vector2 = -state.linear_velocity.normalized()
		
		# Calculate surface area "visible" to drag by dotting edge normals with drag direction.
		var edge_x_normal: Vector2 = Vector2(drag_size.x, 0.0).rotated(global_rotation + (PI / 2.0)).normalized()
		var edge_x_fraction: float = absf(drag_direction.dot(edge_x_normal))
		var edge_y_normal: Vector2 = Vector2(0.0, drag_size.y).rotated(global_rotation + (PI / 2.0)).normalized()
		var edge_y_fraction: float = absf(drag_direction.dot(edge_y_normal))
		
		var area: float = (edge_x_fraction * drag_size.x) + (edge_y_fraction * drag_size.y)
		var coeff: float = (edge_x_fraction * drag_coefficient.x) + (edge_y_fraction * drag_coefficient.y)
		
		var density_kg: float = (drag_density / MG_TO_KG)
		
		var drag: Vector2 = drag_direction * (0.5 * coeff * density_kg * state.linear_velocity.length_squared() * area)
		
		var drag_velocity: Vector2 = drag * state.inverse_mass * state.step
		# HACK clamp drag to 99% of velocity because big = infinite feedback. may fix drag properly later or something
		drag_velocity = drag_velocity.limit_length(state.linear_velocity.length() * 0.99)
		
		state.linear_velocity += drag_velocity
