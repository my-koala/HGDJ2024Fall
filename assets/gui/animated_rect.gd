@tool
extends NinePatchRect

@export_group("Atlas", "atlas_")
@export
var atlas_texture: Texture2D = null:
	get:
		return _texture.atlas
	set(value):
		_texture.atlas = value

@export_range(1, 16, 1, "or_greater", "hide_slider")
var atlas_hframes: int = 1

@export_range(1, 16, 1, "or_greater", "hide_slider")
var atlas_vframes: int = 1

@export_range(0, 16, 1, "or_greater", "hide_slider")
var atlas_frame: int = 0:
	get:
		return atlas_frame
	set(value):
		atlas_frame = posmod(value, atlas_hframes * atlas_vframes)

@export_range(0.0, 1.0, 0.01, "or_greater", "hide_slider")
var atlas_frame_time: float = 1.0:
	get:
		return atlas_frame_time
	set(value):
		atlas_frame_time = maxf(value, 0.0)
var _atlas_frame_time: float = 0.0

var _texture: AtlasTexture = AtlasTexture.new()

func _init() -> void:
	texture = _texture

func _process(delta: float) -> void:
	if !is_instance_valid(_texture.atlas):
		return
	
	_atlas_frame_time += delta
	if _atlas_frame_time >= atlas_frame_time:
		_atlas_frame_time = 0.0
		atlas_frame += 1
	
	var frame_size: Vector2 = _texture.atlas.get_size() / Vector2(float(atlas_hframes), float(atlas_vframes))
	var frame_x: int = atlas_frame % atlas_hframes
	var frame_y: int = atlas_frame / atlas_hframes
	_texture.region.size = frame_size
	_texture.region.position = frame_size * Vector2(float(frame_x), float(frame_y))
