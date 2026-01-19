extends Node2D

# Level references
@onready var player: CharacterBody2D = $Player
@onready var hud: Control = $HUD
@onready var score_label: Label = $HUD/ScoreLabel
@onready var health_label: Label = $HUD/HealthLabel
@onready var high_score_label: Label = $HUD/HighScoreLabel

func _ready():
	# Set up game state
	Global.current_state = Global.GameState.PLAYING
	Global.game_state_changed.emit(Global.current_state)
	
	# Connect signals
	Global.score_changed.connect(_on_score_changed)
	Global.health_changed.connect(_on_health_changed)
	
	# Initialize HUD
	update_hud()
	
	# Add player to group for easy reference
	player.add_to_group("player")

func _on_score_changed(new_score: int):
	score_label.text = "Score: " + str(new_score)
	
	# Update high score if needed
	if new_score > Global.high_score:
		Global.high_score = new_score
		high_score_label.text = "High Score: " + str(Global.high_score)

func _on_health_changed(new_health: int):
	health_label.text = "Health: " + str(new_health) + "/" + str(Global.max_health)
	
	# Check for defeat
	if new_health <= 0:
		Global.current_state = Global.GameState.DEFEAT
		Global.game_state_changed.emit(Global.current_state)
		
		# Save score
		Global.save_score_to_storage(Global.player_name, Global.score)
		
		# Change to defeat scene
		get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")

func update_hud():
	score_label.text = "Score: " + str(Global.score)
	health_label.text = "Health: " + str(Global.player_health) + "/" + str(Global.max_health)
	high_score_label.text = "High Score: " + str(Global.high_score)