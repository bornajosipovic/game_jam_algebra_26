class_name Bandit
extends Enemy

# ---------------------------------------------------------
# Signali
# ---------------------------------------------------------
signal ascension_stolen(amount: int)

# ---------------------------------------------------------
# State machine
# ---------------------------------------------------------
enum State { ROAMING, CHASE, STEAL, FLEE }

var state: State = State.ROAMING

# ---------------------------------------------------------
# Stats
# ---------------------------------------------------------
const HP               := 2
const SPEED            := 110.0
const DETECTION        := 600.0
const FLEE_SPEED       := 70.0

# ---------------------------------------------------------
# Roaming
# ---------------------------------------------------------
const ROAM_WAIT_TIME   := 2.0

var roam_target: Vector2
var roam_timer: float = 0.0

# ---------------------------------------------------------
# Separation — aktivan samo u ROAMING stanju
# ---------------------------------------------------------
const SEPARATION_RADIUS   := 80.0
const SEPARATION_STRENGTH := 150.0

# ---------------------------------------------------------
# Steal
# ---------------------------------------------------------
const DASH_SPEED       := 300.0
const DASH_DURATION    := 0.3

var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var stolen_amount: int = 0

# ---------------------------------------------------------
# Kvadrant — injektira spawn logika
# ---------------------------------------------------------
var quadrant: Rect2

# ---------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------
func _ready() -> void:
	super._ready()

	enemy_type      = Type.BANDIT
	max_hp          = HP
	current_hp      = HP
	speed           = SPEED
	detection_range = DETECTION
	contact_damage  = 0

	add_to_group("banditi")
	_pick_roam_target()

func _physics_process(delta: float) -> void:
	match state:
		State.ROAMING: _state_roaming(delta)
		State.CHASE:   _state_chase()
		State.STEAL:   _state_steal(delta)
		State.FLEE:    _state_flee()

# ---------------------------------------------------------
# States
# ---------------------------------------------------------
func _state_roaming(delta: float) -> void:
	if is_player_in_detection_range():
		state = State.CHASE
		return

	var nav_vel: Vector2 = get_nav_velocity(roam_target)
	var sep_vel: Vector2 = _get_separation_velocity()
	velocity = nav_vel + sep_vel
	move_and_slide()

	if global_position.distance_to(roam_target) < 10.0:
		velocity = Vector2.ZERO
		roam_timer += delta
		if roam_timer >= ROAM_WAIT_TIME:
			roam_timer = 0.0
			_pick_roam_target()

func _state_chase() -> void:
	if player == null:
		return
	move_toward_target(player.global_position)

func _state_steal(delta: float) -> void:
	# Dasha u suprotnom smjeru od igrača
	dash_timer -= delta
	velocity = dash_direction * DASH_SPEED
	move_and_slide()

	if dash_timer <= 0.0:
		state = State.FLEE

func _state_flee() -> void:
	if player == null:
		queue_free()
		return
	# Bježi od igrača brzinom manjom od igračeve
	velocity = -get_direction_to_player() * FLEE_SPEED
	move_and_slide()

# ---------------------------------------------------------
# Kontakt s igračem — override iz Enemy.gd
# ---------------------------------------------------------
func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead or body.is_in_group("player") == false:
		return

	match state:
		State.CHASE:
			_execute_steal()
		State.FLEE:
			_execute_return()

func _execute_steal() -> void:
	if GameManager.current_run_ascensions <= 0:
		return

	# Uzima Ascension
	stolen_amount = 1
	GameManager.current_run_ascensions -= stolen_amount
	ascension_stolen.emit(stolen_amount)

	# Dasha u suprotnom smjeru
	dash_direction = -get_direction_to_player()
	dash_timer = DASH_DURATION
	state = State.STEAL

func _execute_return() -> void:
	# Vraća ukradeni Ascension i despawna
	GameManager.current_run_ascensions += stolen_amount
	stolen_amount = 0
	die()

# ---------------------------------------------------------
# Separation
# ---------------------------------------------------------
func _get_separation_velocity() -> Vector2:
	var separation := Vector2.ZERO

	for bandit in get_tree().get_nodes_in_group("banditi"):
		if bandit == self:
			continue
		var dist: float = global_position.distance_to(bandit.global_position)
		if dist < SEPARATION_RADIUS and dist > 0.0:
			var push: Vector2 = (global_position - bandit.global_position).normalized()
			separation += push * (SEPARATION_RADIUS - dist)

	if separation == Vector2.ZERO:
		return Vector2.ZERO
	return separation.normalized() * SEPARATION_STRENGTH

# ---------------------------------------------------------
# Roaming
# ---------------------------------------------------------
func _pick_roam_target() -> void:
	roam_target = Vector2(
		randf_range(quadrant.position.x, quadrant.end.x),
		randf_range(quadrant.position.y, quadrant.end.y)
	)
