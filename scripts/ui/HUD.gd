extends CanvasLayer

@onready var time_bar = $MarginContainer/VBoxContainer/TimeBar
@onready var fuse_particles = $MarginContainer/VBoxContainer/TimeBar/FuseParticles
@onready var current_ascensions_label = $MarginContainer/VBoxContainer/MainRow/LeftSection/CurrentAscensionsLabel
@onready var class_label = $MarginContainer/VBoxContainer/MainRow/LeftSection/ClassLabel
@onready var class_icon = $MarginContainer/VBoxContainer/MainRow/CenterSection/ClassIcon
@onready var remaining_incarnations_label = $MarginContainer/VBoxContainer/MainRow/RightSection/Reincarnations
@onready var total_ascensions_label = $MarginContainer/VBoxContainer/MainRow/RightSection/TotalAscensions
@onready var basic_indicator = $MarginContainer/VBoxContainer/AttackIndicators/BasicIndicator
@onready var special_indicator = $MarginContainer/VBoxContainer/AttackIndicators/SpecialIndicator
@onready var overlay = $Overlay


@export var icon_knight: Texture2D
@export var icon_priest: Texture2D
@export var icon_rat: Texture2D
@export var icon_child: Texture2D

func _ready() -> void:
	GameManager.inkarnacija_started.connect(_on_inkarnacija_started)
	GameManager.ascension_collected.connect(_update_hud_values)
	GameManager.ascension_stolen.connect(_update_hud_values)
	GameManager.player_died.connect(_update_hud_values)
	GameManager.cash_in.connect(_on_cash_in)
	GameManager.incarnation_collected.connect(_update_hud_values)
	
	GameManager.show_upgrade_screen.connect(_on_show_upgrade_screen)
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_won.connect(_on_game_won)
	
	time_bar.step = 0.01 
	
	_update_hud_values(0)
	
	visible = false
	overlay.visible = false

func _process(_delta: float) -> void:
	if GameManager.timer_active:
		time_bar.value = GameManager.time_remaining
		
		var ratio = time_bar.value / time_bar.max_value
		var edge_x = time_bar.size.x * ratio
		
		fuse_particles.position.x = edge_x
		fuse_particles.position.y = time_bar.size.y / 2.0 
		fuse_particles.emitting = true
		
		var player = get_tree().get_first_node_in_group("player")
		if player:
			if player.can_basic_attack:
				basic_indicator.modulate = Color(1.0, 1.0, 1.0, 1.0) 
			else:
				basic_indicator.modulate = Color(0.3, 0.3, 0.3, 0.5) 
				
			if player.can_special_attack:
				special_indicator.modulate = Color(1.0, 1.0, 1.0, 1.0)
			else:
				special_indicator.modulate = Color(0.3, 0.3, 0.3, 0.5)
	else:
		fuse_particles.emitting = false

func _on_show_upgrade_screen() -> void:
	visible = false

func _on_inkarnacija_started(klasa) -> void:
	visible = true 
	
	match klasa:
		GameManager.PlayerClass.KNIGHT:
			class_label.text = "KLASA: Vitez"
			if icon_knight:
				class_icon.texture = icon_knight
		GameManager.PlayerClass.PRIEST:
			class_label.text = "KLASA: Svecenik"
			if icon_priest:
				class_icon.texture = icon_priest
		GameManager.PlayerClass.RAT:
			class_label.text = "KLASA: Stakor"
			if icon_rat:
				class_icon.texture = icon_rat
		GameManager.PlayerClass.CHILD:
			class_label.text = "KLASA: Dijete"
			if icon_child:
				class_icon.texture = icon_child
				
	_update_hud_values(0)
	
	await get_tree().process_frame
	time_bar.max_value = GameManager.time_remaining

func _on_cash_in(_score) -> void:
	_update_hud_values(0)

func _on_game_over(_score) -> void:
	overlay.visible = true
	overlay.show_message("You died.", Color(1, 0.2, 0.2))

func _on_game_won(_score) -> void:
	overlay.visible = true
	overlay.show_message("Ashbound God Reborn", Color(1, 0.85, 0.1))

func _update_hud_values(_amount = 0) -> void:
	current_ascensions_label.text = "TRENUTNI RUN: " + str(GameManager.current_run_ascensions)
	
	var prikaz_inkarnacija = str(GameManager.remaining_incarnations)
	if GameManager.current_run_incarnations > 0:
		prikaz_inkarnacija += " (+" + str(GameManager.current_run_incarnations) + ")"
		
	remaining_incarnations_label.text = "INKARNACIJE: " + prikaz_inkarnacija
	total_ascensions_label.text = "UKUPNO ASCENSIONA: " + str(GameManager.total_score)
