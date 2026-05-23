class_name Hooligan
extends Enemy

enum State { PATROL, CHASE }

var state: State = State.PATROL
var quadrant: Rect2

const HP        := 3
const SPEED     := 800.0
const DETECTION := 1400.0
const DAMAGE    := 3.0

const ROAM_SPEED     := 200.0
const ROAM_WAIT_TIME := 2.0

var roam_target: Vector2
var roam_timer: float = 0.0

func _ready() -> void:
	super._ready()
	enemy_type      = Type.HOOLIGAN
	max_hp          = HP
	current_hp      = HP
	speed           = SPEED
	detection_range = DETECTION
	contact_damage  = DAMAGE
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	_pick_roam_target()

func _physics_process(delta: float) -> void:
	match state:
		State.PATROL: _state_patrol(delta)
		State.CHASE:  _state_chase()

func _state_patrol(delta: float) -> void:
	if is_player_in_detection_range():
		state = State.CHASE
		return

	nav_agent.target_position = roam_target
	if not nav_agent.is_navigation_finished():
		var next_pos: Vector2 = nav_agent.get_next_path_position()
		var desired_vel: Vector2 = (next_pos - global_position).normalized() * ROAM_SPEED
		nav_agent.set_velocity(desired_vel)

	if global_position.distance_to(roam_target) < 10.0:
		roam_timer += delta
		if roam_timer >= ROAM_WAIT_TIME:
			roam_timer = 0.0
			_pick_roam_target()

func _state_chase() -> void:
	if player == null:
		return
	move_toward_target(player.global_position)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func _pick_roam_target() -> void:
	roam_target = Vector2(
		randf_range(quadrant.position.x, quadrant.end.x),
		randf_range(quadrant.position.y, quadrant.end.y)
	)
