extends Area2D

var sfx_player1: AudioStreamPlayer2D
var sfx_player2: AudioStreamPlayer2D

@export_group("Item Sounds")
@export var sfx_pickup1: AudioStream
@export var sfx_pickup2: AudioStream


func _ready() -> void:
	sfx_player1 = AudioStreamPlayer2D.new()
	sfx_player1.volume_db = 8.0
	add_child(sfx_player1)

	connect("body_entered", _on_body_entered)
	var player = get_tree().get_first_node_in_group("player")
	if player and has_node("CollisionShape2D"):
		var multiplier = player.pickup_range_multiplier
		$CollisionShape2D.scale = Vector2(multiplier, multiplier)
	_hover()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameManager.add_seconds(3.0)
		if sfx_pickup1:
			visible = false
			sfx_player1.stream = sfx_pickup1
			sfx_player1.play()
			await sfx_player1.finished
		queue_free()



func _hover():
	var tween = create_tween()
	tween.set_loops()  # loops forever
	tween.tween_property(self, "position:y", position.y - 10, 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y + 10, 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 1.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
