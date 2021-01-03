extends Node2D

var panels_game_type = [-1, -1, -1, -1]  # -1 indicates no game
var active_games = []

const WAIT_BETWEEN_GAMES = 20
const READ_TIME = 8
const SHIFT_TIME = 120

onready var binary = load("res://Binary/Binary.tscn")
onready var charge = load("res://Charge/Charge.tscn")
onready var dialTune = load("res://DialTune/DialTune.tscn")
onready var findSeq = load("res://FindSeq/FindSeq.tscn")
onready var gauges = load("res://Gauges/Gauges.tscn")
onready var keyTurn = load("res://KeyTurn/KeyTurn.tscn")
onready var laserAlign = load("res://LaserAlign/LaserAlign.tscn")
onready var reboot = load("res://Reboot/Reboot.tscn")
onready var tubes = load("res://Tubes/Tubes.tscn")

onready var game_list = [binary, charge, dialTune, findSeq, gauges, laserAlign, reboot, tubes, keyTurn]

var message_options = ['FREQ', 'SAT', 'CODE', 'SER', 'ORD', 'MSG', 'SIGN', 'STAT', 'GEO', 'POS', 'TRAJ', 'KEY', 'RES', 'SPD']
var number_of_messages = 6  # 6 is max
var message_prompt_list = []  # populated in _ready
var message_saved_prompt_list = []  # copy of messages

onready var cover_list = [$StaticScreen/cover_0, $StaticScreen/cover_1, $StaticScreen/cover_2, $StaticScreen/cover_3]
onready var spawn_list = [$StaticScreen/panel_0_spawn, $StaticScreen/panel_1_spawn, $StaticScreen/panel_2_spawn, $StaticScreen/panel_3_spawn]
onready var loadbar_list = [$StaticScreen/panel_0_spawn/loadbar_0, $StaticScreen/panel_1_spawn/loadbar_1, $StaticScreen/panel_2_spawn/loadbar_2, $StaticScreen/panel_3_spawn/loadbar_3]
const LOAD_BAR_RIGHT_MARGIN = 70

var start_message = "GOOD MORNING COMRADE.  CONGRATULATIONS ON FINISHING YOUR INITIAL QUALIFICATION. DON’T FORGET TO WRITE DOWN ALL RESULTS YOU COLLECT IN YOUR JOURNAL. THE AMERICANS HAVE BEEN QUIET LATELY SO DON’T EXPECT THAT MUCH ACTIVITY."
var fail_message = "I FOUND SEVERAL ERRORS IN YOUR REPORT. TRY AGAIN."
var pass_message = "GOOD JOB COMRADE. TAKE A QUICK BREAK AND I WILL TAKE OVER. SEE YOU SOON."


#onready var report = 

func _ready():
	randomize()
	#spawn a random game in a random location at the start
	for cover in cover_list:
		cover.show()
	
	# Randomize messages

	message_options.shuffle()

	for i in range(number_of_messages):
		message_prompt_list.append(message_options[i] + ": " + str(randi()%5+1))
	message_saved_prompt_list = message_prompt_list.duplicate()
	
	# add messages and answers to SubmitReport
	$SubmitReport.message_prompt_list = message_saved_prompt_list
#	$SubmitReport.message_answer_list = message_answer_list
	
	# start message
	$speech.set('message_text', start_message)
	$speech.set('playing', true)
	
	$ShiftTimer.wait_time = SHIFT_TIME
	


func _process(delta):
	if $ShiftTimer.time_left < (SHIFT_TIME-5) and not $speech.visible:
		if Input.is_action_just_released("submit_report") and not $SubmitReport.visible:  # ENTER
			$SubmitReport.visible = true
			
			$SpawnTimer.stop()
			for cover in cover_list:
				cover.visible = true
			for game in active_games:
				if game:
					game.free()


func _on_HeartBeat_timeout():
	for active_game in active_games:
		if active_game:
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

	if total_active < 4:  # less than 4 active panels, can add game
		# get random panel number that isn't active
		var panel_idx = randi() % 4
		while panels_game_type[panel_idx] > -1:  # find new rand_idx
			panel_idx = randi() % 4
		
		var new_game_idx = randi() % len(game_list)
		panels_game_type[panel_idx] = new_game_idx
		
		var new_game = game_list[new_game_idx].instance()
		new_game.set('panel_location', panel_idx)
		#var new_msg = message_prompt_list.pop + " " + message_answer_list
		new_game.set('message', message_prompt_list.pop_back())
#		print(message_prompt_list)
		
		# START TIMER TO COMPLETE MINIGAME, SEND GAME TO THAT JUST LIKE READ_TIMER
		var new_read_timer = Timer.new()
		new_read_timer.connect("timeout", self, "_countdown_timer", [new_game])
		add_child(new_read_timer)
		new_read_timer.set('wait_time', 5)
		new_read_timer.start()
		
		spawn_list[panel_idx].add_child(new_game)
		cover_list[panel_idx].hide()
		
		loadbar_list[new_game.panel_location].margin_right = 30
		
		active_games.append(new_game)


func _countdown_timer(game):
	if game:
		game.game_timer -= 5
#		print("GAME_TIMER: ", game.game_timer)
		
		# update loadbar width
		var new_loadbar_width = 30 + 40*(1 - (float(game.game_timer) / 35))
		loadbar_list[game.panel_location].margin_right = new_loadbar_width
#		print("WIDTH: ", new_loadbar_width)
		
		if game.game_timer <= 0:
			loadbar_list[game.panel_location].margin_right = 70
			panels_game_type[game.panel_location] = -1
			cover_list[game.panel_location].show()
			message_prompt_list.append(game.message)
			
			game.free()


func _on_read_timer_timeout(game):
#	print("READ_TIMER")
#	print("active_games: ", active_games)
#	print("game: ", game)
	if game:  # check if it exists
		#print("PANEL:", game.panel_location)
		number_of_messages -= 1
		panels_game_type[game.panel_location] = -1
		loadbar_list[game.panel_location].margin_right = 70
		cover_list[game.panel_location].show()
		game.free()
		if number_of_messages <= 0:
			print("ALL MESSAGES RECEIVED")


func _on_SubmitReport_submitted(correct_submission):
	if correct_submission:
		$SubmitReport.hide()
		$speech.set('message_text', pass_message)
		$speech/ColorRect/Label.percent_visible = 0
		$speech.set('playing', true)
	elif not correct_submission:
		$SubmitReport.hide()
		$speech.set('message_text', fail_message)
		$speech/ColorRect/Label.percent_visible = 0
		$speech.set('playing', true)


func _on_speech_message_completed(message_played):
	if message_played == start_message:
		print("GREET_MESSAGE PLAYED")
		$SpawnTimer.start()
		$ShiftTimer.start()
	elif message_played == fail_message:
		print("FAIL_MESSAGE PLAYED")
	elif message_played == pass_message:
		print("PASS_MESSAGE PLAYED")

func _on_ShiftTimer_timeout():
	pass # Replace with function body.
