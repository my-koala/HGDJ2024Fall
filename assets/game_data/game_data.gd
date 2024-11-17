extends Resource
class_name GameData

# Global game data container.

func _init() -> void:
	print("lul")
	if Engine.is_editor_hint():
		
		return
	

const CENT_TO_DOLLAR: int = 100

var _money_dollars: int = 0
var _money_cents: int = 0

func get_money_dollars() -> int:
	return _money_dollars

func get_money_cents() -> int:
	return _money_cents

func money_deposit(dollars: int, cents: int) -> void:
	dollars = maxi(dollars, 0)
	cents = maxi(cents, 0)
	
	_money_cents += cents
	_money_dollars += dollars + (_money_cents / CENT_TO_DOLLAR)
	_money_cents = _money_cents % CENT_TO_DOLLAR
	
	emit_changed()

func money_withdraw(dollars: int, cents: int) -> void:
	dollars = maxi(dollars, 0)
	cents = maxi(cents, 0)
	
	_money_dollars -= dollars
	_money_cents -= cents
	if _money_cents < 0:
		_money_dollars += (_money_cents / CENT_TO_DOLLAR) - 1
		_money_cents = CENT_TO_DOLLAR + (_money_cents % CENT_TO_DOLLAR)
	if _money_dollars < 0:
		_money_dollars = 0
		_money_cents = 0
	
	emit_changed()

func can_money_withdraw(dollars: int, cents: int) -> bool:
	dollars += cents / CENT_TO_DOLLAR
	cents = cents % CENT_TO_DOLLAR
	return _money_dollars > dollars || ((_money_dollars == dollars) && (cents > _money_cents))

const ITEM_PATH: String = "res://assets/item/items/"


const ITEM_DEFAULT: int = 1 << 0
var _items_purchased: Array[int] = [ITEM_DEFAULT, ITEM_DEFAULT, ITEM_DEFAULT, ITEM_DEFAULT]
var _items_equipped: Array[int] = [ITEM_DEFAULT, ITEM_DEFAULT, ITEM_DEFAULT, ITEM_DEFAULT]

func get_items_purchased(index: int) -> int:
	return _items_purchased[index]

func get_items_equipped(index: int) -> int:
	return _items_equipped[index]

func is_item_purchased(index: int, item: int) -> bool:
	return (_items_purchased[index] & (1 << item)) > 0

func item_purchase(index: int, item: int) -> void:
	_items_purchased[index] |= 1 << item
	emit_changed()

func item_equip(index: int, item: int) -> void:
	if !is_item_purchased(index, item):
		return
	_items_equipped[index] = 1 << item
	emit_changed()
