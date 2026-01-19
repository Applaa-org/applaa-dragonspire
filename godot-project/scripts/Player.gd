extends CharacterBody2D

# Movement constants
const SPEED: float = 250.0
const JUMP_VELOCITY: float = -500.0
const DOUBLE_JUMP_VELOCITY: float = -450.0

# Combat
var attack_damage: int = 25
var can_attack: bool = true
var attack_cooldown: float = 0.5

# Abilities
var can_double_jump: bool = true
var jumps_remaining: int = 2

# References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D

func _ready():
	# Connect signals
	Global.health_changed.connect(_on_health_changed)
	Global.game_state_changed.connect(_on_game_state_changed)
	
	# Initialize health
	Global.player_health = Global.max_health
	
	# Hide attack area initially
	attack_area.monitoring = false

func _physics_process(delta: float):
	# Don't process if game is not in playing state
	if Global.current_state != Global.GameState.PLAYING:
		return
	
	# Handle gravity
	if not is_on_floor():
		velocity.y += get_gravity() * delta
	else:
		jumps_remaining = 2
	
	# Handle jumping
	if Input.is_action_just_pressed("ui_accept"):
		if jumps_remaining > 0:
			if jumps_remaining == 2:
				velocity.y = JUMP_VELOCITY
			else:
				velocity.y = DOUBLE_JUMP_VELOCITY
			jumps_remaining -= 1
	
	# Handle movement
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Handle attack
	if Input.is_action_just_pressed("attack") and can_attack:
		perform_attack()
	
	# Update attack cooldown
	if not can_attack:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			can_attack = true
			attack_cooldown = 0.5
	
	# Play animations
	update_animation()
	
	# Move the character
	move_and_slide()

func perform_attack():
	can_attack = false
	attack_area.monitoring = true
	attack_collision.disabled = false
	
	# Play attack animation
	animated_sprite.play("attack")
	
	# Disable attack area after a short delay
	await get_tree().create_timer(0.3).timeout
	attack_area.monitoring = false
	attack_collision.disabled = true

func update_animation():
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif abs(velocity.x) > 10:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

func _on_attack_area_body_entered(body: Node2D):
	if body.is_in_group("enemies"):
		body.take_damage(attack_damage)
		Global.add_score(25)

func _on_health_changed(new_health: int):
	# Update visual feedback for health
	if new_health <= 30:
		animated_sprite.modulate = Color.RED
	else:
		animated_sprite.modulate = Color.WHITE

func _on_game_state_changed(new_state: Global.GameState):
	if new_state != Global.GameState.PLAYING:
		# Stop all movement when not playing
		velocity = Vector2.ZERO
		animated_sprite.play("idle")