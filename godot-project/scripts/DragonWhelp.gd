extends CharacterBody2D

# Enemy stats
var health: int = 50
var max_health: int = 50
var speed: float = 80.0
var damage: int = 15
var score_value: int = 100

# AI behavior
var patrol_direction: int = 1
var patrol_timer: float = 0.0
var patrol_duration: float = 2.0
var is_dead: bool = false

# References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar

func _ready():
	# Initialize health bar
	health_bar.max_value = max_health
	health_bar.value = health
	
	# Add to enemies group
	add_to_group("enemies")

func _physics_process(delta: float):
	if is_dead or Global.current_state != Global.GameState.PLAYING:
		return
	
	# Patrol behavior
	patrol_timer += delta
	if patrol_timer >= patrol_duration:
		patrol_direction *= -1
		patrol_timer = 0.0
	
	# Move
	velocity.x = patrol_direction * speed
	
	# Update animation
	if abs(velocity.x) > 10:
		animated_sprite.play("walk")
		animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")
	
	move_and_slide()

func take_damage(damage: int):
	health -= damage
	health_bar.value = health
	
	# Flash red
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	is_dead = true
	animated_sprite.play("death")
	Global.add_score(score_value)
	
	# Disable collision
	$CollisionShape2D.disabled = true
	
	# Remove after animation
	await animated_sprite.animation_finished
	queue_free()

func _on_body_entered(body: Node2D):
	if body.name == "Player" and not is_dead:
		Global.take_damage(damage)
		# Knockback
		var knockback_direction = (body.global_position - global_position).normalized()
		body.velocity = knockback_direction * 300