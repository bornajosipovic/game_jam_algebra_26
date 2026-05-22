extends Control

const GAME_SCENE: String = "res://scenes/world/World.tscn"

func _ready() -> void:
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
