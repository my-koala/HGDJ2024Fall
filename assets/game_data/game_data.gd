extends Resource
class_name GameData

# Global game data container.

@export
var _items: Array[Item] = []:
	get:
		return _items
	set(value):
		_items = value
		_init_items()

var _items_purchased: Array[bool] = []
var _items_equipped: Array[bool] = []

func _init_items() -> void:
	_items_purchased.resize(_items.size())
	_items_purchased.fill(false)
	_items_equipped.resize(_items.size())
	_items_equipped.fill(false)
	# purchase and equip all free items
	for item: Item in _items:
		if (item.price_dollars + item.price_cents) <= 0:
			item_purchase(item)
			item_equip(item)

const CENT_TO_DOLLAR: int = 100

@export
var _money_dollars: int = 0
@export
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
	return _money_dollars > dollars || ((_money_dollars == dollars) && (cents >= _money_cents))

func get_items() -> Array[Item]:
	return _items

func get_items_purchased() -> Array[Item]:
	var items_purchased: Array[Item] = []
	for index: int in _items.size():
		if _items_purchased[index]:
			items_purchased.append(_items[index])
	return items_purchased

func is_item_purchased(item: Item) -> bool:
	var index: int = _items.find(item)
	if index == -1:
		return false
	return _items_purchased[index]

func is_item_equipped(item: Item) -> bool:
	var index: int = _items.find(item)
	if index == -1:
		return false
	return _items_equipped[index]

func item_purchase(item: Item) -> void:
	var index: int = _items.find(item)
	if index == -1:
		return
	if !can_money_withdraw(item.price_dollars, item.price_cents):
		return
	money_withdraw(item.price_dollars, item.price_cents)
	_items_purchased[index] = true
	emit_changed()

func item_equip(item: Item) -> void:
	var index: int = _items.find(item)
	if index == -1:
		return
	if !_items_purchased[index]:
		return
	_items_equipped[index] = true
	# find other items in section and unequip
	for index2: int in _items.size():
		if _items[index2] == item:
			continue
		if _items[index2].section == item.section:
			_items_equipped[index2] = false
	emit_changed()
