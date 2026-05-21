extends PanelContainer

@onready var naziv_label = $VBoxContainer/Label
@onready var opis_label = $VBoxContainer/Label2

var upgrade_data: Dictionary

signal upgrade_odabran(upgrade)

func postavi_upgrade(upgrade: Dictionary) -> void:
	upgrade_data = upgrade
	naziv_label.text = upgrade["name"]
	opis_label.text = upgrade["description"]

func _on_pressed() -> void:
	upgrade_odabran.emit(upgrade_data)s
