extends Node


signal player_died # Listened to by: EnemySpawner, HUD, UpgradeScreen 
signal inkarnacija_started(klasa) # Listened to by: HUD, PickupSpawner, EnemySpawner 
signal ascension_collected(n) # Listened to by: GameManager, HUD 
signal ascension_stolen(n) # Listened to by: GameManager, HUD 
signal cash_in(score) # Listened to by: GameManager, HUD 
signal enemy_died(tip) # Listened to by: GameManager (for Vitez bonus) 
signal upgrade_selected(upgrade) # Listened to by: GameManager, Player 
signal game_over(total_score) # Listened to by: GameOver screen 

var total_score: int = 0
var remaining_incarnations: int = 3
var current_run_ascensions: int = 0

# KLASE
enum PlayerClass { KNIGHT, PRIEST, RAT, CHILD }
var current_class: PlayerClass = PlayerClass.RAT

var class_weight = {
	PlayerClass.KNIGHT: 100,
	PlayerClass.PRIEST: 25,
	PlayerClass.CHILD: 25,
	PlayerClass.RAT: 25
}

# TIMER LOGIKA 
var incarnation_duration: float = 15.0 # Osnovno trajanje je 15 sekundi
var time_remaining: float = 15.0
var timer_active: bool = false

func _ready():
	randomize()
	start_new_iteration()
	
func start_new_iteration():
	current_class = get_weighted_random_class()
	time_remaining = incarnation_duration
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
			
	return PlayerClass.KNIGHT # Fallback za svaki slučaj

func _process(delta):
	if timer_active:
		time_remaining -= delta
		if time_remaining <= 0:
			time_remaining = 0
			timer_active = false
			time_expired()

# Funkcija koju tvoj kolega C treba za SecondsExtra pickup!
func add_seconds(amount: float):
	time_remaining += amount
	print("Added ", amount, " seconds! Time remaining: ", time_remaining)

func time_expired():
	print("Time expired for this incarnation!")
	
func add_ascension(amount: int):
	current_run_ascensions += amount
	print("Picked up ascension, amount: ", amount)
	ascension_collected.emit(amount)
	
func perform_cash_in():
	var cashed_amount = current_run_ascensions
	total_score += cashed_amount
	remaining_incarnations -= 1
	current_run_ascensions = 0
	print("cash in uspješan")
	cash_in.emit(cashed_amount)
	if remaining_incarnations <= 0:
		game_over.emit(total_score)
	else:
		print("Iduci run")
	
