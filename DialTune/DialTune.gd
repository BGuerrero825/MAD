extends Node2D

export var message := "FREQ: 4"
export var completed := false
export var panel_location := 0  # panel location 0-3

const COLOR_ORANGE = Color('fb9d28')
const COLOR_GREEN = Color('6abe30')
const COLOR_RED = Color('fa0404')

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

var downloading := false
var progress := 0.0
var progress_mult := 0.4

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
	var phase : float = solution_phase
	for i in range(len($Graph1/line.points)):
		$Graph1/line.points[i] = Vector2(i+1, 8*sin(freq*i + phase) + 10)


func draw_graph_2():
	var freq : float = player_freq + 1
	var phase : float = player_phase
	for i in range(len($Graph2/line.points)):
		$Graph2/line.points[i] = Vector2(i+1, 8*sin(freq*i + phase) + 10)
	
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
		
		# Check if player phase and freq match solution
		progress = 0
		downloading = true
	elif downloading:
		$output_bar.set_bar_color("orange")
		progress += 1 * progress_mult
		if ceil(progress) <= 100:
			$output_bar.set_bar(ceil(progress))
		else:
			if (solution_phase == player_phase) and (solution_freq == player_freq):
				completed = true
				$output_bar.set_bar(100)
				$output_bar.set_bar_color("green")
				$output_bar/output_message.text = message
			else:
				$output_bar/output_message.text = "Bad Signal"
				$output_bar.set_bar_color("red")
				downloading = false
				progress = 0
	
	
	# Button Animation and Sounds
	if Input.is_action_just_pressed(key_dial_a_left):
		$dial_a_left.add_color_override("font_color", COLOR_GREEN)
		$sounds/click_in.play()
		$sounds/radio_adjust2.play()
	elif Input.is_action_just_released(key_dial_a_left):
		$dial_a_left.add_color_override("font_color", COLOR_ORANGE)
		$sounds/click_out.play()
	if Input.is_action_just_pressed(key_dial_a_right):
		$dial_a_right.add_color_override("font_color", COLOR_GREEN)
		$sounds/click_in.play()
		$sounds/radio_adjust2.play()
	elif Input.is_action_just_released(key_dial_a_right):
		$dial_a_right.add_color_override("font_color", COLOR_ORANGE)
		$sounds/click_out.play()
	if Input.is_action_just_pressed(key_dial_b_left):
		$dial_b_left.add_color_override("font_color", COLOR_GREEN)
		$sounds/click_in.play()
		$sounds/radio_adjust1.play()
	elif Input.is_action_just_released(key_dial_b_left):
		$dial_b_left.add_color_override("font_color", COLOR_ORANGE)
		$sounds/click_out.play()
	if Input.is_action_just_pressed(key_dial_b_right):
		$dial_b_right.add_color_override("font_color", COLOR_GREEN)
		$sounds/click_in.play()
		$sounds/radio_adjust1.play()
	elif Input.is_action_just_released(key_dial_b_right):
		$dial_b_right.add_color_override("font_color", COLOR_ORANGE)
		$sounds/click_out.play()
	if Input.is_action_just_pressed(key_download):
		$download_prompt.add_color_override("font_color", COLOR_GREEN)
		$sounds/click_in.play()
	elif Input.is_action_just_released(key_download):
		$download_prompt.add_color_override("font_color", COLOR_ORANGE)
		$sounds/click_out.play()
	
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
