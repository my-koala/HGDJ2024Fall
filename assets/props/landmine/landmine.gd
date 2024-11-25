extends Area2D

const Player: = preload("res://assets/actors/player/player.gd")
const EXPLOSION_TEXTURES_FOLDER: String = "res://assets/props/landmine/explosion_out/"
var _explosion_textures: Array[Texture2D] = []

@onready
var _explosion_sprite: Sprite2D = $explosion as Sprite2D
@onready
var _explosion_particles: GPUParticles2D = $particles_explode as GPUParticles2D
@onready
var _sprite: Sprite2D = $sprite_2d as Sprite2D
@onready
var _sound_explosion: AudioStreamPlayer2D = $sounds/explosion as AudioStreamPlayer2D

func _init() -> void:
	if Engine.is_editor_hint():
		return
	
	var file_names: PackedStringArray = DirAccess.get_files_at(EXPLOSION_TEXTURES_FOLDER)
	for file_name: String in file_names:
		var texture: Texture2D = ResourceLoader.load(EXPLOSION_TEXTURES_FOLDER + file_name.replace(".import", "")) as Texture2D
		_explosion_textures.append(texture)
	

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	body_entered.connect(_on_body_entered)
	
	_explosion_sprite.texture = null

func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if is_instance_valid(player):
		player.explode()
		explode()

var _explosion_frame: int = 0
var _explosion_fps: float = 240.0
var _explosion_fps_delta: float = 0.0
var _explosion: bool = false

func explode() -> void:
	_sprite.visible = false
	_explosion_particles.emitting = true
	_explosion = true
	_sound_explosion.play()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if !_explosion:
		return
	
	var explode_fps_delta: float = 1.0 / _explosion_fps
	_explosion_fps_delta += delta
	while _explosion_fps_delta > explode_fps_delta:
		_explosion_fps_delta -= explode_fps_delta
		_explosion_frame += 1
		if _explosion_frame >= _explosion_textures.size():
			_explosion = false
	
	if _explosion:
		_explosion_sprite.texture = _explosion_textures[_explosion_frame]
