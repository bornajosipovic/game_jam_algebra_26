extends Node2D

const HOOLIGAN_SCENE = preload("res://scenes/enemies/Hooligan.tscn")
const BANDIT_SCENE   = preload("res://scenes/enemies/Bandit.tscn")
const DEMON_SCENE    = preload("res://scenes/enemies/Demon.tscn")

const BASE_HOOLIGAN_COUNT := 5
const BASE_BANDIT_COUNT   := 4
const BASE_DEMON_COUNT    := 5

@export var map_width: float = 10000.0
@export var map_height: float = 10000.0

const MIN_DIST_PLAYER := 2000.0
const MIN_DIST_FIRE   := 2500.0
@export var min_enemy_spacing: float = 1200.0

@export var enemy_root: Node2D
@export var player_spawn: Marker2D
@export var vjecna_vatra: Node2D

var spawned_positions: Array[Vector2] = []

func _ready() -> void:
	GameManager.inkarnacija_started.connect(_on_inkarnacija_started)
	GameManager.show_upgrade_screen.connect(_clear_enemies)

func _on_inkarnacija_started(_klasa) -> void:
	_clear_enemies()
	_spawn_all()

func _get_wave_counts() -> Dictionary:
	var wave = GameManager.total_incarnations_completed
	var bonus = int(floor(wave / 3.0))
	return {
		"hooligan": BASE_HOOLIGAN_COUNT + bonus,
		"bandit":   BASE_BANDIT_COUNT   + bonus,
		"demon":    BASE_DEMON_COUNT    + bonus,
	}

func _get_hp_multiplier() -> float:
	var wave = GameManager.total_incarnations_completed
	return 1.0 + (wave * 0.05)

func _get_speed_multiplier() -> float:
	var wave = GameManager.total_incarnations_completed
	return min(1.0 + (wave * 0.03), 2.0)

func _spawn_all() -> void:
	spawned_positions.clear()

	var counts    = _get_wave_counts()
	var hp_mult   = _get_hp_multiplier()
	var spd_mult  = _get_speed_multiplier()

	# --- DEBUG ---
	var wave = GameManager.total_incarnations_completed
	print("========================================")
	print("[SpawnManager] VAL: ", wave)
	print("[SpawnManager] --- NEPRIJATELJI ---")
	print("[SpawnManager]   Hooligani: ", counts["hooligan"], " | HP mult: x", snappedf(hp_mult, 0.01), " | Speed mult: x", snappedf(spd_mult, 0.01))
	print("[SpawnManager]   Banditi:   ", counts["bandit"],   " | HP mult: x", snappedf(hp_mult, 0.01), " | Speed mult: x", snappedf(spd_mult, 0.01))
	print("[SpawnManager]   Demoni:    ", counts["demon"],    " | HP mult: x", snappedf(hp_mult, 0.01), " | Speed mult: x", snappedf(spd_mult, 0.01))
	print("[SpawnManager]   Hooligan efektivni HP:  ", int(ceil(3  * hp_mult)), " | speed: ", snappedf(800.0  * spd_mult, 1.0))
	print("[SpawnManager]   Demon efektivni HP:     ", int(ceil(10 * hp_mult)), " | speed: ", snappedf(900.0  * spd_mult, 1.0))
	print("[SpawnManager]   Bandit efektivni HP:    ", int(ceil(2  * hp_mult)))
	print("[SpawnManager] --- SPAWN ZONA ---")
	print("[SpawnManager]   player_spawn pos: ", player_spawn.global_position if player_spawn else "NULL")
	print("[SpawnManager]   vjecna_vatra pos: ", vjecna_vatra.global_position if vjecna_vatra else "NULL")
	print("========================================")
	# --- END DEBUG ---

	var center = Vector2.ZERO
	if vjecna_vatra:
		center = vjecna_vatra.global_position

	var half_w = map_width / 2.0
	var half_h = map_height / 2.0

	var quadrants: Array[Rect2] = [
		Rect2(center.x - half_w, center.y - half_h, half_w, half_h),
		Rect2(center.x,          center.y - half_h, half_w, half_h),
		Rect2(center.x - half_w, center.y,          half_w, half_h),
		Rect2(center.x,          center.y,           half_w, half_h),
	]

	for i in range(counts["hooligan"]):
		var pos: Vector2 = _get_valid_position(quadrants[i % 4])
		var hooligan = HOOLIGAN_SCENE.instantiate()
		hooligan.quadrant = quadrants[i % 4]
		hooligan.global_position = pos
		hooligan.hp_multiplier = hp_mult
		hooligan.speed_multiplier = spd_mult
		enemy_root.add_child(hooligan)

	for i in range(counts["bandit"]):
		var pos: Vector2 = _get_valid_position(quadrants[i % 4])
		var bandit = BANDIT_SCENE.instantiate()
		bandit.quadrant = quadrants[i % 4]
		bandit.global_position = pos
		bandit.hp_multiplier = hp_mult
		bandit.speed_multiplier = spd_mult
		enemy_root.add_child(bandit)

	var full_map = Rect2(center.x - half_w, center.y - half_h, map_width, map_height)
	for i in range(counts["demon"]):
		var pos: Vector2 = _get_valid_position(full_map)
		var demon = DEMON_SCENE.instantiate()
		demon.global_position = pos
		demon.hp_multiplier = hp_mult
		demon.speed_multiplier = spd_mult
		enemy_root.add_child(demon)

func _clear_enemies() -> void:
	spawned_positions.clear()
	for enemy in enemy_root.get_children():
		enemy.queue_free()

func _get_valid_position(area: Rect2) -> Vector2:
	var attempts: int = 0

	while attempts < 500:
		var pos: Vector2 = Vector2(
			randf_range(area.position.x, area.end.x),
			randf_range(area.position.y, area.end.y)
		)

		if _is_position_valid(pos):
			spawned_positions.append(pos)
			return pos

		attempts += 1

	var fallback = area.get_center()
	spawned_positions.append(fallback)
	return fallback

func _is_position_valid(pos: Vector2) -> bool:
	if not player_spawn or not vjecna_vatra:
		return true

	var dist_player: float = pos.distance_to(player_spawn.global_position)
	var dist_fire: float   = pos.distance_to(vjecna_vatra.global_position)

	if dist_player < MIN_DIST_PLAYER or dist_fire < MIN_DIST_FIRE:
		return false

	for p in spawned_positions:
		if pos.distance_to(p) < min_enemy_spacing:
			return false

	return true
