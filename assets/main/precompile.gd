extends Node

signal done()

var _frames: int = 5

var materials: Array[ParticleProcessMaterial] = [
	preload("res://assets/actors/player/player_particles_explode.tres")
]

func _ready() -> void:
	await(get_tree().physics_frame)
	for material: ParticleProcessMaterial in materials:
		var particles: GPUParticles2D = GPUParticles2D.new()
		particles.process_material = material
		particles.one_shot = true
		particles.emitting = true
		add_child(particles)

func _physics_process(delta: float) -> void:
	if _frames >= 0:
		_frames -= 1
	else:
		_done()

func _done() -> void:
	done.emit()
	queue_free()
