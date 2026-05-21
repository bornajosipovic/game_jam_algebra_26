extends Node


signal player_died # Listened to by: EnemySpawner, HUD, UpgradeScreen 
signal inkarnacija_started(klasa) # Listened to by: HUD, PickupSpawner, EnemySpawner 
signal ascension_collected(n) # Listened to by: GameManager, HUD 
signal ascension_stolen(n) # Listened to by: GameManager, HUD 
signal cash_in(score) # Listened to by: GameManager, HUD 
signal enemy_died(tip) # Listened to by: GameManager (for Vitez bonus) 
signal upgrade_selected(upgrade) # Listened to by: GameManager, Player 
signal game_over(total_score) # Listened to by: GameOver screen 

var ukupni_score: int = 0
var preostale_inkarnacije: int = 3
var time_length: float = 15.0
var time_left: float = 15.0
var timer_active:bool = false

enum Klasa { VITEZ, SVECENIK, STAKOR, DIJETE }
var trenutna_klasa: Klasa = Klasa.VITEZ

func add_incarnation():
	preostale_inkarnacije += 1
	print("Incarnation picked up, current ", preostale_inkarnacije)

func _process(delta: float) -> void:
	if timer_active:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			timer_active = false
			time_up()
			
func add_seconds(amount: float):
	time_left += amount
	print("Added seconds, amount:", amount)
	
func time_up():
	print("Time UP!")
		
