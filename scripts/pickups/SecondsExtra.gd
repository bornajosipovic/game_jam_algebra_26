extends Area2D

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# pitaj osobu A kako se zove funkcija za dodavanje sekundi na timeru
		queue_free()
