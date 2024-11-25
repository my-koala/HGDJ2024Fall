@tool
extends SwingThruster2D

# TODO: make this explode at the end
# like high risk high reward type stuff
# how close can you cut it lol

const Player: = preload("res://assets/actors/player/player.gd")

@onready
var _particles_pop: GPUParticles2D = $particles_pop as GPUParticles2D
@onready
var _particles_smoke: GPUParticles2D = $particles_smoke as GPUParticles2D
@onready
var _particles_firework: GPUParticles2D = $particles_firework as GPUParticles2D
@onready
var _sprite: Sprite2D = $sprite_2d as Sprite2D
@onready
var _area: Area2D = $area_2d as Area2D

@onready
var _sound_firework_launch: AudioStreamPlayer2D = $sounds/firework_launch as AudioStreamPlayer2D
@onready
var _sound_firework_explode: AudioStreamPlayer2D = $sounds/firework_explode as AudioStreamPlayer2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_sprite.visible = true
	_area.monitoring = false
	_particles_pop.emitting = false
	_particles_smoke.emitting = false
	_particles_firework.emitting = false
	
	_area.body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if is_instance_valid(player):
		player.explode()

var _thrust_tween: Tween = null
func activate() -> void:
	if _active:
		return
	_active = true
	
	_sprite.visible = true
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
	_thrust_tween.tween_property(self, "thrust", 2048.0 + 1024.0, 5.0)
	_thrust_tween.tween_property(_particles_pop, "amount_ratio", 1.0, 1.0)
	_thrust_tween.tween_property(_particles_smoke, "amount_ratio", 1.0, 1.0)
	
	_sound_firework_launch.play()
	
	await _thrust_tween.finished
	thrust = 0.0
	_particles_pop.emitting = false
	_particles_smoke.emitting = false
	_particles_pop.amount_ratio = 1.0
	_particles_smoke.amount_ratio = 1.0
	
	_sound_firework_launch.stop()
	_sound_firework_explode.play()
	
	_particles_firework.emitting = true
	_sprite.visible = false
	# TODO: explosion area
	_area.monitoring = true
	await get_tree().physics_frame
	await get_tree().physics_frame
	_area.monitoring = false
