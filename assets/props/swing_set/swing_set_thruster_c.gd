@tool
extends SwingThruster2D

@onready
var _particles_smoke: GPUParticles2D = $sprite_2d/particles_smoke as GPUParticles2D
@onready
var _particles_flame: GPUParticles2D = $sprite_2d/particles_flame as GPUParticles2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_particles_flame.emitting = false
	_particles_smoke.emitting = false

var _thrust_tween: Tween = null
func activate() -> void:
	if _active:
		return
	_active = true
	
	_particles_flame.emitting = true
	_particles_smoke.emitting = true
	
	if is_instance_valid(_thrust_tween) && _thrust_tween.is_valid():
		_thrust_tween.kill()
	_thrust_tween = create_tween()
	_thrust_tween.set_ease(Tween.EASE_IN)
	_thrust_tween.set_trans(Tween.TRANS_QUINT)
	_thrust_tween.set_parallel(false)
	
	_thrust_tween.tween_property(self, "thrust", 16384.0, 2.0)
