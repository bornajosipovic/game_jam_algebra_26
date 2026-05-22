extends Area2D

var speed: float = 2000.0
var damage: int = 30
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		return
		
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
	queue_free() 

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
