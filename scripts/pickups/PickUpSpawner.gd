extends Node

@export var ascension_item_scene: PackedScene
@export var hp_pickup_scene: PackedScene
@export var seconds_pickup_scene: PackedScene
@export var incarnation_pickup_scene: PackedScene

var map_width: float = 1920.0
var map_height: float = 1080.0
var margin: float = 100.0
var center: Vector2

@export var near_radius: float = 250.0
@export var mid_radius: float = 500.0

func _ready() -> void:
	center = Vector2(map_width / 2, map_height / 2)
	GameManager.inkarnacija_started.connect(_on_inkarnacija_started)
	
	# OVO JE NEDOSTAJALO: Ručno pokreni prvu rundu čim se mapa učita!
	call_deferred("_on_inkarnacija_started", GameManager.current_class)
	print("PickupSpawner je spreman i pokreće se!")

func spawn_pickups() -> void:
	# Blizu vatre - samo HP i sekunde
	spawn_in_zone(hp_pickup_scene, 2, 0, near_radius)
	spawn_in_zone(seconds_pickup_scene, 1, 0, near_radius)
	
	# Srednja zona - mijesano
	spawn_in_zone(ascension_item_scene, 4, near_radius, mid_radius)
	spawn_in_zone(hp_pickup_scene, 1, near_radius, mid_radius)
	spawn_in_zone(seconds_pickup_scene, 1, near_radius, mid_radius)
	
	# Daleka zona - najvise ascensiona
	spawn_in_zone(ascension_item_scene, 6, mid_radius, 9999)
	spawn_in_zone(incarnation_pickup_scene, 2, mid_radius, 9999)

func spawn_in_zone(scene: PackedScene, count: int, min_dist: float, max_dist: float) -> void:
	if scene == null: return # Sigurnosna provjera
	
	for i in count:
		var pos = get_position_in_zone(min_dist, max_dist)
		var instance = scene.instantiate()
		instance.position = pos
		add_child(instance) # PROMIJENJENO: Dodaje item kao svoje dijete, a ne od Parenta!

func get_position_in_zone(min_dist: float, max_dist: float, attempts: int = 0) -> Vector2:
	if attempts > 20:
		return center + Vector2(randf_range(-400, 400), randf_range(-400, 400))
	var x = randf_range(margin, map_width - margin)
	var y = randf_range(margin, map_height - margin)
	var pos = Vector2(x, y)
	var dist = pos.distance_to(center)
	if dist < min_dist or dist > max_dist:
		return get_position_in_zone(min_dist, max_dist, attempts + 1)
	return pos
	
func _clear_pickups() -> void:
	# Briše sve stare iteme s mape prije nego stvori nove
	for child in get_children():
		child.queue_free()

func _on_inkarnacija_started(_klasa) -> void:
	_clear_pickups()
	spawn_pickups()
