extends Control

@onready var label: Label = $VBoxContainer/Label

func _ready() -> void:
	visible = false

func show_message(text: String, color: Color) -> void:
	visible = true
	label.text = text
	label.modulate = color
