extends Node2D

signal finished()

const PARTICLE_SCENES: Array[PackedScene] = [
	preload("res://assets/particles/particles_afterimage.tscn"),
	preload("res://assets/particles/particles_bubble.tscn"),
	preload("res://assets/particles/particles_drop.tscn"),
	preload("res://assets/particles/particles_explode.tscn"),
	preload("res://assets/particles/particles_flame.tscn"),
	preload("res://assets/particles/particles_firework.tscn"),
	preload("res://assets/particles/particles_gore.tscn"),
	preload("res://assets/particles/particles_pop.tscn"),
	preload("res://assets/particles/particles_smoke.tscn"),
	preload("res://assets/particles/particles_speed.tscn"),
]

var _frames: int = 16

func start() -> void:
	var frame: int = 0
	while frame < 5:
		frame += 1
		await get_tree().physics_frame
	
	for particle_scene: PackedScene in PARTICLE_SCENES:
		var particles: GPUParticles2D = particle_scene.instantiate() as GPUParticles2D
		add_child(particles)
		particles.amount_ratio = 1.0
		particles.emitting = true
	
	frame = 0
	while frame < _frames:
		frame += 1
		await get_tree().physics_frame
	
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	
	finished.emit()
