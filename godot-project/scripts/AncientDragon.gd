extends CharacterBody2D

# Boss stats
var health: int = 200
var max_health: int = 200
var damage: int = 30
var score_value: int = 1000

# Attack patterns
var attack_timer: float = 0.0
var attack_cooldown: float = 3.0
var current_attack: String = "idle"
var is_dead: bool = false

# Movement
var speed: float = 60.0
var target_position: Vector2

# References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var fireball_scene: PackedScene = preload("res://scenes/Fireball.tscn")

func _ready():
	# Initialize health bar
	health_bar.max_value = max_health
	health_bar.value = health
	
	# Add to enemies group
	add_to_group("enemies")
	add_to_group("boss")

func _physics_process(delta: float):
	if is_dead or Global.current_state != Global.GameState.PLAYING:
		return
	
	# Update attack timer
	attack_timer += delta
	
	# Choose attack pattern
	if attack_timer >= attack_cooldown:
		perform_attack()
		attack_timer = 0.0
	
	# Move towards player occasionally
	if current_attack == "idle":
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * speed * 0.5
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	# Update animation
	update_animation()
	
	move_and_slide()

func perform_attack():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var attack_choice = randi() % 3
	
	match attack_choice:
		0:
			# Fireball attack
			current_attack = "fireball"
			shoot_fireball(player.global_position)
		1:
			# Breath attack
			current_attack = "breath"
			animated_sprite.play("breath")
		2:
			# Lunge attack
			current_attack = "lunge"
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed * 3

func shoot_fireball(target_pos: Vector2):
	var fireball = fireball_scene.instantiate()
	get_parent().add_child(fireball)
	fireball.global_position = global_position + Vector2(50, 0)
	
	var direction = (target_pos - global_position).normalized()
	fireball.velocity = direction * 400

func update_animation():
	match current_attack:
		"idle":
			if abs(velocity.x) > 10:
				animated_sprite.play("walk")
			else:
				animated_sprite.play("idle")
		"fireball":
			animated_sprite.play("attack")
		"breath":
			animated_sprite.play("breath")
		"lunge":
			animated_sprite.play("attack")
	
	# Reset attack state after animation
	if animated_sprite.animation != "idle" and animated_sprite.is_playing():
		await animated_sprite.animation_finished
		current_attack = "idle"

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
	
	# Victory after boss death
	await animated_sprite.animation_finished
	Global.current_state = Global.GameState.VICTORY
	Global.game_state_changed.emit(Global.current_state)
	
	# Save score and progress
	Global.save_score_to_storage(Global.player_name, Global.score)
	Global.save_progress()
	
	# Change to victory scene
	get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")

func _on_body_entered(body: Node2D):
	if body.name == "Player" and not is_dead:
		Global.take_damage(damage)
		# Knockback
		var knockback_direction = (body.global_position - global_position).normalized()
		body.velocity = knockback_direction * 400