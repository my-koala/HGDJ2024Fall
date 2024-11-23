@tool
extends SwingThruster2D

# TODO: make this explode at the end
# like high risk high reward type stuff
# how close can you cut it lol

@onready
var _particles_pop: GPUParticles2D = $sprite_2d/particles_pop as GPUParticles2D
@onready
var _particles_smoke: GPUParticles2D = $sprite_2d/particles_smoke as GPUParticles2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_particles_pop.emitting = false
	_particles_smoke.emitting = false

var _thrust_tween: Tween = null
func activate() -> void:
	if _active:
		return
	_active = true
	
	_particles_pop.emitting = true
	_particles_smoke.emitting = true
	_particles_pop.amount_ratio = 0.0
	_particles_smoke.amount_ratio = 0.0
	
	if is_instance_valid(_thrust_tween) && _thrust_tween.is_valid():
		_thrust_tween.kill()
	_thrust_tween = create_tween()
	_thrust_tween.set_ease(Tween.EASE_IN)
	_thrust_tween.set_trans(Tween.TRANS_QUAD)
	
	_thrust_tween.set_parallel(true)
	_thrust_tween.tween_property(self, "thrust", 4096.0, 5.0)
	_thrust_tween.tween_property(_particles_pop, "amount_ratio", 1.0, 1.0)
	_thrust_tween.tween_property(_particles_smoke, "amount_ratio", 1.0, 1.0)
	
	await _thrust_tween.finished
	thrust = 0.0
	_particles_pop.emitting = false
	_particles_smoke.emitting = false
	_particles_pop.amount_ratio = 1.0
	_particles_smoke.amount_ratio = 1.0
	
	# TODO: explosion
