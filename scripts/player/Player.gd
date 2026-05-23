extends CharacterBody2D

var base_speed: float = 300.0 
var armor_multiplier: float = 1.0
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

@onready var aura_visual = $SpecialAoeArea/AuraVisual
@onready var weapon_pivot = $WeaponPivot
@onready var basic_melee_area = $WeaponPivot/BasicMeleeArea
@onready var shoot_point = $ShootPoint
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var special_aoe_area = $SpecialAoeArea

@onready var sfx_player = $SfxPlayer

@export_group("Player Sounds")
@export var sfx_hit: AudioStream
@export var sfx_die: AudioStream
@export var sfx_die_rat: AudioStream
@export var sfx_attack_knight: AudioStream
@export var sfx_attack_priest: AudioStream
@export var sfx_attack_rat: AudioStream
@export var sfx_attack_child: AudioStream
@export var sfx_rat_frenzy: AudioStream
@export var sfx_child_dash: AudioStream
@export var sfx_knight_swirl: AudioStream
@export var sfx_priest_aura: AudioStream


func _ready():
	GameManager.inkarnacija_started.connect(_on_inkarnacija_started)
	GameManager.show_upgrade_screen.connect(_on_show_upgrade_screen)
	
	is_dead = true
	visible = false
	if basic_melee_area: basic_melee_area.monitoring = false
	if special_aoe_area: special_aoe_area.monitoring = false
	$CollisionShape2D.set_deferred("disabled", true)
	add_to_group("player")

func _physics_process(_delta):
	if is_dead:
		return
		
	if is_frenzy_active:
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_dir != Vector2.ZERO:
			last_direction = input_dir.normalized()
		velocity = last_direction * base_speed
	elif is_dashing:
		velocity = last_direction * (base_speed * dash_speed_multiplier)
	else:
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = direction * base_speed
		if direction != Vector2.ZERO:
			last_direction = direction.normalized()
			
	move_and_slide()

	var h_input = Input.get_axis("move_left", "move_right")
	if sprite and h_input != 0.0:
		sprite.flip_h = h_input < 0

	# Animation state
	_update_animation(velocity)

	if weapon_pivot:
		weapon_pivot.rotation = last_direction.angle()

func _input(event):
	if is_dead: 
		return
		
	if event.is_action_pressed("attack") and can_basic_attack:
		execute_basic_attack()
	if event.is_action_pressed("special_attack") and can_special_attack:
		execute_special_attack()

func _on_show_upgrade_screen():
	if not is_inside_tree():
		return
	var spawn_point = get_tree().get_first_node_in_group("spawn_point")
	if spawn_point:
		global_position = spawn_point.global_position

func _on_inkarnacija_started(_nova_klasa):
	is_dead = false
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	
	apply_stats()

func apply_stats():
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
	armor_multiplier = 1.0
	if aura_visual:
		aura_visual.visible = false
	if special_aoe_area: special_aoe_area.scale = Vector2(1.0, 1.0)
	
	match GameManager.current_class:
		GameManager.PlayerClass.KNIGHT:
			armor_multiplier = 0.5
			base_speed = 1000.0
			current_melee_damage = 50
			if basic_melee_area: basic_melee_area.scale = Vector2(1.0, 1.0)
		GameManager.PlayerClass.PRIEST:
			armor_multiplier = 0.8
			base_speed = 1200.0
		GameManager.PlayerClass.RAT:
			armor_multiplier = 1.0
			base_speed = 1600.0
			current_melee_damage = 15
			if basic_melee_area: basic_melee_area.scale = Vector2(0.5, 0.5)
		GameManager.PlayerClass.CHILD:
			armor_multiplier = 1.2
			base_speed = 1400.0

	if sprite:
		sprite.play("idle")
			
	var my_upgrades = UpgradeManager.get_active_upgrades_for_class(GameManager.current_class)
	for upg in my_upgrades:
		apply_single_upgrade(upg)
		
	if GameManager.current_class == GameManager.PlayerClass.CHILD:
		dashes_left = child_max_dashes

	# --- DEBUG ---
	var class_name_str = GameManager.PlayerClass.keys()[GameManager.current_class]
	print("========================================")
	print("[Player] INKARNACIJA #", GameManager.total_incarnations_completed, " | KLASA: ", class_name_str)
	print("[Player] --- STATOVI ---")
	print("[Player]   base_speed:              ", base_speed)
	print("[Player]   armor_multiplier:        ", armor_multiplier)
	print("[Player]   damage_multiplier:       ", damage_multiplier)
	print("[Player]   cooldown_multiplier:     ", cooldown_multiplier)
	print("[Player]   pickup_range_multiplier: ", pickup_range_multiplier)
	print("[Player]   current_melee_damage:    ", current_melee_damage)
	print("[Player]   timer duration:          ", GameManager.get_scaled_duration())
	print("[Player] --- AKTIVNI UPGRADEOVI (", my_upgrades.size(), ") ---")
	if my_upgrades.is_empty():
		print("[Player]   (nema upgradeova)")
	for upg in my_upgrades:
		print("[Player]   [", upg["rarity"], "] ", upg["id"], " -> stat: ", upg["stat"], ", value: ", upg["value"])
	print("========================================")
	# --- END DEBUG ---

