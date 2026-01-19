extends Control

# UI References
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var new_high_score_label: Label = $VBoxContainer/NewHighScoreLabel
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton
@onready var close_button: Button = $VBoxContainer/CloseButton

func _ready():
	# Display final score
	score_label.text = "Final Score: " + str(Global.score)
	
	# Check for new high score
	if Global.score > Global.high_score:
		new_high_score_label.visible = true
		new_high_score_label.text = "🎉 NEW HIGH SCORE! 🎉"
		high_score_label.text = "High Score: " + str(Global.score)
	else:
		new_high_score_label.visible = false
		high_score_label.text = "High Score: " + str(Global.high_score)
	
	# Connect button signals
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _on_restart_pressed():
	# Reset game
	Global.reset_game()
	
	# Reload main scene
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_main_menu_pressed():
	# Reset game
	Global.reset_game()
	
	# Go back to start screen
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
	get_tree().quit()