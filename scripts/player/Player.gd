extends CharacterBody2D

var base_speed: float = 300.0 
var max_hp: int = 100
var current_hp: int = 100
var is_dead: bool = false

func _ready():
	primijeni_stats()

func _physics_process(_delta):
	if is_dead:
		return
		
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * base_speed
	move_and_slide()

func primijeni_stats():
	match GameManager.trenutna_klasa:
		GameManager.Klasa.VITEZ:
			max_hp = 150
			base_speed = 200.0 # Slow but tanky
		GameManager.Klasa.SVECENIK:
			max_hp = 100
			base_speed = 250.0 # Medium
		GameManager.Klasa.STAKOR:
			max_hp = 80
			base_speed = 400.0 # Very fast, squishy
		GameManager.Klasa.DIJETE:
			max_hp = 60
			base_speed = 300.0 # Lowest HP, medium speed
			
	current_hp = max_hp

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
	
