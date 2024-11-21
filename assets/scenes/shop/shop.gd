@tool
extends Control

# TODO: i think everything is done
# TODO: need sound effects (cash register, cant buy, 

const ShopSection: = preload("shop_section.gd")
const SHOP_SECTION: PackedScene = preload("shop_section.tscn")
const ShopSectionButton: = preload("shop_section_button.gd")
const SHOP_SECTION_BUTTON: PackedScene = preload("shop_section_button.tscn")
const ShopItemButton: = preload("shop_item_button.gd")
const SHOP_ITEM_BUTTON: PackedScene = preload("shop_item_button.tscn")

signal exit_home()
signal exit_play()

@export
var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

@onready
var _section_button_container: GridContainer = $section_button_container/grid_container as GridContainer
@onready
var _section_overlay: ColorRect = $section_overlay as ColorRect
@onready
var _section_container: Control = $section_container as Control
@onready
var _balance: Label = $bottom/balance as Label
@onready
var _ready_button: Button = $right/ready as Button
@onready
var _home_button: Button = $left/home as Button

var _menu_group_id: int = 0

var _sections: Array[ShopSection] = []
var _section_buttons: Array[ShopSectionButton] = []

var _queue_refresh: bool = false
func queue_refresh() -> void:
	_queue_refresh = true

var _scene_active: bool = false
func scene_start() -> void:
	_scene_active = true
	queue_refresh()
	_set_active_section(null)

func scene_stop() -> void:
	_scene_active = false
	_set_active_section(null)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_game_data.changed.connect(_on_game_data_changed)
	_ready_button.pressed.connect(_on_ready_button_pressed)
	_home_button.pressed.connect(_on_home_button_pressed)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _queue_refresh:
		refresh()
		_queue_refresh = false

