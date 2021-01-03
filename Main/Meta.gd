extends Node2D

var panels_game_type = [-1, -1, -1, -1]  # -1 indicates no game
var active_games = []

const WAIT_BETWEEN_GAMES = 20
const READ_TIME = 10

onready var binary = load("res://Binary/Binary.tscn")
onready var charge = load("res://Charge/Charge.tscn")
onready var dialTune = load("res://DialTune/DialTune.tscn")
onready var findSeq = load("res://FindSeq/FindSeq.tscn")
onready var gauges = load("res://Gauges/Gauges.tscn")
onready var keyTurn = load("res://KeyTurn/KeyTurn.tscn")
onready var laserAlign = load("res://LaserAlign/LaserAlign.tscn")
onready var reboot = load("res://Reboot/Reboot.tscn")
onready var tubes = load("res://Tubes/Tubes.tscn")

onready var game_list =       [binary, charge, dialTune, findSeq, gauges, laserAlign, reboot, tubes]
var game_timer_list = [30,     30,     30,       30,      30,     30,         30,     30]

var message_options = ['FREQ', 'SAT', 'CODE', 'SER', 'ORD', 'MSG', 'SIGN', 'STAT', 'GEO', 'POS', 'TRAJ', 'KEY', 'RES', 'SPD']
var number_of_messages = 5
var message_prompt_list = []  # populated in _ready
var message_answer_list = []  # populated in _ready (1 - 5)

onready var cover_list = [$StaticScreen/cover_0, $StaticScreen/cover_1, $StaticScreen/cover_2, $StaticScreen/cover_3]
onready var spawn_list = [$StaticScreen/panel_0_spawn, $StaticScreen/panel_1_spawn, $StaticScreen/panel_2_spawn, $StaticScreen/panel_3_spawn]

func _ready():
	randomize()
	#spawn a random game in a random location at the start
	for cover in cover_list:
		cover.show()
	
	# Randomize messages
#	message_options_list.shuffle()

	for i in range(number_of_messages):
		message_prompt_list.append(message_options[i])
		message_answer_list.append(randi() % 5 + 1)
	
func _process(delta):
	for active_game in active_games:
		if active_game.completed:
			# remove active_game from active list
			active_games.erase(active_game)
#			print("ACTIVE_GAME REMOVED: ", active_game)
			# start timer
			var new_read_timer = Timer.new()
			new_read_timer.connect("timeout", self, "_on_read_timer_timeout", [active_game])
			add_child(new_read_timer)
			new_read_timer.set('wait_time', READ_TIME)
			new_read_timer.start()


func _on_SpawnTimer_timeout():
	$SpawnTimer.wait_time = WAIT_BETWEEN_GAMES
#	$SpawnTimer.wait_time = 1
	$SpawnTimer.start()
	
	# leave function if all panels are active
	var total_active = 0
	for game_num in panels_game_type:
		if game_num >= 0:
			total_active += 1

	if total_active < 4:  # less than 4 active panels, can add
		# get random panel number that isn't active
		var panel_idx = randi() % 4
		while panels_game_type[panel_idx] > -1:  # find new rand_idx
			panel_idx = randi() % 4
		
		var new_game_idx = randi() % len(game_list)
		panels_game_type[panel_idx] = new_game_idx
		
		var new_game = game_list[new_game_idx].instance()
		new_game.set('panel_location', panel_idx)
		new_game.set('message', "TEST")
		
		spawn_list[panel_idx].add_child(new_game)
		cover_list[panel_idx].hide()
		
		active_games.append(new_game)

func _on_read_timer_timeout(game):
#	print("READ_TIMER")
#	print("active_games: ", active_games)
#	print("game: ", game)
	if game:  # check if it exists
		print("PANEL:", game.panel_location)
		panels_game_type[game.panel_location] = -1
		game.free()

