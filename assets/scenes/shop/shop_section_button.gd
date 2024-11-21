@tool
extends Button

@export
var section: StringName = &""

@onready
var _label_title: Label = $title as Label
@onready
var _label_subtitle: Label = $subtitle as Label
@onready
var _texture_icon: TextureRect = $icon as TextureRect
@onready
var _label_name: Label = $name as Label
