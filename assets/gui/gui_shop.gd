@tool
extends Control

# TODO:
# set focus neighbors, rather than setting focus modes/states
# then grab_focus() manually
# maybe clean up the refresh if possible?
#

const GuiShopSection: = preload("gui_shop_section.gd")
const GUI_SHOP_SECTION: PackedScene = preload("gui_shop_section.tscn")
const GuiShopSectionButton: = preload("gui_shop_section_button.gd")
const GUI_SHOP_SECTION_BUTTON: PackedScene = preload("gui_shop_section_button.tscn")
const GuiShopItemButton: = preload("gui_shop_item_button.gd")
const GUI_SHOP_ITEM_BUTTON: PackedScene = preload("gui_shop_item_button.tscn")

signal exit_home()
signal exit_game()

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

var _menu_group_id: int = 0

var _sections: Array[GuiShopSection] = []
var _section_buttons: Array[GuiShopSectionButton] = []

var _queue_refresh: bool = false
func queue_refresh() -> void:
	_queue_refresh = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_game_data.changed.connect(_on_game_data_changed)
	
	refresh()
	_set_active_section(null)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _queue_refresh:
		refresh()
		_queue_refresh = false

func refresh() -> void:
	_balance.text = "my Money: $%d and %d¢" % [_game_data.get_money_dollars(), _game_data.get_money_cents()]
	
	for item: Item in _game_data.get_items():
		var section: GuiShopSection = null
		for index: int in _sections.size():
			if _sections[index].section == item.section:
				section = _sections[index]
				break
		
		if !is_instance_valid(section):
			# Create section.
			section = GUI_SHOP_SECTION.instantiate() as GuiShopSection
			_section_container.add_child(section)
			section.section = item.section
			section._title.text = item.section
			section._back.pressed.connect(_on_section_back_pressed)
			_sections.append(section)
		
		var section_button: GuiShopSectionButton = null
		for index: int in _section_buttons.size():
			if _section_buttons[index].section == item.section:
				section_button = _section_buttons[index]
				break
		
		if !is_instance_valid(section_button):
			# Create section button.
			section_button = GUI_SHOP_SECTION_BUTTON.instantiate() as GuiShopSectionButton
			_section_button_container.add_child(section_button)
			section_button.section = item.section
			section_button._label_title.text = item.section
			section_button.pressed.connect(_on_section_button_pressed.bind(section_button))
			_section_buttons.append(section_button)
		
		if _game_data.is_item_equipped(item):
			section_button._label_name.text = item.name
			section_button._texture_icon.texture = item.icon
		
		var item_button: GuiShopItemButton = null
		for index: int in section.item_buttons.size():
			if section.item_buttons[index].item == item:
				item_button = section.item_buttons[index]
				break
		
		if !is_instance_valid(item_button):
			# Create item button.
			item_button = GUI_SHOP_ITEM_BUTTON.instantiate() as GuiShopItemButton
			section._container.add_child(item_button)
			item_button.item = item
			item_button.pressed.connect(_on_item_button_pressed.bind(item_button))
			section.item_buttons.append(item_button)
		
		item_button._label_name.text = item.name
		item_button._label_price.text = "$%d and %d¢" % [item.price_dollars, item.price_cents]
		if _game_data.is_item_equipped(item):
			item_button._label_price.text = "Equipped"
			item_button._label_subtitle.text = "(this is equipped)"
		elif _game_data.is_item_purchased(item):
			item_button._label_price.text = "Purchased"
			item_button._label_subtitle.text = "(click to equip)"
		elif _game_data.can_money_withdraw(item.price_dollars, item.price_cents):
			item_button._label_subtitle.text = "(click to buy)"
		else:
			item_button._label_subtitle.text = "(cant buy)"
		item_button._texture_icon.texture = item.icon
		

func _on_item_button_pressed(item_button: GuiShopItemButton) -> void:
	if _game_data.is_item_purchased(item_button.item):
		_game_data.item_equip(item_button.item)
	else:
		_game_data.item_purchase(item_button.item)
		_game_data.item_equip(item_button.item)

func _on_section_button_pressed(section_button: GuiShopSectionButton) -> void:
	var section: GuiShopSection = null
	for index: int in _sections.size():
		if _sections[index].section == section_button.section:
			section = _sections[index]
			break
	_set_active_section(section)

func _on_section_back_pressed() -> void:
	_set_active_section(null)

var _active_section: GuiShopSection = null
var _active_section_tween: Tween = null
func _set_active_section(active_section: GuiShopSection) -> void:
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
	
	for section: GuiShopSection in _sections:
		if section != _active_section || section != active_section:
			section.position.y = size.y
	
	_section_overlay.visible = false
	
	if is_instance_valid(_active_section):
		var duration: float = 0.25 * (1.0 - (_active_section.position.y / size.y))
		_active_section_tween.tween_property(_active_section, "position:y", size.y, duration)
		if !is_instance_valid(active_section):
			duration = 0.25 * (_section_overlay.modulate.a)
			_active_section_tween.tween_property(_section_overlay, "modulate:a", 0.0, duration)
			_active_section_tween.tween_property(_section_overlay, "visible", false, duration)
	
	_active_section = active_section
	
	if is_instance_valid(_active_section):
		_section_overlay.visible = true
		var duration: float = 0.25 * (_active_section.position.y / size.y)
		_active_section_tween.tween_property(_active_section, "position:y", 0.0, duration)
		duration = 0.25 * (1.0 - _section_overlay.modulate.a)
		_active_section_tween.tween_property(_section_overlay, "modulate:a", 1.0, duration)

func _on_game_data_changed() -> void:
	refresh()
