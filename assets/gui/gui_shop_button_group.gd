@tool
extends Button

@export
var item_group: StringName = &""

@onready
var _label_title: Label = $title as Label
@onready
var _label_subtitle: Label = $subtitle as Label
@onready
var _label_item_icon: TextureRect = $item_icon as TextureRect
@onready
var _label_item_name: Label = $item_name as Label
