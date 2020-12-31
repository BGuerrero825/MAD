extends ReferenceRect

export var message := "80% CLOUDY"
<<<<<<< Updated upstream
=======

>>>>>>> Stashed changes
export var panel_location := 0  # panel location 0-3
export var download_speed := 24

var solution_phase := 0
var solution_freq := 0

# Randomize in _ready() to not be the same as solution
var player_phase := 0
var player_freq := 0

# Inputs
var key_dial_a_left := '-'
var key_dial_a_right := '-'
var key_dial_b_left := '-'
var key_dial_b_right := '-'
var key_download := '-'

var downloading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	assign_input()
	
	randomize()
	solution_phase = randi() % 4
	solution_freq = randi() % 4
	
	while player_phase == solution_phase:
		player_phase = randi() % 4
	while player_freq == solution_freq:
		player_freq = randi() % 4
	
	draw_graph_1()
	draw_graph_2()


func draw_graph_1():
	var freq : float = solution_freq + 1
	var phase : float = solution_phase * 1.5
	for i in range(len($Graph1/line.points)):
		$Graph1/line.points[i] = Vector2(i+1, 8*sin(freq*i + phase) + 10)


func draw_graph_2():
	var freq : float = player_freq + 1
	var phase : float = player_phase * 1.5
	for i in range(len($Graph2/line.points)):
		$Graph2/line.points[i] = Vector2(i+1, 8*sin(freq*(i + phase)) + 10)
	
	# Update Dials
	$DialA.frame = player_phase
	$DialB.frame = player_freq


func _process(delta):
	
	# INPUT
	
	# Dial A
	if Input.is_action_just_released(key_dial_a_left):
		player_phase = max(player_phase-1, 0)
		draw_graph_2()
	elif Input.is_action_just_released(key_dial_a_right):
		player_phase = min(player_phase+1, 3)
		draw_graph_2()
	
	# Dial B
	if Input.is_action_just_released(key_dial_b_left):
		player_freq = max(player_freq-1, 0)
		draw_graph_2()
	elif Input.is_action_just_pressed(key_dial_b_right):
		player_freq = min(player_freq+1, 3)
		draw_graph_2()
	
	# Start Download
	if not downloading and Input.is_action_just_pressed(key_download):
		$output_bar/output_message.text = ""
		
		print("phase_match: ", solution_phase == player_phase,  
				"\tfreq_match: ", solution_freq == player_freq)
		print("\tplayer: ", player_phase, " ", player_freq)
		print("\tsolution: ", solution_phase, " ", solution_freq)
		# Check if player phase and freq match solution
		$output_bar/load_bar.rect_size.x = 1
		downloading = true
	elif downloading:
		var orange = Color('fb9d28')
		var red = Color('fa0404')
		var green = Color('6abe30')
		
		$output_bar/load_bar.color = orange
		
		if $output_bar/load_bar.rect_size.x < 87:
			$output_bar/load_bar.rect_size.x += download_speed * delta # grow bar
		else:
			if (solution_phase == player_phase) and (solution_freq == player_freq):
				$output_bar/output_message.text = message
				$output_bar/load_bar.color = green
			else:
				$output_bar/output_message.text = "Bad Signal"
				$output_bar/load_bar.color = red
				downloading = false


func assign_input():
	match panel_location:
		0:
			key_dial_a_left = '1'
			key_dial_a_right = '2'
			key_dial_b_left = 'a'
			key_dial_b_right = 's'
			key_download = 'z'
		1:
			key_dial_a_left = '4'
			key_dial_a_right = '5'
			key_dial_b_left = 'd'
			key_dial_b_right = 'f'
			key_download = 'c'
		2:
			key_dial_a_left = '6'
			key_dial_a_right = '7'
			key_dial_b_left = 'g'
			key_dial_b_right = 'h'
			key_download = 'b'
		3:
			key_dial_a_left = '9'
			key_dial_a_right = '0'
			key_dial_b_left = 'k'
			key_dial_b_right = 'l'
			key_download = 'm'
	
	# Update panel key indicators
	$dial_a_left.text = key_dial_a_left
	$dial_a_right.text = key_dial_a_right
	$dial_b_left.text = key_dial_b_left
	$dial_b_right.text = key_dial_b_right
	$download_prompt.text = key_download
