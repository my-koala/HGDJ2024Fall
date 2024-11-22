@tool
extends SwingThruster2D

var _thrust_tween: Tween = null
func activate() -> void:
	if _active:
		return
	_active = true
	
	if is_instance_valid(_thrust_tween) && _thrust_tween.is_valid():
		_thrust_tween.kill()
	_thrust_tween = create_tween()
	_thrust_tween.set_ease(Tween.EASE_OUT)
	_thrust_tween.set_trans(Tween.TRANS_SINE)
	_thrust_tween.set_parallel(false)
	
	_thrust_tween.tween_property(self, "thrust", 1024.0, 0.5)
	_thrust_tween.tween_property(self, "thrust", 0.0, 2.0)
