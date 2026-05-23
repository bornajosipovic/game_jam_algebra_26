extends Area2D

@onready var animated_sprite = $AnimatedSprite2D # Make sure this matches your node name

func _ready() -> void:
	# Play the default animation as soon as the node enters the scene
	if animated_sprite:
		animated_sprite.play("default") # Change "default" if your animation has a different name
		
	body_entered.connect(_on_body_entered) # Updated to Godot 4 signal syntax

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameManager.perform_cash_in()
