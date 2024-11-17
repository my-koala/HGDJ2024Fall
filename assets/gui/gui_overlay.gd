@tool
extends Control

@export
var texture: Texture2D = null:
	get:
		return texture
	set(value):
		texture = value
		queue_redraw()

@export_group("Animation", "animation_")

@export
var animation_enabled: bool = false

@export_range(1, 16, 1, "or_greater", "hide_slider")
var animation_hframes: int = 1:
	get:
		return animation_hframes
	set(value):
		animation_hframes = value
		queue_redraw()

@export_range(1, 16, 1, "or_greater", "hide_slider")
var animation_vframes: int = 1:
	get:
		return animation_vframes
	set(value):
		animation_vframes = value
		queue_redraw()

@export_range(0, 16, 1, "or_greater", "hide_slider")
var animation_frame: int = 0:
	get:
		return animation_frame
	set(value):
		animation_frame = posmod(value, animation_hframes * animation_vframes)
		queue_redraw()

@export_range(0.0, 1.0, 0.01, "or_greater", "hide_slider")
var animation_frame_time: float = 1.0:
	get:
		return animation_frame_time
	set(value):
		animation_frame_time = maxf(value, 0.0)

var _animation_frame_time: float = 0.0

func _process(delta: float) -> void:
	if !animation_enabled:
		return
	
	_animation_frame_time += delta
	if _animation_frame_time >= animation_frame_time:
		_animation_frame_time = 0.0
		animation_frame += 1
		queue_redraw()

func _draw() -> void:
	if !is_instance_valid(texture):
		return
	
	var frame_size: Vector2 = texture.get_size() / Vector2(float(animation_hframes), float(animation_vframes))
	var frame_x: int = animation_frame % animation_hframes
	var frame_y: int = animation_frame / animation_hframes
	var rect: Rect2 = Rect2(frame_size * Vector2(float(frame_x), float(frame_y)), frame_size)
	draw_texture_rect_region(texture, Rect2(Vector2.ZERO, frame_size), rect, Color.WHITE, false, true)
