extends Button

@onready var icon_rect = $MarginContainer/VBoxContainer/IconRect
@onready var desc_label = $MarginContainer/VBoxContainer/DescLabel

@export var tex_general: Texture2D
@export var tex_knight: Texture2D
@export var tex_priest: Texture2D
@export var tex_rat: Texture2D
@export var tex_child: Texture2D

var upgrade_data: Dictionary

func setup(data: Dictionary) -> void:
	upgrade_data = data
	desc_label.text = data["name"]
	
	match data["rarity"]:
		UpgradeManager.UpgradeRarity.GENERAL:
			self_modulate = Color(0.6, 0.6, 0.6, 1.0)
			icon_rect.texture = tex_general
		UpgradeManager.UpgradeRarity.CLASS_SPECIFIC:
			self_modulate = Color(0.3, 0.6, 1.0, 1.0)
			_set_class_icon(data["class"])
		UpgradeManager.UpgradeRarity.CLASS_MASTER:
			self_modulate = Color(1.0, 0.8, 0.2, 1.0)
			_set_class_icon(data["class"])

func _set_class_icon(cls) -> void:
	match cls:
		GameManager.PlayerClass.KNIGHT: icon_rect.texture = tex_knight
		GameManager.PlayerClass.PRIEST: icon_rect.texture = tex_priest
		GameManager.PlayerClass.RAT: icon_rect.texture = tex_rat
		GameManager.PlayerClass.CHILD: icon_rect.texture = tex_child
		null: icon_rect.texture = tex_general
