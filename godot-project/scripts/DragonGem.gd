extends Area2D

var value: int = 50
var collected: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Connect signal
	body_entered.connect(_on_body_entered)
	
	# Add to collectibles group
	add_to_group("collectibles")

func _on_body_entered(body: Node2D):
	if body.name == "Player" and not collected:
		collected = true
		Global.add_score(value)
		
		# Play collection animation
		animated_sprite.play("collect")
		
		# Disable collision
		collision_shape.disabled = true
		
		# Remove after animation
		await animated_sprite.animation_finished
		queue_free()

func _process(_delta: float):
	# Floating animation
	var float_offset = sin(Time.get_time_dict_from_system().get("second") * 2) * 5
	position.y += float_offset * get_process_delta_time()