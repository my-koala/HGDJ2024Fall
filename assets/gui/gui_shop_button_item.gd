@tool
extends Button

@export
var item: Item = null

@onready
var _label_price: Label = $price as Label
@onready
var _label_subtitle: Label = $subtitle as Label
@onready
var _label_item_name: Label = $item_name as Label
@onready
var _label_item_icon: TextureRect = $item_icon as TextureRect
