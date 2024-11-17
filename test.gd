@tool
extends EditorScript

func _run() -> void:
	var coef: Vector2 = Vector2(0.75, 0.25)
	var rot: float = (PI / 4.0) * 0.0
	var dir: Vector2 = -Vector2(1.0, 0.0).normalized()
	#print(absf(dir.dot(coef.rotated(rot))))
	
	
	var game_data: GameData = GameData.new()
	game_data.money_deposit(13, 172)
	print(str(game_data.get_money_dollars()) + " " + str(game_data.get_money_cents()))
	game_data.money_withdraw(2, 219)
	print(str(game_data.get_money_dollars()) + " " + str(game_data.get_money_cents()))
