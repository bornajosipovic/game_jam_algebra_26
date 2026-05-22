class_name Demon
extends Enemy

enum State { IDLE, CHASE }

var state: State = State.IDLE

const HP      := 10
const SPEED   := 900.0
const DETECTION := 900.0
const DAMAGE  := 1.0

func _ready() -> void:
	super._ready()

	enemy_type      = Type.DEMON
	max_hp          = HP
	current_hp      = HP
	speed           = SPEED
	detection_range = DETECTION
	contact_damage  = DAMAGE

func _physics_process(_delta: float) -> void:
	match state:
		State.IDLE:  _state_idle()
		State.CHASE: _state_chase()

func _state_idle() -> void:
	stop_moving()
	if is_player_in_detection_range():
		state = State.CHASE

func _state_chase() -> void:
	if player == null:
		return
	move_toward_target(player.global_position)
