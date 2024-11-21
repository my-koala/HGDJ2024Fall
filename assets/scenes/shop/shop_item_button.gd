@tool
extends Button

@export
var item: Item = null

@onready
var _label_name: Label = $name as Label
@onready
var _label_subtitle: Label = $subtitle as Label
@onready
var _texture_icon: TextureRect = $icon as TextureRect
@onready
var _label_price: Label = $price as Label
