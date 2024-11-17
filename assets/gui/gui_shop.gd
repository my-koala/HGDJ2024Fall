@tool
extends Control

signal exit_home()
signal exit_game()

enum Menu { MAIN, SHOP }
var _menu: Menu = Menu.MAIN
var _shop_id: int = 0

@onready
var _menu_main: Control = $menus/main as Control
@onready
var _menu_main_button_shop_a: Button = $menus/main/shops/button_shop_a as Button
@onready
var _menu_main_button_shop_b: Button = $menus/main/shops/button_shop_b as Button
@onready
var _menu_shop: Control = $menus/shop as Control

var _game_data: GameData = preload("res://assets/game_data/game_data.tres")

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_game_data.changed.connect(_on_game_data_changed)
	
	set_menu(Menu.MAIN)

func _on_game_data_changed() -> void:
	pass
	

func set_menu(menu: Menu) -> void:
	_menu = menu
	match _menu:
		Menu.MAIN:
			pass
			
		Menu.SHOP:
			pass
		
