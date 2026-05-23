extends Node

@export var ascension_item_scene: PackedScene
@export var seconds_pickup_scene: PackedScene
@export var incarnation_pickup_scene: PackedScene

@export var vjecna_vatra: Node2D

@export var map_width: float = 20000.0
@export var map_height: float = 10000.0
@export var margin: float = 150.0

@export var near_radius: float = 5000.0
@export var mid_radius: float = 8000.0
@export var far_radius: float = 11000.0
@export var min_item_spacing: float = 5000.0

var center: Vector2
var spawned_positions: Array[Vector2] = []

func _ready() -> void:
	GameManager.inkarnacija_started.connect(_on_inkarnacija_started)
	GameManager.show_upgrade_screen.connect(_clear_pickups)

func spawn_pickups() -> void:
	if vjecna_vatra:
		center = vjecna_vatra.global_position
	else:
		center = Vector2.ZERO

	# Near zone (2500 - near_radius): time pickups + a seed ascension
	spawn_in_zone(seconds_pickup_scene,     6, 2500.0,      near_radius)
	spawn_in_zone(ascension_item_scene,     4, 2500.0,      near_radius)
	spawn_in_zone(incarnation_pickup_scene, 3, 2500.0,      near_radius)

	# Mid zone (near_radius - mid_radius): main ascension cluster + time pickups
	spawn_in_zone(ascension_item_scene,     6, near_radius, mid_radius)
	spawn_in_zone(seconds_pickup_scene,     4, near_radius, mid_radius)
	spawn_in_zone(incarnation_pickup_scene, 4, near_radius, mid_radius)

	# Far zone (mid_radius - far_radius): ascensions + incarnation pickups
	spawn_in_zone(ascension_item_scene,     5, mid_radius,  far_radius)
	spawn_in_zone(incarnation_pickup_scene, 3, mid_radius,  far_radius)

	# --- DEBUG ---
	print("========================================")
	print("[PickUpSpawner] center: ", center, " | min_item_spacing: ", min_item_spacing)
	print("[PickUpSpawner] Spawned ", spawned_positions.size(), " itema:")
	for i in spawned_positions.size():
		var p = spawned_positions[i]
		var dist_center = snappedf(p.distance_to(center), 1.0)
		print("[PickUpSpawner]   [", i, "] pos: ", p, " | dist od centra: ", dist_center)
	print("[PickUpSpawner] --- MIN DISTANCE IZMEĐU ITEMA ---")
	var min_found := INF
	var min_pair := ""
	for i in spawned_positions.size():
		for j in spawned_positions.size():
			if i >= j: continue
			var d = spawned_positions[i].distance_to(spawned_positions[j])
			if d < min_found:
				min_found = d
				min_pair = str(i) + " i " + str(j)
	print("[PickUpSpawner]   Najmanji razmak: ", snappedf(min_found, 1.0), " (između itema ", min_pair, ")")
	print("========================================")
	# --- END DEBUG ---

func spawn_in_zone(scene: PackedScene, count: int, min_dist: float, max_dist: float) -> void:
	if scene == null:
		return
	for i in count:
		var pos = get_position_in_zone(min_dist, max_dist)
		spawned_positions.append(pos)
		var instance = scene.instantiate()
		instance.position = pos
		add_child(instance)

func get_position_in_zone(min_dist: float, max_dist: float, attempts: int = 0) -> Vector2:
	var half_width  = map_width  / 2.0
	var half_height = map_height / 2.0

	var min_x = center.x - half_width  + margin
	var max_x = center.x + half_width  - margin
	var min_y = center.y - half_height + margin
	var max_y = center.y + half_height - margin

	var pos: Vector2
	var inner_attempts := 0

	# Generate a random point within the map rectangle that is also
	# within [min_dist, max_dist] from center (distance check, no clamping)
	while inner_attempts < 200:
		pos = Vector2(
			randf_range(min_x, max_x),
			randf_range(min_y, max_y)
		)
		var d = pos.distance_to(center)
		if d >= min_dist and d <= max_dist:
			break
		inner_attempts += 1

	# Spacing check — retry the whole thing if too close to existing item
	if attempts < 200:
		for p in spawned_positions:
			if pos.distance_to(p) < min_item_spacing:
				return get_position_in_zone(min_dist, max_dist, attempts + 1)

	return pos

func _clear_pickups() -> void:
	spawned_positions.clear()
	for child in get_children():
		child.queue_free()

func _on_inkarnacija_started(_klasa) -> void:
	_clear_pickups()
	# Čekamo 2 framea da budu sigurni da su sve pozicije u sceni ispravno postavljene
	await get_tree().process_frame
	await get_tree().process_frame
	spawn_pickups()
