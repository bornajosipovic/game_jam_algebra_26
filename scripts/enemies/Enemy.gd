class_name Enemy
extends CharacterBody2D

# ---------------------------------------------------------
# Signali
# ---------------------------------------------------------
signal enemy_died(type: Type, pos: Vector2)

# ---------------------------------------------------------
# Tip neprijatelja
# ---------------------------------------------------------
enum Type { HOOLIGAN, BANDIT, DEMON }

@export var enemy_type: Type = Type.HOOLIGAN

# ---------------------------------------------------------
# Stats — override u @export inspekciji za svaku podklasu
# ---------------------------------------------------------
@export var max_hp: int = 3
@export var speed: float = 80.0
@export var detection_range: float = 150.0
@export var contact_damage: int = 1

# ---------------------------------------------------------
# State
# ---------------------------------------------------------
var current_hp: int
var player: CharacterBody2D
var is_dead: bool = false

# ---------------------------------------------------------
# Node refs
# ---------------------------------------------------------
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hitbox: Area2D = $Hitbox

# ---------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------
func _ready() -> void:
	current_hp = max_hp
	player = get_tree().get_first_node_in_group("player")
	hitbox.body_entered.connect(_on_hitbox_body_entered)

# _physics_process namjerno prazan — subklase ga overrideaju
func _physics_process(_delta: float) -> void:
	pass

# ---------------------------------------------------------
# Navigacija
# ---------------------------------------------------------
func move_toward_target(target_pos: Vector2) -> void:
	nav_agent.target_position = target_pos
	if nav_agent.is_navigation_finished():
		return
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	velocity = (next_pos - global_position).normalized() * speed
	move_and_slide()

func stop_moving() -> void:
	velocity = Vector2.ZERO
	move_and_slide()

# ---------------------------------------------------------
# HP i smrt
# ---------------------------------------------------------
func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_hp -= amount
	if current_hp <= 0:
		die()

func die() -> void:
	is_dead = true
	enemy_died.emit(enemy_type, global_position)
	queue_free()

# ---------------------------------------------------------
# Helperi
# ---------------------------------------------------------
func get_player_distance() -> float:
	if player == null:
		player = get_tree().get_first_node_in_group("player") # Pokušaj ga naći ponovno
	if player == null:
		return INF
	return global_position.distance_to(player.global_position)

func is_player_in_detection_range() -> bool:
	return get_player_distance() <= detection_range

func get_direction_to_player() -> Vector2:
	if player == null:
		player = get_tree().get_first_node_in_group("player") # Pokušaj ga naći ponovno
	if player == null:
		return Vector2.ZERO
	return (player.global_position - global_position).normalized()
# ---------------------------------------------------------
# Kontaktni damage na playera
# ---------------------------------------------------------
func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("player"):
		body.take_damage(contact_damage)
		
func get_nav_velocity(target_pos: Vector2) -> Vector2:
	nav_agent.target_position = target_pos
	if nav_agent.is_navigation_finished():
		return Vector2.ZERO
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	return (next_pos - global_position).normalized() * speed
