@tool
extends EditorScript

func _run() -> void:
	var coef: Vector2 = Vector2(0.75, 0.25)
	var rot: float = (PI / 4.0) * 0.0
	var dir: Vector2 = -Vector2(1.0, 0.0).normalized()
	print(absf(dir.dot(coef.rotated(rot))))
