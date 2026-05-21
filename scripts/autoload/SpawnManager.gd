extends Node2D

# ---------------------------------------------------------
# Scene reference za svaki enemy tip
# ---------------------------------------------------------
const HOOLIGAN_SCENE = preload("res://scenes/enemies/Hooligan.tscn")
const BANDIT_SCENE   = preload("res://scenes/enemies/Bandit.tscn")
const DEMON_SCENE    = preload("res://scenes/enemies/Demon.tscn")

# ---------------------------------------------------------
# Broj enemija po tipu
# ---------------------------------------------------------
const HOOLIGAN_COUNT := 4
const BANDIT_COUNT   := 4
const DEMON_COUNT    := 2

# ---------------------------------------------------------
# Spawn pravila
# ---------------------------------------------------------
const MAP_WIDTH       := 1920.0
const MAP_HEIGHT      := 1080.0
const MIN_DIST_PLAYER := 200.0
const MIN_DIST_FIRE   := 150.0

# ---------------------------------------------------------
# Node reference
# ---------------------------------------------------------
@export var enemy_root: Node2D
@export var player_spawn: Marker2D
@export var vjecna_vatra: Node2D

# ---------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------
func _ready() -> void:
	GameManager.inkarnacija_started.connect(_on_inkarnacija_started)
	call_deferred("_on_inkarnacija_started", GameManager.current_class)
	print("SpawnManager je uspješno inicijaliziran i pokreće prvi spawn!")
	
	
# ---------------------------------------------------------
# Signal handler
# ---------------------------------------------------------
func _on_inkarnacija_started(_klasa) -> void:
	_clear_enemies()
	_spawn_all()

# ---------------------------------------------------------
# Spawn logika
# ---------------------------------------------------------
func _spawn_all() -> void:
	# Kvadranti — mapa podijeljena na 4 jednaka dijela
	var quadrants: Array[Rect2] = [
		Rect2(0,              0,               MAP_WIDTH / 2, MAP_HEIGHT / 2),  # gore lijevo
		Rect2(MAP_WIDTH / 2,  0,               MAP_WIDTH / 2, MAP_HEIGHT / 2),  # gore desno
		Rect2(0,              MAP_HEIGHT / 2,  MAP_WIDTH / 2, MAP_HEIGHT / 2),  # dolje lijevo
		Rect2(MAP_WIDTH / 2,  MAP_HEIGHT / 2,  MAP_WIDTH / 2, MAP_HEIGHT / 2),  # dolje desno
	]

	# Hooligani — jedan po kvadrantu
	for i in range(HOOLIGAN_COUNT):
		var pos: Vector2 = _get_valid_position(quadrants[i])
		var hooligan = HOOLIGAN_SCENE.instantiate()
		hooligan.quadrant = quadrants[i]
		hooligan.global_position = pos
		enemy_root.add_child(hooligan)

	# Banditi — jedan po kvadrantu
	for i in range(BANDIT_COUNT):
		var pos: Vector2 = _get_valid_position(quadrants[i])
		var bandit = BANDIT_SCENE.instantiate()
		bandit.quadrant = quadrants[i]
		bandit.global_position = pos
		enemy_root.add_child(bandit)

	# Demoni — nasumična pozicija, bez kvadranta
	for i in range(DEMON_COUNT):
		var pos: Vector2 = _get_valid_position(Rect2(0, 0, MAP_WIDTH, MAP_HEIGHT))
		var demon = DEMON_SCENE.instantiate()
		demon.global_position = pos
		enemy_root.add_child(demon)

# ---------------------------------------------------------
# Brisanje enemija iz prethodne inkarnacije
# ---------------------------------------------------------
func _clear_enemies() -> void:
	for enemy in enemy_root.get_children():
		enemy.queue_free()

# ---------------------------------------------------------
# Traži validnu poziciju unutar zadanog područja
# ---------------------------------------------------------
func _get_valid_position(area: Rect2) -> Vector2:
	var attempts: int = 0
	while attempts < 100:
		var pos: Vector2 = Vector2(
			randf_range(area.position.x, area.end.x),
			randf_range(area.position.y, area.end.y)
		)
		if _is_position_valid(pos):
			return pos
		attempts += 1

	# Fallback — vraća središte područja ako ne nađe validnu poziciju
	return area.get_center()

func _is_position_valid(pos: Vector2) -> bool:
	var dist_player: float = pos.distance_to(player_spawn.global_position)
	var dist_fire: float   = pos.distance_to(vjecna_vatra.global_position)
	return dist_player >= MIN_DIST_PLAYER and dist_fire >= MIN_DIST_FIRE
