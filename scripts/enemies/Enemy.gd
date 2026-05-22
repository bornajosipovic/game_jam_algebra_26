class_name Enemy
extends CharacterBody2D

signal enemy_died(type: Type, pos: Vector2)

enum Type { HOOLIGAN, BANDIT, DEMON }

@export var enemy_type: Type = Type.HOOLIGAN

@export var max_hp: int = 3
@export var speed: float = 80.0
@export var detection_range: float = 150.0
@export var contact_damage: int = 1

var current_hp: int
var player: CharacterBody2D
var is_dead: bool = false
var original_speed: float = 0.0
var is_slowed: bool = false
var slow_timer: float = 0.0

# Set by SpawnManager before add_child; applied in apply_wave_scaling()
var hp_multiplier: float = 1.0
var speed_multiplier: float = 1.0

# Hit stun
var is_stunned: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hitbox: Area2D = $Hitbox
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	match enemy_type:
		Type.HOOLIGAN:
			max_hp = 50
		Type.BANDIT:
			max_hp = 50
		Type.DEMON:
			max_hp = 100
	current_hp = max_hp
	player = get_tree().get_first_node_in_group("player")
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	call_deferred("apply_wave_scaling")

func apply_wave_scaling() -> void:
	max_hp = int(ceil(max_hp * hp_multiplier))
	current_hp = max_hp
	speed = speed * speed_multiplier

func _physics_process(_delta: float) -> void:
	pass

func move_toward_target(target_pos: Vector2) -> void:
	if is_stunned:
		return
	nav_agent.target_position = target_pos
	if nav_agent.is_navigation_finished():
		return
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	velocity = (next_pos - global_position).normalized() * speed
	move_and_slide()

func stop_moving() -> void:
	velocity = Vector2.ZERO
	move_and_slide()

func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_hp -= amount
	if current_hp <= 0:
		die()
	else:
		play_hit_feedback()

func play_hit_feedback() -> void:
	if is_dead:
		return

	is_stunned = true

	if player:
		var knockback_dir = (global_position - player.global_position).normalized()
		velocity = knockback_dir * 300.0
		move_and_slide()

	var tween = create_tween()
	animated_sprite.modulate = Color.RED
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.15)

	await get_tree().create_timer(0.15).timeout
	if not is_dead:
		is_stunned = false

func die() -> void:
	is_dead = true
	is_stunned = false

	# Flash red on death then free
	if animated_sprite:
		animated_sprite.modulate = Color.RED

	enemy_died.emit(enemy_type, global_position)
	GameManager.enemy_died.emit(enemy_type)

	await get_tree().create_timer(0.12).timeout
	queue_free()

func get_player_distance() -> float:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		return INF
	return global_position.distance_to(player.global_position)

func is_player_in_detection_range() -> bool:
	return get_player_distance() <= detection_range

func get_direction_to_player() -> Vector2:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		return Vector2.ZERO
	return (player.global_position - global_position).normalized()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("player"):
		body.take_damage(contact_damage)
		_play_contact_flash()

func _play_contact_flash() -> void:
	# Brief white flash on enemy when it hits the player
	if is_dead:
		return
	var tween = create_tween()
	animated_sprite.modulate = Color.WHITE * 3.0
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

func get_nav_velocity(target_pos: Vector2) -> Vector2:
	nav_agent.target_position = target_pos
	if nav_agent.is_navigation_finished():
		return Vector2.ZERO
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	return (next_pos - global_position).normalized() * speed

func _process(delta: float) -> void:
	if is_slowed and not is_dead:
		slow_timer -= delta
		if slow_timer <= 0.0:
			speed = original_speed
			is_slowed = false

func apply_slow(multiplier: float, duration: float) -> void:
	if is_dead:
		return
	if is_slowed:
		slow_timer = duration
		return
	is_slowed = true
	original_speed = speed
	speed = original_speed * multiplier
	slow_timer = duration
