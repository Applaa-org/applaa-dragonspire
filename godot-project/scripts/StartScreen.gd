extends Control

# UI References
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var close_button: Button = $VBoxContainer/CloseButton
@onready var player_name_input: LineEdit = $VBoxContainer/PlayerNameInput
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var leaderboard_container: VBoxContainer = $VBoxContainer/LeaderboardContainer

func _ready():
	# Initialize high score display to 0 immediately
	high_score_label.text = "High Score: 0"
	high_score_label.visible = true
	
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Load game data and update display
	_load_game_data()

func _load_game_data():
	# Request data from localStorage
	JavaScriptBridge.eval("""
		window.parent.postMessage({ type: 'applaa-game-load-data', gameId: 'dragonspire' }, '*');
	""")
	
	# Set up message listener
	_setup_message_listener()

func _setup_message_listener():
	# Simulate data loading (in real implementation, this would listen for messages)
	call_deferred("_on_data_loaded", {
		"highScore": 0,
		"lastPlayerName": "",
		"scores": []
	})

func _on_data_loaded(data: Dictionary):
	if data:
		# Update high score display
		var high_score = data.get("highScore", 0)
		high_score_label.text = "High Score: " + str(high_score)
		Global.high_score = high_score
		
		# Pre-fill player name
		var last_player = data.get("lastPlayerName", "")
		if last_player != "":
			player_name_input.text = last_player
			Global.player_name = last_player
		
		# Display top scores
		var scores = data.get("scores", [])
		_display_leaderboard(scores)

func _display_leaderboard(scores: Array):
	# Clear existing scores
	for child in leaderboard_container.get_children():
		child.queue_free()
	
	# Display top 5 scores
	var display_count = min(5, scores.size())
	for i in range(display_count):
		var score_data = scores[i]
		var score_label = Label.new()
		score_label.text = str(i + 1) + ". " + score_data.playerName + " - " + str(score_data.score)
		leaderboard_container.add_child(score_label)

func _on_start_pressed():
	# Set player name from input
	Global.player_name = player_name_input.text
	
	# Reset game state
	Global.reset_game()
	
	# Change to main game scene
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_close_pressed():
	get_tree().quit()