func refresh() -> void:
	_balance.text = "my Money: $%d and %d¢" % [_game_data.get_money_dollars(), _game_data.get_money_cents()]
	
	for item: Item in _game_data.get_items():
		var section: ShopSection = null
		for index: int in _sections.size():
			if _sections[index].section == item.section:
				section = _sections[index]
				break
		
		if !is_instance_valid(section):
			# Create section.
			section = SHOP_SECTION.instantiate() as ShopSection
			_section_container.add_child(section)
			section.section = item.section
			section._title.text = item.section
			section._back.pressed.connect(_on_section_back_pressed)
			_sections.append(section)
		
		var section_button: ShopSectionButton = null
		for index: int in _section_buttons.size():
			if _section_buttons[index].section == item.section:
				section_button = _section_buttons[index]
				break
			
		if !is_instance_valid(section_button):
			# Create section button.
			section_button = SHOP_SECTION_BUTTON.instantiate() as ShopSectionButton
			_section_button_container.add_child(section_button)
			section_button.section = item.section
			section_button._label_title.text = item.section
			section_button.pressed.connect(_on_section_button_pressed.bind(section_button))
			_section_buttons.append(section_button)
		
		if _game_data.is_item_equipped(item):
			section_button._label_name.text = item.name
			section_button._texture_icon.texture = item.icon
		
		var item_button: ShopItemButton = null
		for _item_button: ShopItemButton in section.item_buttons:
			if _item_button.item == item:
				item_button = _item_button
		
		if !is_instance_valid(item_button):
			# Create item button.
			item_button = SHOP_ITEM_BUTTON.instantiate() as ShopItemButton
			section._container.add_child(item_button)
			item_button.item = item
			item_button.pressed.connect(_on_item_button_pressed.bind(item_button))
			section.item_buttons.append(item_button)
		
		item_button._label_name.text = item.name
		item_button._label_price.text = "$%d and %d¢" % [item.price_dollars, item.price_cents]
		if _game_data.is_item_equipped(item):
			item_button._label_price.text = "Equipped"
			item_button._label_subtitle.text = "(this is equipped)"
			item_button._label_subtitle.modulate = Color(0.0, 0.0, 0.0, 0.75)
		elif _game_data.is_item_purchased(item):
			item_button._label_price.text = "Owned"
			item_button._label_subtitle.text = "(click to equip)"
			item_button._label_subtitle.modulate = Color(0.0, 0.5, 0.0, 0.75)
		elif _game_data.can_money_withdraw(item.price_dollars, item.price_cents):
			item_button._label_subtitle.text = "(click to buy)"
			item_button._label_subtitle.modulate = Color(0.0, 0.5, 0.0, 0.75)
		else:
			item_button._label_subtitle.text = "(cant buy)"
			item_button._label_subtitle.modulate = Color(1.0, 0.0, 0.0, 0.75)
		item_button._texture_icon.texture = item.icon
	
	for section_button: ShopSectionButton in _section_buttons:
		var size_col: int = mini(_section_button_container.columns, _section_buttons.size())
		var size_row: int = ceili(float(_section_buttons.size()) / float(size_col))
		
		var index: int = _section_buttons.find(section_button)
		var is_left: bool = (index % size_col) == 0
		var is_right: bool = ((index + size_col - 1) % size_col) == 0
		is_right = is_right || ((index + size_col - 1) >= _section_buttons.size())
		var is_top: bool = (index - size_col) < 0
		var is_bottom: bool = (index + size_col) >= (_section_buttons.size())
		
		if is_left:
			section_button.focus_neighbor_left = section_button.get_path_to(_home_button)
		else:
			section_button.focus_neighbor_left = section_button.get_path_to(_section_buttons[index - 1])
		if is_right:
			section_button.focus_neighbor_right = section_button.get_path_to(_ready_button)
		else:
			section_button.focus_neighbor_right = section_button.get_path_to(_section_buttons[index + 1])
		if is_top:
			section_button.focus_neighbor_top = section_button.get_path_to(section_button)
		else:
			section_button.focus_neighbor_top = section_button.get_path_to(_section_buttons[index - size_col])
		if is_bottom:
			section_button.focus_neighbor_bottom = section_button.get_path_to(section_button)
		else:
			section_button.focus_neighbor_bottom = section_button.get_path_to(_section_buttons[index + size_col])
		section_button.focus_next = section_button.get_path_to(_ready_button)
		section_button.focus_previous = section_button.get_path_to(section_button)
	
	for section: ShopSection in _sections:
		if section.item_buttons.is_empty():
			section._back.focus_neighbor_left = section._back.get_path_to(section._back)
			section._back.focus_neighbor_right = section._back.get_path_to(section._back)
			section._back.focus_neighbor_bottom = section._back.get_path_to(section._back)
			section._back.focus_neighbor_top = section._back.get_path_to(section._back)
			section._back.focus_next = section._back.get_path_to(section._back)
			section._back.focus_previous = section._back.get_path_to(section._back)
		else:
			section._back.focus_neighbor_left = section._back.get_path_to(section._back)
			section._back.focus_neighbor_right = section._back.get_path_to(section._back)
			section._back.focus_neighbor_bottom = section._back.get_path_to(section.item_buttons[0])
			section._back.focus_neighbor_top = section._back.get_path_to(section._back)
			section._back.focus_next = section._back.get_path_to(section.item_buttons[0])
			section._back.focus_previous = section._back.get_path_to(section._back)
		for index: int in section.item_buttons.size():
			var item_button: ShopItemButton = section.item_buttons[index]
			var is_left: bool = index == 0
			var is_right: bool = index == (section.item_buttons.size() - 1)
			if is_left:
				item_button.focus_neighbor_left = item_button.get_path_to(item_button)
			else:
				item_button.focus_neighbor_left = item_button.get_path_to(section.item_buttons[index - 1])
			if is_right:
				item_button.focus_neighbor_right = item_button.get_path_to(item_button)
			else:
				item_button.focus_neighbor_right = item_button.get_path_to(section.item_buttons[index + 1])
			item_button.focus_neighbor_bottom = item_button.get_path_to(item_button)
			item_button.focus_neighbor_top = item_button.get_path_to(section._back)
			item_button.focus_next = item_button.get_path_to(section._back)
			item_button.focus_previous = item_button.get_path_to(section._back)
	
	var ready_button_left: Node = _ready_button
	if !_section_buttons.is_empty():
		ready_button_left = _section_buttons[mini(_section_button_container.columns, _section_buttons.size()) - 1]
	_ready_button.focus_neighbor_left = _ready_button.get_path_to(ready_button_left)
	_ready_button.focus_neighbor_right = _ready_button.get_path_to(_ready_button)
	_ready_button.focus_neighbor_top = _ready_button.get_path_to(_ready_button)
	_ready_button.focus_neighbor_bottom = _ready_button.get_path_to(_ready_button)
	_ready_button.focus_next = _ready_button.get_path_to(_ready_button)
	_ready_button.focus_previous = _ready_button.get_path_to(ready_button_left)
	
	var home_button_right: Node = _home_button
	if !_section_buttons.is_empty():
		home_button_right = _section_buttons[0]
	_home_button.focus_neighbor_left = _home_button.get_path_to(_home_button)
	_home_button.focus_neighbor_right = _home_button.get_path_to(home_button_right)
	_home_button.focus_neighbor_top = _home_button.get_path_to(_home_button)
	_home_button.focus_neighbor_bottom = _home_button.get_path_to(_home_button)
	_home_button.focus_next = _home_button.get_path_to(home_button_right)
	_home_button.focus_previous = _home_button.get_path_to(_home_button)

