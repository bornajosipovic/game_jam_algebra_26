extends CanvasLayer

@export var upgrade_card_scene: PackedScene

@onready var card1 = $Control/Button
@onready var card2 = $Control/Button2
@onready var card3 = $Control/Button3

var ponudeni_upgradi: Array = []

func prikazi() -> void:
	visible = true
	ponudeni_upgradi = UpgradeManager.get_random_upgrades(3)
	postavi_karticu(card1, ponudeni_upgradi[0])
	postavi_karticu(card2, ponudeni_upgradi[1])
	postavi_karticu(card3, ponudeni_upgradi[2])

func postavi_karticu(button: Button, upgrade: Dictionary) -> void:
	button.text = upgrade["name"] + "\n" + upgrade["description"]

func _on_Button_pressed() -> void:
	odaberi(0)

func _on_Button2_pressed() -> void:
	odaberi(1)

func _on_Button3_pressed() -> void:
	odaberi(2)

func odaberi(index: int) -> void:
	UpgradeManager.apply_upgrade(ponudeni_upgradi[index])
	visible = false
