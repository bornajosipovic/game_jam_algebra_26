extends CharacterBody2D


var base_speed: float = 300.0 
var max_hp: int = 100
var current_hp: int = 100
var is_dead: bool = false
var can_basic_attack: bool = true
var last_direction: Vector2 = Vector2.RIGHT
var current_melee_damage: int = 50
var can_special_attack: bool = true
var priest_slow_multiplier: float = 0.5
var priest_aura_duration: float = 3.0
var damage_multiplier: float = 1.0
var cooldown_multiplier: float = 1.0
var pickup_range_multiplier: float = 1.0

var knight_special_scale: float = 1.0
var child_max_dashes: int = 1
var rat_frenzy_damage: int = 0

var is_frenzy_active: bool = false
var is_immune: bool = false

var is_dashing: bool = false
var dashes_left: int = 1
var dash_speed_multiplier: float = 3.0



@export var projectile_scene: PackedScene
@export_group("Class Placeholders")
@export var texture_knight: Texture2D
@export var texture_priest: Texture2D
@export var texture_rat: Texture2D
@export var texture_child: Texture2D
@onready var weapon_pivot = $WeaponPivot
@onready var basic_melee_area = $WeaponPivot/BasicMeleeArea
@onready var shoot_point = $ShootPoint
@onready var sprite = $Sprite2D
@onready var special_aoe_area = $SpecialAoeArea


func _ready():
	apply_stats()
	# Ensure the hitbox is turned off when the game starts
	if basic_melee_area:
		basic_melee_area.monitoring = false
	if special_aoe_area:
		special_aoe_area.monitoring = false
	add_to_group("player")
	GameManager.upgrade_selected.connect(_on_upgrade_selected)

func _physics_process(_delta):
	if is_dead:
		return
		
	if is_frenzy_active:
		# ŠTAKOR FRENZY: Samo skreće, brzina je konstantna
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_dir != Vector2.ZERO:
			last_direction = input_dir.normalized()
		velocity = last_direction * base_speed
	elif is_dashing:
		velocity = last_direction * (base_speed * dash_speed_multiplier)
	else:
		# NORMALNO WASD KRETANJE
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = direction * base_speed
		if direction != Vector2.ZERO:
			last_direction = direction.normalized()
			
	move_and_slide()
		
	# Rotate the weapon pivot to match the angle of the last direction
	if weapon_pivot:
		weapon_pivot.rotation = last_direction.angle()

func _input(event):
	if is_dead: 
		return
		
	# BASIC ATTACK (Left Click)
	if event.is_action_pressed("attack") and can_basic_attack:
		execute_basic_attack()
	if event.is_action_pressed("special_attack") and can_special_attack:
		execute_special_attack()

func apply_stats():
	# 1. Reset varijabli pri svakom spawnu
	damage_multiplier = 1.0
	cooldown_multiplier = 1.0
	pickup_range_multiplier = 1.0
	knight_special_scale = 1.0
	priest_slow_multiplier = 0.5 
	child_max_dashes = 1
	rat_frenzy_damage = 0
	is_frenzy_active = false
	is_immune = false
	is_dashing = false
	dashes_left = child_max_dashes
	if special_aoe_area: special_aoe_area.scale = Vector2(1.0, 1.0)
	
	# 2. Bazni statovi (tvoj postojeći kod)
	match GameManager.current_class:
		GameManager.PlayerClass.KNIGHT:
			max_hp = 150
			base_speed = 200.0
			current_melee_damage = 50
			if basic_melee_area: basic_melee_area.scale = Vector2(1.0, 1.0)
			if texture_knight and sprite:
				sprite.texture = texture_knight
		GameManager.PlayerClass.PRIEST:
			max_hp = 100
			base_speed = 250.0
			if texture_priest and sprite:
				sprite.texture = texture_priest
		GameManager.PlayerClass.RAT:
			max_hp = 80
			base_speed = 400.0
			current_melee_damage = 15
			if basic_melee_area: basic_melee_area.scale = Vector2(0.5, 0.5)
			if texture_rat and sprite:
				sprite.texture = texture_rat
		GameManager.PlayerClass.CHILD:
			max_hp = 60
			base_speed = 300.0
			if texture_child and sprite:
				sprite.texture = texture_child
			
	var my_upgrades = UpgradeManager.get_active_upgrades_for_class(GameManager.current_class)
	for upg in my_upgrades:
		apply_single_upgrade(upg, false)
		
	if GameManager.current_class == GameManager.PlayerClass.CHILD:
		dashes_left = child_max_dashes
		
	current_hp = max_hp

func _on_upgrade_selected(upgrade: Dictionary):
	apply_single_upgrade(upgrade, true)

