class_name Bandit
extends Enemy

enum State { ROAMING, CHASE, STEAL, FLEE }

var state: State = State.ROAMING

const HP        := 2
const DETECTION := 1600.0

const ROAM_SPEED     := 300.0
const ROAM_WAIT_TIME := 2.0

var roam_target: Vector2
var roam_timer: float = 0.0

const DASH_SPEED    := 400.0
const DASH_DURATION := 0.3

var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var stolen_amount: int = 0

var quadrant: Rect2

func _ready() -> void:
	super._ready()
	enemy_type      = Type.BANDIT
	max_hp          = HP
	current_hp      = HP
	speed           = ROAM_SPEED
	detection_range = DETECTION
	contact_damage  = 0.0
	add_to_group("banditi")
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	_pick_roam_target()


func _physics_process(delta: float) -> void:
	match state:
		State.ROAMING: _state_roaming(delta)
		State.CHASE:   _state_chase()
		State.STEAL:   _state_steal(delta)
		State.FLEE:    _state_flee()

func _state_roaming(delta: float) -> void:
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
	var chase_speed: float = player.base_speed * 1.1
	nav_agent.target_position = player.global_position
	if not nav_agent.is_navigation_finished():
		var next_pos: Vector2 = nav_agent.get_next_path_position()
		var desired_vel = (next_pos - global_position).normalized() * chase_speed
		nav_agent.set_velocity(desired_vel)

func _state_steal(delta: float) -> void:
	dash_timer -= delta
	velocity = dash_direction * DASH_SPEED
	move_and_slide()
	if dash_timer <= 0.0:
		state = State.FLEE

func _state_flee() -> void:
	if player == null:
		queue_free()
		return
	var flee_speed: float = player.base_speed * 0.8
	velocity = -get_direction_to_player() * flee_speed
	move_and_slide()

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("player") == false:
		return
	if state == State.CHASE:
		_execute_steal()

func _execute_steal() -> void:
	if GameManager.current_run_ascensions > 0:
		stolen_amount = 1
		GameManager.current_run_ascensions -= stolen_amount
		GameManager.ascension_stolen.emit(stolen_amount)
	dash_direction = -get_direction_to_player()
	dash_timer = DASH_DURATION
	state = State.STEAL

func die() -> void:
	if stolen_amount > 0:
		GameManager.current_run_ascensions += stolen_amount
		GameManager.ascension_collected.emit(stolen_amount)
		stolen_amount = 0
	super.die()

func _pick_roam_target() -> void:
	roam_target = Vector2(
		randf_range(quadrant.position.x, quadrant.end.x),
		randf_range(quadrant.position.y, quadrant.end.y)
	)
