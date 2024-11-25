@tool
extends SwingThruster2D

@onready
var _particles_bubble: GPUParticles2D = $sprite_2d/particles_bubble as GPUParticles2D
@onready
var _sound_launch: AudioStreamPlayer2D = $sounds/launch as AudioStreamPlayer2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_particles_bubble.emitting = false

var _thrust_tween: Tween = null
func activate() -> void:
	if _active:
		return
	_active = true
	
	_particles_bubble.emitting = true
	_particles_bubble.amount_ratio = 0.0
	
	if is_instance_valid(_thrust_tween) && _thrust_tween.is_valid():
		_thrust_tween.kill()
	_thrust_tween = create_tween()
	_thrust_tween.set_ease(Tween.EASE_OUT)
	_thrust_tween.set_trans(Tween.TRANS_SINE)
	
	_thrust_tween.set_parallel(true)
	_thrust_tween.tween_property(self, "thrust", 1024.0 + 512.0, 0.5)
	_thrust_tween.tween_property(_particles_bubble, "amount_ratio", 1.0, 0.5)
	
	_thrust_tween.set_parallel(false)
	_thrust_tween.tween_property(self, "thrust", 0.0, 2.0)
	_thrust_tween.set_parallel(true)
	_thrust_tween.tween_property(_particles_bubble, "amount_ratio", 0.0, 2.0)
	
	_sound_launch.play()
	
	await _thrust_tween.finished
	_particles_bubble.emitting = false
	_particles_bubble.amount_ratio = 1.0