func apply_single_upgrade(upgrade: Dictionary):
	match upgrade["stat"]:
		"speed":
			base_speed *= (1.0 + upgrade["value"])
		"armor":
			armor_multiplier += upgrade["value"]
		"dmg":
			damage_multiplier *= (1.0 + upgrade["value"])
		"range":
			pickup_range_multiplier *= (1.0 + upgrade["value"])
		"cooldown":
			cooldown_multiplier *= (1.0 + upgrade["value"])
		"timer":
			GameManager.add_seconds(upgrade["value"])
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

func _update_animation(current_velocity: Vector2) -> void:
	if not sprite or is_dead:
		return
	# Don't interrupt attack animation while it's playing
	if sprite.animation == "attack" and sprite.is_playing():
		return
	if current_velocity.length() > 10.0:
		sprite.play("walk")
	else:
		sprite.flip_h = true
		sprite.play("idle")

func execute_basic_attack():
	can_basic_attack = false
	match GameManager.current_class:
		GameManager.PlayerClass.KNIGHT:
			if sprite: sprite.play("attack")
			sfx_player.stream = sfx_attack_knight
			sfx_player.play()
			basic_melee_area.monitoring = true
			await get_tree().create_timer(0.1).timeout
			basic_melee_area.monitoring = false
			await get_tree().create_timer(0.6 * cooldown_multiplier).timeout
			can_basic_attack = true
			
		GameManager.PlayerClass.RAT:
			if sprite: sprite.play("attack")
			sfx_player.stream = sfx_attack_rat
			sfx_player.play()
			basic_melee_area.monitoring = true
			await get_tree().create_timer(0.1).timeout
			basic_melee_area.monitoring = false
			await get_tree().create_timer(0.3 * cooldown_multiplier).timeout 
			can_basic_attack = true
			
		GameManager.PlayerClass.PRIEST:
			if sprite: sprite.play("attack")
			sfx_player.stream = sfx_attack_priest
			sfx_player.play()
			if projectile_scene:
				var proj = projectile_scene.instantiate()
				proj.damage = 5 * damage_multiplier
				proj.speed = 2000.0
				proj.global_position = shoot_point.global_position
				proj.direction = (get_global_mouse_position() - shoot_point.global_position).normalized()
				get_tree().root.add_child(proj)
			await get_tree().create_timer(1.2 * cooldown_multiplier).timeout
			can_basic_attack = true
			
		GameManager.PlayerClass.CHILD:
			if sprite: sprite.play("attack")
			sfx_player.stream = sfx_attack_child
			sfx_player.play()
			if projectile_scene:
				var proj = projectile_scene.instantiate()
				proj.damage = 3.5 * damage_multiplier
				proj.speed = 1500.0
				proj.global_position = shoot_point.global_position
				proj.direction = (get_global_mouse_position() - shoot_point.global_position).normalized()
				get_tree().root.add_child(proj)
			await get_tree().create_timer(0.8 * cooldown_multiplier).timeout
			can_basic_attack = true

