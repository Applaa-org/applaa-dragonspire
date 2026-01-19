extends Node

# Game state
var score: int = 0
var player_health: int = 100
var max_health: int = 100
var level_progress: int = 0
var game_data: Dictionary = {}

# High score and player data
var high_score: int = 0
var player_name: String = ""
var scores: Array[Dictionary] = []

# Game state enum
enum GameState { MENU, PLAYING, VICTORY, DEFEAT }
var current_state: GameState = GameState.MENU

# Signals
signal score_changed(new_score: int)
signal health_changed(new_health: int)
signal game_state_changed(new_state: GameState)

func _ready():
	# Initialize high score display to 0 immediately
	high_score = 0
	player_name = ""
	scores.clear()
	
	# Load game data from localStorage
	load_game_data()

func add_score(points: int):
	score += points
	score_changed.emit(score)
	# Check for new high score
	if score > high_score:
		high_score = score

func reset_game():
	score = 0
	player_health = max_health
	level_progress = 0
	current_state = GameState.PLAYING
	score_changed.emit(score)
	health_changed.emit(player_health)
	game_state_changed.emit(current_state)

func take_damage(damage: int):
	player_health -= damage
	if player_health < 0:
		player_health = 0
	health_changed.emit(player_health)
	
	if player_health <= 0:
		current_state = GameState.DEFEAT
		game_state_changed.emit(current_state)

func heal(amount: int):
	player_health += amount
	if player_health > max_health:
		player_health = max_health
	health_changed.emit(player_health)

# Load game data from localStorage
func load_game_data():
	# Request data from Applaa storage
	JavaScriptBridge.eval("""
		window.parent.postMessage({ type: 'applaa-game-load-data', gameId: 'dragonspire' }, '*');
	""")
	
	# Set up listener for response
	_setup_message_listener()

func _setup_message_listener():
	# This will be called when data is loaded
	# In a real implementation, you'd set up a proper message listener
	# For now, we'll simulate the data loading
	call_deferred("_on_data_loaded", {
		"highScore": 0,
		"lastPlayerName": "",
		"scores": [],
		"gameProgress": {"level": 1, "unlocked_abilities": ["jump", "attack"]}
	})

func _on_data_loaded(data: Dictionary):
	if data:
		high_score = data.get("highScore", 0)
		player_name = data.get("lastPlayerName", "")
		scores = data.get("scores", [])
		game_data = data.get("gameProgress", {})

# Save score to localStorage
func save_score_to_storage(name: String, final_score: int):
	player_name = name
	JavaScriptBridge.eval("""
		window.parent.postMessage({ 
			type: 'applaa-game-save-score', 
			gameId: 'dragonspire',
			playerName: '%s',
			score: %d
		}, '*');
	""" % [name, final_score])

# Save game progress
func save_progress():
	JavaScriptBridge.eval("""
		window.parent.postMessage({ 
			type: 'applaa-game-save-data', 
			gameId: 'dragonspire',
			data: {
				level: %d,
				score: %d,
				health: %d,
				unlocked_abilities: ['jump', 'attack', 'double_jump']
			}
		}, '*');
	""" % [level_progress, score, player_health])