extends Node2D

export var message := "NULL"
export var completed := false
export var panel_location := 0
export var game_timer := 30

export var electric_move_time := 0.2  # assign in _ready()

enum {HORZ=0, VERT=1, RED_HORZ=2, RED_VERT=3, GRN_HORZ=4, 
				GRN_VERT=5, TOP_RIGHT=6, BOT_RIGHT=7, BOT_LEFT=8, TOP_LEFT=9}

const TUBE_WIDTH = 6
const COLOR_ORANGE = Color('fb9d28')
const COLOR_GREEN = Color('6abe30')
const COLOR_RED = Color('fa0404')
const DARK_GRAY = Color('595652')

var key1 = '-'
var key2 = '-'
var key3 = '-'

var progress := 0

var key_list = []  # populated in assign_input()
onready var key_label_list = [$mx_frame_overlay/key1, $mx_frame_overlay/key2, $mx_frame_overlay/key3]

var maze = get_maze_list()
var switch_gates = []  # Populated in spawn_tube()
var switch_gates_original_types = []  # Copied from switch_gates in _ready()

var electric_ball_idx = 0  # index where the ball is currently in the maze list
var electric_ball_vec = Vector2(1, 0)  # Physical location of the ball
var electric_ball_dir = Vector2.RIGHT
var reset_electric_ball = false

var completion := 2  # set in ball_reached_end()
onready var completion_lights = [$mx_frame_overlay/completion_1, 
		$mx_frame_overlay/completion_2, $mx_frame_overlay/completion_3]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	assign_input()
	$electric_move_timer.wait_time = electric_move_time
	
	# Generate tubes based on maze list
	var current_loc = Vector2(1, 0)
	var current_dir = Vector2.RIGHT # start going right
	for i in range(len(maze)):
		var tube = maze[i]
		spawn_tube(current_loc, tube, i)
		current_dir = get_next_dir(current_dir, tube)
		current_loc += current_dir
	
	# randomize switch_gates order
	randomize()
	switch_gates.shuffle()
	
	for switch in switch_gates:
		switch_gates_original_types.append(switch[0].frame)  # append switch enum


func _process(delta):
	
	# Get key inputs to switch gate directions
	for i in range(len(switch_gates)):
		
		var current_key = key_list[i%3]
		var current_button = key_label_list[i%3]
		
		var gate = switch_gates[i][0]
		if Input.is_action_pressed(current_key):
			current_button.add_color_override("font_color", COLOR_GREEN)
			if gate.frame == RED_HORZ:
				gate.frame = GRN_VERT
			elif gate.frame == RED_VERT:
				gate.frame = GRN_HORZ
		else:
			current_button.add_color_override("font_color", COLOR_ORANGE)
			gate.frame = RED_HORZ
			gate.frame = switch_gates_original_types[i]
	
	# Add clicking sounds
	for key in key_list:
		if Input.is_action_just_pressed(key):
			#$sounds/click.play()
			$sounds/click_in.play()
		if Input.is_action_just_released(key):
			$sounds/click_out.play()


func _on_electric_move_timer_timeout():
	# electric_ball_idx, electric_ball_vec, electric_ball_dir
	
	# ball was reset
	if reset_electric_ball:
		electric_ball_idx = 0
		electric_ball_vec = Vector2(1, 0)
		electric_ball_dir = Vector2.RIGHT
		reset_electric_ball = false
	
	$mx_frame/maze_corner/electric_ball.position = TUBE_WIDTH * electric_ball_vec
	
	electric_ball_dir = get_next_dir(electric_ball_dir, maze[electric_ball_idx])
	electric_ball_vec += electric_ball_dir
	
	electric_ball_idx += 1
	if electric_ball_idx > len(maze)-1:  # ball reached end of maze
		ball_reached_end()


func ball_reached_end():
	reset_electric_ball = true
	
	completion += 1
	completion_lights[completion-1].color = COLOR_GREEN
	#update progress bar according to current progress
	if progress == 0:
		progress = 34
		$output_bar.set_bar(progress)
	elif progress > 0:
		progress = 67
		$output_bar.set_bar(progress)
	
	if completion >= 3:
		$electric_move_timer.stop()
		progress = 100
		completed = true
		$output_bar.set_bar(progress)
		$output_bar.set_bar_color("green")
		$output_bar.set_message(message)
		# signal completion
	

func get_next_dir(dir : Vector2, tube_type : int):
	match tube_type:
		
		# Detect bad dir on these
		RED_HORZ, GRN_HORZ, RED_VERT, GRN_VERT:
			# reset ball idx
			if electric_ball_dir == Vector2.DOWN or electric_ball_dir == Vector2.UP:
				for switch in switch_gates:
					if switch[1] == electric_ball_idx:
						if not (switch[0].frame == RED_VERT or switch[0].frame == GRN_VERT):
							reset_electric_ball = true
			elif electric_ball_dir == Vector2.LEFT or electric_ball_dir == Vector2.RIGHT:
				for switch in switch_gates:
					if switch[1] == electric_ball_idx:
						if not (switch[0].frame == RED_HORZ or switch[0].frame == GRN_HORZ):
							reset_electric_ball = true
			
			return dir  # always return next dir for maze gen
		
		# Change dir
		TOP_RIGHT:
			if dir == Vector2.RIGHT:
				return Vector2.DOWN
			elif dir == Vector2.UP:
				return Vector2.LEFT
			else:
				print("ERROR, hit outside of pipe corner")
		BOT_RIGHT:
			if dir == Vector2.RIGHT:
				return Vector2.UP
			elif dir == Vector2.DOWN:
				return Vector2.LEFT
			else:
				print("ERROR, hit outside of pipe corner")
		BOT_LEFT:
			if dir == Vector2.DOWN:
				return Vector2.RIGHT
			elif dir == Vector2.LEFT:
				return Vector2.UP
			else:
				print("ERROR, hit outside of pipe corner")
		TOP_LEFT:
			if dir == Vector2.UP:
				return Vector2.RIGHT
			elif dir == Vector2.LEFT:
				return Vector2.DOWN
		_:
			return dir


