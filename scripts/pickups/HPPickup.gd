extends Area2D

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# pitaj osobu A koliko HP healamo i kako se zove funkcija na Playeru
		queue_free()
