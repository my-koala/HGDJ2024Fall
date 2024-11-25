@tool
extends Panel

var _active: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	visible = true
	
	# disable stuff initially
	position.y = get_viewport_rect().size.y

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if !_active:
		return
	
	get_viewport().set_input_as_handled()
	
	if event.is_echo() || !event.is_pressed():
		return
	
	if Input.is_anything_pressed():
		set_active(false)

var _active_tween: Tween = null
func set_active(active: bool) -> void:
	if _active == active:
		return
	
	_active = active
	
	if is_instance_valid(_active_tween) && _active_tween.is_valid():
		_active_tween.kill()
	
	_active_tween = create_tween()
	_active_tween.set_ease(Tween.EASE_OUT)
	_active_tween.set_trans(Tween.TRANS_CUBIC)
	_active_tween.set_parallel(true)
	
	var weight: float = position.y / get_viewport_rect().size.y
	if _active:
		_active_tween.tween_property(self, "position:y", 0.0, 0.5 * weight)
	else:
		_active_tween.tween_property(self, "position:y", get_viewport_rect().size.y, 0.5 * (1.0 - weight))
	
