extends Area2D

var velocity: Vector2 = Vector2.ZERO
var damage: int = 20
var lifetime: float = 3.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Connect body entered signal
	body_entered.connect(_on_body_entered)
	
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float):
	# Move fireball
	global_position += velocity * delta
	
	# Update animation
	animated_sprite.play("fly")

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		Global.take_damage(damage)
		queue_free()
	elif body.is_in_group("walls"):
		queue_free()