func _on_item_button_pressed(item_button: ShopItemButton) -> void:
	if _game_data.is_item_purchased(item_button.item):
		_game_data.item_equip(item_button.item)
	else:
		_game_data.item_purchase(item_button.item)
		_game_data.item_equip(item_button.item)

func _on_section_button_pressed(section_button: ShopSectionButton) -> void:
	var section: ShopSection = null
	for index: int in _sections.size():
		if _sections[index].section == section_button.section:
			section = _sections[index]
			break
	_set_active_section(section)

func _on_section_back_pressed() -> void:
	_set_active_section(null)

var _active_section: ShopSection = null
var _active_section_tween: Tween = null
func _set_active_section(active_section: ShopSection) -> void:
	if is_instance_valid(active_section) && !_sections.has(active_section):
		push_error("wtf")
		return
	
	if is_instance_valid(_active_section_tween) && _active_section_tween.is_valid():
		_active_section_tween.kill()
	_active_section_tween = create_tween()
	_active_section_tween.set_parallel(true)
	_active_section_tween.tween_interval(1.0)
	_active_section_tween.set_ease(Tween.EASE_IN_OUT)
	_active_section_tween.set_trans(Tween.TRANS_CUBIC)
	
	for section: ShopSection in _sections:
		if section != _active_section && section != active_section:
			section.position.y = size.y
	
	if _scene_active:
		_ready_button.grab_focus.call_deferred()
		if !_section_buttons.is_empty():
			_section_buttons[0].grab_focus.call_deferred()
	
	_section_overlay.visible = false
	
	if is_instance_valid(_active_section):
		_section_overlay.visible = true
		var duration: float = 0.25 * (1.0 - (_active_section.position.y / size.y))
		_active_section_tween.tween_property(_active_section, "position:y", size.y, duration)
		if !is_instance_valid(active_section):
			duration = 0.25 * (_section_overlay.modulate.a)
			_active_section_tween.tween_property(_section_overlay, "modulate:a", 0.0, duration)
			_active_section_tween.tween_property(_section_overlay, "visible", false, duration)
		# find corresponding section button and focus
		if _scene_active:
			for section_button: ShopSectionButton in _section_buttons:
				if section_button.section == _active_section.section:
					section_button.grab_focus.call_deferred()
					break
	
	_active_section = active_section
	
	if is_instance_valid(_active_section):
		_section_overlay.visible = true
		if _scene_active:
			_active_section._back.grab_focus.call_deferred()
			if !_active_section.item_buttons.is_empty():
				_active_section.item_buttons[0].grab_focus.call_deferred()
		var duration: float = 0.25 * (_active_section.position.y / size.y)
		_active_section_tween.tween_property(_active_section, "position:y", 0.0, duration)
		duration = 0.25 * (1.0 - _section_overlay.modulate.a)
		_active_section_tween.tween_property(_section_overlay, "modulate:a", 1.0, duration)
	

func _on_ready_button_pressed() -> void:
	exit_play.emit()

func _on_home_button_pressed() -> void:
	exit_home.emit()

func _on_game_data_changed() -> void:
	refresh()