func apply_single_upgrade(upgrade: Dictionary, is_new: bool = false):
	match upgrade["stat"]:
		"speed":
			base_speed *= (1.0 + upgrade["value"])
		"hp":
			max_hp = int(max_hp * (1.0 + upgrade["value"]))
			if is_new: current_hp = max_hp
		"dmg":
			damage_multiplier *= (1.0 + upgrade["value"])
		"range":
			pickup_range_multiplier *= (1.0 + upgrade["value"])
		"cooldown":
			cooldown_multiplier *= (1.0 + upgrade["value"])
		"timer":
			if is_new: GameManager.add_seconds(upgrade["value"])
		"master":
			match upgrade["id"]:
				"cm_knight":
					knight_special_scale = 1.5
					if special_aoe_area: special_aoe_area.scale = Vector2(knight_special_scale, knight_special_scale)
				"cm_priest":
					priest_slow_multiplier = 0.0
				"cm_child":
					child_max_dashes = 2
				"cm_rat":
					rat_frenzy_damage = 999

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
			print("Priest shoots magic!")
			if projectile_scene:
				var proj = projectile_scene.instantiate()
				proj.damage = 30
				proj.speed=600.0
				proj.global_position = shoot_point.global_position
				proj.direction = (get_global_mouse_position() - shoot_point.global_position).normalized()
				get_tree().root.add_child(proj)
			await get_tree().create_timer(0.7).timeout
			can_basic_attack = true
			
		GameManager.PlayerClass.CHILD:
			print("Child throws rock!")
			if projectile_scene:
				var proj = projectile_scene.instantiate()
				proj.damage = 10
				proj.speed=900.0
				proj.global_position = shoot_point.global_position
				proj.direction = (get_global_mouse_position() - shoot_point.global_position).normalized()
				get_tree().root.add_child(proj)
			await get_tree().create_timer(0.4).timeout
			can_basic_attack = true


func execute_special_attack():
	can_special_attack = false
	
	match GameManager.current_class:
		GameManager.PlayerClass.KNIGHT:
			print("Vitez koristi MASIVNI SWEEP!")
			if special_aoe_area:
				# Upali hitbox na 0.2 sekunde
				special_aoe_area.monitoring = true
				await get_tree().create_timer(0.2).timeout
				special_aoe_area.monitoring = false
			
			# Dugačak cooldown od 2 sekunde
			await get_tree().create_timer(2.0).timeout
			can_special_attack = true
			print("Vitezov special spreman!")
			
		GameManager.PlayerClass.PRIEST:
			print("Svecenik pali auru! (Kolega B treba sloziti usporavanje)")
			# Kasnije ćemo ovdje dodati logiku za paljenje aure
			await get_tree().create_timer(1.5).timeout
			can_special_attack = true
			
		GameManager.PlayerClass.RAT:
			print("Stakor Frenzy Mode!")
			is_frenzy_active = true
			var temp_base_speed = base_speed
			base_speed *= 2
			if rat_frenzy_damage == 999: # Ako ima upgrade, daj mu imunost
				is_immune = true
				
			if special_aoe_area:
				special_aoe_area.scale = Vector2(0.5, 0.5)
				special_aoe_area.monitoring = true
				
			await get_tree().create_timer(3.0).timeout
			base_speed = temp_base_speed
			is_frenzy_active = false
			is_immune = false
			if special_aoe_area: special_aoe_area.monitoring = false
			
			await get_tree().create_timer(5.0 * cooldown_multiplier).timeout
			can_special_attack = true
			
		GameManager.PlayerClass.CHILD:
			if dashes_left <= 0: return # Osigurač
			
			print("Dijete koristi Dash!")
			is_dashing = true
			is_immune = true # Pali I-frames (koristi istu imunost kao Štakor!)
			dashes_left -= 1
			
			# Dash traje jako kratko (0.2 sekunde)
			await get_tree().create_timer(0.2).timeout
			
			is_dashing = false
			is_immune = false # Gasi I-frames
			
			# Ako imamo još dasheva, odmah otključaj tipku Space za idući dash
			if dashes_left > 0:
				can_special_attack = true
				
			# Pokreni proces vraćanja ovog potrošenog dasha u pozadini
			punjenje_dasha()
			
func punjenje_dasha():
	# Cooldown za vraćanje 1 dasha je npr. 1.5 sekundi
	await get_tree().create_timer(1.5 * cooldown_multiplier).timeout
	
	if dashes_left < child_max_dashes:
		dashes_left += 1
		print("Dash napunjen! Preostalo: ", dashes_left)
		
	# Čim imamo barem 1 dash, tipka Space opet radi
	if dashes_left > 0:
		can_special_attack = true


func take_damage(amount: int):
	if is_dead or is_immune: 
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
		body.take_damage(current_melee_damage)


func _on_special_aoe_area_body_entered(body: Node2D) -> void:
	if body == self: return
	if GameManager.current_class == GameManager.PlayerClass.KNIGHT:
		if body.has_method("take_damage"):
			print("Vitezov sweep pogodio neprijatelja!")
			body.take_damage(999)
	if GameManager.current_class == GameManager.PlayerClass.PRIEST:
		if body.has_method("apply_slow"):
			print("Neprijatelj uhvaćen u auru! Multiplier: ", priest_slow_multiplier)
			body.apply_slow(priest_slow_multiplier, priest_aura_duration)
	if GameManager.current_class == GameManager.PlayerClass.RAT and is_frenzy_active:
		if body.has_method("take_damage") and rat_frenzy_damage > 0:
			print("Štakor zgazio neprijatelja!")
			body.take_damage(rat_frenzy_damage)
