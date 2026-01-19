extends Area2D

var damage: int = 20

func _ready():
	# Connect signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		Global.take_damage(damage)
		# Knockback
		var knockback_direction = (body.global_position - global_position).normalized()
		body.velocity = knockback_direction * 300