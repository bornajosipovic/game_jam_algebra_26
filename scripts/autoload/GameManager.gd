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
var current_class: PlayerClass = PlayerClass.KNIGHT

# TIMER LOGIKA 
var incarnation_duration: float = 15.0 # Osnovno trajanje je 15 sekundi
var time_remaining: float = 15.0
var timer_active: bool = false

func _ready():
	pass

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
	
