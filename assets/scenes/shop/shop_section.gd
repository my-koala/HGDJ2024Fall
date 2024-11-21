@tool
extends Panel

const ShopItemButton: = preload("shop_item_button.gd")

@export
var section: StringName = &""

@export
var item_buttons: Array[ShopItemButton] = []

@onready
var _title: Label = $title as Label
@onready
var _back: Button = $back as Button
@onready
var _container: HBoxContainer = $items/scroll_container/h_box_container as HBoxContainer
