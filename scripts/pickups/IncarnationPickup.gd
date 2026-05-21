extends Area2D

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if GameManager.current_class == GameManager.PlayerClass.CHILD:
			GameManager.add_incarnation()
			GameManager.add_incarnation()
		else:
			GameManager.add_incarnation()
		queue_free()
