extends CharacterBody2D

# --- STATS ---
var base_speed: float = 300.0 
var max_hp: int = 100
var current_hp: int = 100
var is_dead: bool = false
var can_basic_attack: bool = true
var last_direction: Vector2 = Vector2.RIGHT

# --- NODE REFERENCES ---
@onready var weapon_pivot = $WeaponPivot
@onready var basic_melee_area = $WeaponPivot/BasicMeleeArea
@onready var shoot_point = $WeaponPivot/ShootPoint

func _ready():
	apply_stats()
	# Ensure the hitbox is turned off when the game starts
	if basic_melee_area:
		basic_melee_area.monitoring = false
	add_to_group("player")

func _physics_process(_delta):
	if is_dead:
		return
		
	# Movement
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * base_speed
	move_and_slide()
	
	# Only update the aiming direction if the player is actively pressing a key
	if direction != Vector2.ZERO:
		last_direction = direction.normalized()
		
	# Rotate the weapon pivot to match the angle of the last direction
	if weapon_pivot:
		weapon_pivot.rotation = last_direction.angle()

func _input(event):
	if is_dead: 
		return
		
	# BASIC ATTACK (Left Click)
	if event.is_action_pressed("attack") and can_basic_attack:
		execute_basic_attack()

func apply_stats():
	# Matches the active class from GameManager
	match GameManager.current_class:
		GameManager.PlayerClass.KNIGHT:
			max_hp = 150
			base_speed = 200.0 # Slow but tanky
		GameManager.PlayerClass.PRIEST:
			max_hp = 100
			base_speed = 250.0 # Medium
		GameManager.PlayerClass.RAT:
			max_hp = 80
			base_speed = 400.0 # Very fast, squishy
		GameManager.PlayerClass.CHILD:
			max_hp = 60
			base_speed = 300.0 # Lowest HP, medium speed
			
	current_hp = max_hp

func execute_basic_attack():
	can_basic_attack = false
	
	match GameManager.current_class:
		GameManager.PlayerClass.KNIGHT:
			print("Knight basic swing!")
			basic_melee_area.monitoring = true
			await get_tree().create_timer(0.1).timeout
			basic_melee_area.monitoring = false
			await get_tree().create_timer(0.3).timeout
			can_basic_attack = true
			
		GameManager.PlayerClass.RAT:
			print("Rat quick bite!")
			basic_melee_area.monitoring = true
			await get_tree().create_timer(0.1).timeout
			basic_melee_area.monitoring = false
			await get_tree().create_timer(0.15).timeout 
			can_basic_attack = true
			
		GameManager.PlayerClass.PRIEST:
			print("Priest shoots magic! (Projectile needed)")
			await get_tree().create_timer(0.5).timeout
			can_basic_attack = true
			
		GameManager.PlayerClass.CHILD:
			print("Child throws rock! (Projectile needed)")
			await get_tree().create_timer(0.4).timeout
			can_basic_attack = true

func take_damage(amount: int):
	if is_dead: 
		return
	current_hp -= amount
	print("Player took damage! Current HP: ", current_hp)
	if current_hp <= 0:
		die()

func die():
	is_dead = true
	print("Player Died!")
	GameManager.player_died.emit() 
	
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
func heal(amount: int):
	if is_dead:
		return
	current_hp += amount
	if current_hp > max_hp:
		current_hp = max_hp
	print("Healed, current health: ", current_hp)

func _on_basic_melee_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not body == self:
		print("Basic melee hit an enemy!")
		body.take_damage(50)