func spawn_tube(vec : Vector2, tube_type : int, idx : int):
# x = offset (0 - 11)
# y = offset (0 - 11)
# tube_type = tube_type enum
	var new_tube = $mx_frame/maze_corner/tube.duplicate()
	new_tube.frame = tube_type
	new_tube.offset.x = TUBE_WIDTH * vec.x
	new_tube.offset.y = TUBE_WIDTH * vec.y
	
	if tube_type in [RED_HORZ, RED_VERT]:
		switch_gates.append([new_tube, idx])
	
	$mx_frame/maze_corner.add_child(new_tube)


func get_maze_list():
	# 0,0 HORZ and 11,11 VERT are always there
	# Only use RED_HORZ & RED_VERT to indicate location, do not use GRN
	# Add one extra vert to the end of the list
	var m1 = [HORZ, HORZ, HORZ, HORZ, TOP_RIGHT, VERT, VERT, BOT_LEFT, HORZ, 
			BOT_RIGHT, VERT, TOP_LEFT, TOP_RIGHT, VERT, VERT, RED_HORZ, VERT, 
			BOT_RIGHT, HORZ, HORZ, HORZ, HORZ, HORZ, RED_HORZ, HORZ, TOP_LEFT,
			VERT, RED_VERT, BOT_LEFT, HORZ, HORZ, HORZ, BOT_RIGHT, TOP_LEFT, 
			HORZ, RED_VERT, HORZ, TOP_RIGHT, VERT, VERT, BOT_LEFT, HORZ, HORZ, TOP_RIGHT, VERT]
	
	var m2 = [HORZ, HORZ, HORZ, HORZ, HORZ, TOP_RIGHT, BOT_RIGHT, HORZ, HORZ, 
			RED_VERT, HORZ, TOP_LEFT, VERT, VERT, VERT, BOT_LEFT, HORZ, HORZ, 
			RED_HORZ, HORZ, BOT_RIGHT, VERT, TOP_RIGHT, HORZ, BOT_LEFT, TOP_LEFT,
			HORZ, HORZ, RED_VERT, HORZ, TOP_RIGHT, VERT, VERT, RED_HORZ, VERT,
			BOT_RIGHT, HORZ, HORZ, RED_VERT, HORZ, TOP_LEFT, BOT_RIGHT, TOP_LEFT,
			BOT_LEFT, HORZ, HORZ, HORZ, TOP_RIGHT, VERT, BOT_LEFT, HORZ, RED_VERT,
			HORZ, TOP_RIGHT, VERT]
	
	var m3 = [HORZ, HORZ, TOP_RIGHT, VERT, RED_HORZ, BOT_LEFT, BOT_RIGHT, TOP_LEFT,
			HORZ, HORZ, TOP_RIGHT, RED_VERT, VERT, VERT, RED_HORZ, VERT, BOT_RIGHT,
			HORZ, HORZ, HORZ, RED_VERT, TOP_LEFT, BOT_LEFT, HORZ, HORZ, HORZ, HORZ,
			HORZ, TOP_RIGHT, RED_HORZ, BOT_LEFT, BOT_RIGHT, VERT, VERT, TOP_LEFT,
			HORZ, TOP_RIGHT, RED_VERT, VERT, RED_HORZ, VERT]
	
	var m4 = [TOP_RIGHT, VERT, VERT, VERT, RED_HORZ, VERT, VERT, VERT, VERT,
			BOT_LEFT, HORZ, BOT_RIGHT, VERT, VERT, RED_VERT, VERT, VERT, VERT,
			RED_HORZ, TOP_LEFT, HORZ, HORZ, TOP_RIGHT, VERT, RED_HORZ, BOT_LEFT,
			HORZ, HORZ, HORZ, TOP_RIGHT, RED_HORZ, BOT_RIGHT, HORZ, HORZ, HORZ,
			TOP_LEFT, VERT, VERT, VERT, BOT_LEFT, RED_HORZ, HORZ, BOT_RIGHT,
			VERT, VERT, TOP_LEFT, HORZ, TOP_RIGHT, VERT, VERT, RED_HORZ, VERT, VERT]
	
	var maze_options = [m1, m2, m3, m4]
	randomize()
	# create list of mazes, return random maze
	return maze_options[randi()%len(maze_options)]


func assign_input():
	match panel_location:
		0:
			key1 = '1'
			key2 = '2'
			key3 = '3'
		1:
			key1 = 'E'
			key2 = 'R'
			key3 = 'T'
		2:
			key1 = '6'
			key2 = '7'
			key3 = '8'
		3:
			key1 = 'J'
			key2 = 'K'
			key3 = 'L'
	
	# Update key_list
	key_list = [key1, key2, key3]
	
	# Update panel key indicators
	$mx_frame_overlay/key1.text = key1
	$mx_frame_overlay/key2.text = key2
	$mx_frame_overlay/key3.text = key3



