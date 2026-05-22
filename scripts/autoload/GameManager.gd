extends Node

const WIN_SCORE: int = 25
const START_SCREEN: String = "res://scenes/ui/StartScreen.tscn"

signal player_died
signal inkarnacija_started(klasa)
signal ascension_collected(n)
signal ascension_stolen(n)
signal cash_in(score)
signal enemy_died(tip)
signal show_upgrade_screen
signal upgrade_selected(upgrade)
signal game_over(total_score)
signal game_won(total_score)
signal incarnation_collected(amount)

var total_score: int = 0
var remaining_incarnations: int = 2
var current_run_ascensions: int = 0
var current_run_incarnations: int = 0
var total_incarnations_completed: int = 0

enum PlayerClass { KNIGHT, PRIEST, RAT, CHILD }
var current_class: PlayerClass = PlayerClass.RAT

var class_weight = {
	PlayerClass.KNIGHT: 0,
	PlayerClass.PRIEST: 100,
	PlayerClass.CHILD: 0,
	PlayerClass.RAT: 0
}

var incarnation_duration: float = 15.0
var time_remaining: float = 15.0
var timer_active: bool = false

func _ready():
	randomize()
	player_died.connect(_on_player_died)
	upgrade_selected.connect(_on_upgrade_selected)
	enemy_died.connect(_on_enemy_died)
	call_deferred("start_upgrade_phase")

func _reset_state() -> void:
	total_score = 0
	remaining_incarnations = 3
	current_run_ascensions = 0
	current_run_incarnations = 0
	total_incarnations_completed = 0
	UpgradeManager.active_upgrades.clear()

func _on_player_died():
	if remaining_incarnations > 0:
		remaining_incarnations -= 1
		start_upgrade_phase()
	else:
		game_over.emit(total_score)
		await get_tree().create_timer(3.0).timeout
		_reset_state()
		get_tree().change_scene_to_file(START_SCREEN)

func start_upgrade_phase():
	current_run_ascensions = 0
	current_run_incarnations = 0
	show_upgrade_screen.emit()

func _on_upgrade_selected(_upgrade: Dictionary):
	start_new_iteration()

func get_scaled_duration() -> float:
	return max(10.0, 15.0 - floor(total_incarnations_completed / 5.0))

func start_new_iteration():
	total_incarnations_completed += 1
	current_class = get_weighted_random_class()
	time_remaining = get_scaled_duration()
	timer_active = true
	inkarnacija_started.emit(current_class)

func get_weighted_random_class() -> PlayerClass:
	var total_weight = 0
	for weight in class_weight.values():
		total_weight += weight

	var roll = randi_range(1, total_weight)
	var current_sum = 0

	for cls in class_weight.keys():
		current_sum += class_weight[cls]
		if roll <= current_sum:
			return cls

	return PlayerClass.KNIGHT

func _process(delta):
	if timer_active:
		time_remaining -= delta
		if time_remaining <= 0:
			time_remaining = 0
			timer_active = false
			time_expired()

func add_seconds(amount: float):
	time_remaining += amount

func reduce_time(amount: float):
	if timer_active:
		time_remaining -= amount
		if time_remaining <= 0:
			time_remaining = 0
			timer_active = false
			time_expired()

func add_incarnation():
	current_run_incarnations += 1
	incarnation_collected.emit(current_run_incarnations)

func time_expired():
	var player = get_tree().get_first_node_in_group("player")
	if player and not player.is_dead:
		player.die()

func add_ascension(amount: int):
	current_run_ascensions += amount
	ascension_collected.emit(amount)

func perform_cash_in():
	var cashed_amount = current_run_ascensions
	total_score += cashed_amount
	remaining_incarnations += current_run_incarnations - 1
	current_run_ascensions = 0
	current_run_incarnations = 0
	timer_active = false

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_dead = true
		player.visible = false
		if player.has_node("CollisionShape2D"):
			player.get_node("CollisionShape2D").set_deferred("disabled", true)

	cash_in.emit(cashed_amount)

	# Check win condition after cashing in
	if total_score >= WIN_SCORE:
		game_won.emit(total_score)
		await get_tree().create_timer(4.0).timeout
		_reset_state()
		get_tree().change_scene_to_file(START_SCREEN)
	elif remaining_incarnations > 0:
		start_upgrade_phase()
	else:
		game_over.emit(total_score)
		await get_tree().create_timer(3.0).timeout
		_reset_state()
		get_tree().change_scene_to_file(START_SCREEN)

func _on_enemy_died(tip):
	if current_class == PlayerClass.KNIGHT and tip == Enemy.Type.DEMON:
		add_ascension(1)
