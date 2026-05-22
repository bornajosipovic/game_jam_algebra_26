extends CanvasLayer

@export var upgrade_card_scene: PackedScene
@onready var cards_container = $Control/HBoxContainer

func _ready() -> void:
	GameManager.show_upgrade_screen.connect(prikazi)
	visible = false

func prikazi() -> void:
	visible = true
	var ponudeni_upgradi = UpgradeManager.get_random_upgrades(3)
	
	# Ovdje sada pozivamo novu funkciju koja sama stvara kartice
	populate_cards(ponudeni_upgradi)

func populate_cards(upgrades_array: Array) -> void:
	# Prvo očistimo kontejner u slučaju da su ostale kartice od prošlog puta
	for child in cards_container.get_children():
		child.queue_free()
		
	# Zatim instanciramo novu karticu za svaki upgrade koji smo izvukli
	for upg in upgrades_array:
		var card = upgrade_card_scene.instantiate()
		cards_container.add_child(card)
		card.setup(upg)
		card.pressed.connect(_on_card_pressed.bind(upg))

func _on_card_pressed(upgrade: Dictionary) -> void:
	UpgradeManager.apply_upgrade(upgrade)
	visible = false
