@tool
extends Control

const GUI_SHOP_BUTTON_GROUP: PackedScene = preload("gui_shop_button_group.tscn")
const GuiShopButtonGroup: = preload("gui_shop_button_group.gd")

signal exit_home()
signal exit_game()

@export
var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

@onready
var _menu_main: Control = $menus/main as Control
@onready
var _menu_shop: Control = $menus/shop as Control
@onready
var _menu_main_groups_container: GridContainer = $menus/main/panel_groups/grid_container as GridContainer

enum Menu { MAIN, SHOP }
var _menu: Menu = Menu.MAIN
var _shop_id: int = 0

var _button_groups: Array[GuiShopButtonGroup] = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_game_data.changed.connect(_on_game_data_changed)
	
	var item_groups: Array[StringName] = []
	for item: Item in _game_data.get_items():
		if !item_groups.has(item.group):
			item_groups.append(item.group)
			var button_group: GuiShopButtonGroup = GUI_SHOP_BUTTON_GROUP.instantiate() as GuiShopButtonGroup
			button_group.item_group = item.group
			button_group.pressed.connect(_on_button_group_pressed.bind(null))
			_menu_main_groups_container.add_child(button_group)
		
	
	
	set_menu(Menu.MAIN)

func _on_button_group_pressed(gui_shop_group: Control) -> void:
	pass

func _on_game_data_changed() -> void:
	pass
	

func set_menu(menu: Menu) -> void:
	_menu = menu
	match _menu:
		Menu.MAIN:
			pass
			
		Menu.SHOP:
			pass
		
