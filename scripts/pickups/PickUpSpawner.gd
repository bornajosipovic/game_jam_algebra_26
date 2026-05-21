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
	for i in count:
		var pos = get_position_in_zone(min_dist, max_dist)
		var instance = scene.instantiate()
		instance.position = pos
		get_parent().add_child(instance)

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