func execute_special_attack():
	can_special_attack = false
	
	match GameManager.current_class:
		GameManager.PlayerClass.KNIGHT:
			if special_aoe_area:
				sfx_player.stream = sfx_knight_swirl
				sfx_player.play()
				special_aoe_area.monitoring = true
				await get_tree().create_timer(0.2).timeout
				special_aoe_area.monitoring = false
			
			await get_tree().create_timer(4.0 * cooldown_multiplier).timeout
			can_special_attack = true
			
		GameManager.PlayerClass.PRIEST:
			if special_aoe_area:
				sfx_player.stream = sfx_priest_aura
				sfx_player.play()
				special_aoe_area.monitoring = true
				if aura_visual: 
					aura_visual.visible = true
				await get_tree().create_timer(1.5).timeout
				if aura_visual: 
					aura_visual.visible = false
				special_aoe_area.monitoring = false
			
			await get_tree().create_timer(4.0 * cooldown_multiplier).timeout
			can_special_attack = true
			
		GameManager.PlayerClass.RAT:
			sfx_player.stream = sfx_rat_frenzy
			sfx_player.play()
			is_frenzy_active = true
			var temp_base_speed = base_speed
			base_speed *= 2
			if rat_frenzy_damage == 999: 
				is_immune = true
				
			if special_aoe_area:
				special_aoe_area.scale = Vector2(0.5, 0.5)
				special_aoe_area.monitoring = true
				
			await get_tree().create_timer(3.0).timeout
			base_speed = temp_base_speed
			is_frenzy_active = false
			is_immune = false
			if special_aoe_area: special_aoe_area.monitoring = false
			
			await get_tree().create_timer(8.0 * cooldown_multiplier).timeout
			can_special_attack = true
			
		GameManager.PlayerClass.CHILD:
			if dashes_left <= 0: return 
			
			is_dashing = true
			is_immune = true 
			dashes_left -= 1
			sfx_player.stream = sfx_child_dash
			sfx_player.play()
			
			await get_tree().create_timer(0.2).timeout
			
			is_dashing = false
			is_immune = false 
			
			if dashes_left > 0:
				can_special_attack = true
				
			punjenje_dasha()

func punjenje_dasha():
	await get_tree().create_timer(2.5 * cooldown_multiplier).timeout
	
	if dashes_left < child_max_dashes:
		dashes_left += 1
		
	if dashes_left > 0:
		can_special_attack = true

func take_damage(amount: float):
	if is_dead or is_immune: 
		return
	sfx_player.stream = sfx_hit
	sfx_player.play()
	var time_damage = amount * armor_multiplier
	GameManager.reduce_time(time_damage)
	_play_hit_flash()

func _play_hit_flash() -> void:
	if not sprite:
		return
	var tween = create_tween()
	sprite.modulate = Color.RED
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
func die():
	is_dead = true
	if GameManager.current_class == GameManager.PlayerClass.RAT:
		sfx_player.stream = sfx_die_rat
		sfx_player.play()
	else:
		sfx_player.stream = sfx_die
		sfx_player.play()
	GameManager.player_died.emit() 
	
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)

func _on_basic_melee_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not body == self:
		body.take_damage(current_melee_damage * damage_multiplier)

func _on_special_aoe_area_body_entered(body: Node2D) -> void:
	if body == self: return
	if GameManager.current_class == GameManager.PlayerClass.KNIGHT:
		if body.has_method("take_damage"):
			body.take_damage(999)
	if GameManager.current_class == GameManager.PlayerClass.PRIEST:
		if body.has_method("apply_slow"):
			body.apply_slow(priest_slow_multiplier, priest_aura_duration)
	if GameManager.current_class == GameManager.PlayerClass.RAT and is_frenzy_active:
		if body.has_method("take_damage") and rat_frenzy_damage > 0:
			body.take_damage(rat_frenzy_damage)
