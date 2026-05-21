class_name Hooligan
extends Enemy

# ---------------------------------------------------------
# State machine
# ---------------------------------------------------------
enum State { IDLE, CHASE }

var state: State = State.IDLE

# ---------------------------------------------------------
# Stats
# ---------------------------------------------------------
const HP        := 3
const SPEED     := 80.0
const DETECTION := 150.0
const DAMAGE    := 1

# ---------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------
func _ready() -> void:
	super._ready()

	enemy_type      = Type.HOOLIGAN
	max_hp          = HP
	current_hp      = HP
	speed           = SPEED
	detection_range = DETECTION
	contact_damage  = DAMAGE

func _physics_process(_delta: float) -> void:
	match state:
		State.IDLE:  _state_idle()
		State.CHASE: _state_chase()

# ---------------------------------------------------------
# States
# ---------------------------------------------------------
func _state_idle() -> void:
	stop_moving()
	if is_player_in_detection_range():
		state = State.CHASE

func _state_chase() -> void:
	if player == null:
		return
	move_toward_target(player.global_position)
