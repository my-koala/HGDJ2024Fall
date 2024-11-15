@tool
extends Node2D
class_name Catenary2D

@export
var texture: Texture2D = null

@export
var texture_offset: Vector2 = Vector2.ZERO

@export_range(0, 24, 1, "or_greater", "hide_slider")
var segments: int = 16:
	get:
		return segments
	set(value):
		segments = maxi(value, 0)
		queue_redraw()

@export
var length: float = 256.0:
	get:
		return length
	set(value):
		length = value
		queue_redraw()

@export
var end_position: Vector2 = Vector2.ZERO:
	get:
		return end_position
	set(value):
		end_position = value
		queue_redraw()

func _process(delta: float) -> void:
	queue_redraw()

func coth(x: float) -> float:
	return cosh(x) / sinh(x)

# todo: some math here LOL

func _draw() -> void:
	if end_position.length_squared() >= length * length:
		# Draw line.
		draw_line(Vector2.ZERO, end_position, Color.BLUE, 1.0)
		return
	elif is_zero_approx(end_position.x):
		# Draw half line.
		draw_line(Vector2.ZERO, Vector2(0.0, length / 2.0), Color.BLUE, 1.0)
		return
	
	# Catenary math. 90% of development time went into this.
	var delta: Vector2 = Vector2(absf(end_position.x), -end_position.y)
	
	const Interval: float = 1.0
	var c: float = sqrt((length * length) - (delta.y * delta.y))
	var a_min: float = 0.0
	var a_max: float = 1.0
	var i: int = 0
	
	while i < 32 && c < (2.0 * a_max * sinh(delta.x / (2.0 * a_max))):
		i += 1
		a_min = a_max
		a_max *= 2.0
	
	i += 16
	var a: float = 0.0
	while i > 0:
		i -= 1
		a = (a_min + a_max) * 0.5
		if c < 2.0 * a * sinh(delta.x / (2.0 * a)):
			a_min = a
		else:
			a_max = a
	
	var p: float = (delta.x - a * log((length + delta.y) / (length - delta.y))) / 2.0
	var q: float = (delta.y - length * 1.0 / tanh(delta.x / (2.0 * a))) / 2.0
	
	var segment_prev: Vector2 = Vector2.ZERO
	
	for segment: int in segments:
		var weight: float = float(segment + 1) / float(segments)
		var x: float = weight * delta.x
		var y: float = a * cosh((x - p) / a) + q
		
		var end_point: Vector2 = Vector2(weight * end_position.x, -y)
		
		draw_line(segment_prev, end_point, Color.RED, 1.0)
		segment_prev = end_point
	
	if is_instance_valid(texture):
		var texture_rect: Rect2 = Rect2(texture_offset, texture.get_size())
		
		draw_texture_rect(texture, texture_rect, true, Color.WHITE, false)
	
	
