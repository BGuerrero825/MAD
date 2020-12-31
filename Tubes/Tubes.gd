extends Node2D

export var panel_location := 0

enum {HORZ=0, VERT=1, RED_HORZ=2, RED_VERT=3, GRN_HORZ=4, 
				GRN_VERT=5, TOP_RIGHT=6, BOT_RIGHT=7, BOT_LEFT=8, TOP_LEFT=9}

const TUBE_WIDTH = 6
const COLOR_ORANGE = Color('fb9d28')
const COLOR_GREEN = Color('6abe30')

var key1 = '-'
var key2 = '-'
var key3 = '-'

var maze = get_maze_list()
var switch_gates = []  # Populated in spawn_tube()
var switch_gates_original_types = []  # Copied from switch_gates in _ready()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	assign_input()
	
	# Generate tubes based on maze list
	var current_loc = Vector2(1, 0)
	var current_dir = Vector2.RIGHT # start going right
	for tube in maze:
		spawn_tube(current_loc, tube)
		current_dir = get_next_dir(current_dir, tube)
		current_loc += current_dir
	
	# randomize switch_gates order
#	randomize()
#	switch_gates.shuffle()
	
	# Assign keys to switch gates
	
	
	for switch in switch_gates:
		switch_gates_original_types.append(switch.frame)  # append switch enum
	
	print(switch_gates)
	print(switch_gates_original_types)


func _process(delta):
	for i in range(len(switch_gates)):
		var gate = switch_gates[i]
		if Input.is_action_pressed(key1):
#			$mx_frame_overlay/key1.custom_colors/font_color = 
			if gate.frame == RED_HORZ:
				gate.frame = GRN_VERT
			elif gate.frame == RED_VERT:
				gate.frame = GRN_HORZ
		else:
			gate.frame = RED_HORZ
			gate.frame = switch_gates_original_types[i]
			#gate.frame = switch_gates_original_types[switch_gates]

func get_next_dir(dir : Vector2, tube_type : int):
	match tube_type:
		# Detect bad dir on these
		RED_HORZ, GRN_HORZ:
			return dir
		RED_VERT, GRN_VERT:
			return dir
		
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


func spawn_tube(vec : Vector2, tube_type : int):
# x = offset (0 - 11)
# y = offset (0 - 11)
# tube_type = tube_type enum
	var new_tube = $mx_frame/maze_corner/tube.duplicate()
	new_tube.frame = tube_type
	new_tube.offset.x = TUBE_WIDTH * vec.x
	new_tube.offset.y = TUBE_WIDTH * vec.y
	
	if tube_type in [RED_HORZ, RED_VERT]:
		switch_gates.append(new_tube)
	
	$mx_frame/maze_corner.add_child(new_tube)


func get_maze_list():
	# 0,0 HORZ and 11,11 VERT are always there
	# Only use RED_HORZ & RED_VERT to indicate location, do not use GRN
	var m1 = [HORZ, HORZ, HORZ, HORZ, TOP_RIGHT, VERT, VERT, BOT_LEFT, HORZ, 
			BOT_RIGHT, VERT, TOP_LEFT, TOP_RIGHT, VERT, VERT, RED_VERT, VERT, 
			BOT_RIGHT, HORZ, HORZ, HORZ, HORZ, HORZ, RED_HORZ, HORZ, TOP_LEFT,
			VERT, RED_VERT, BOT_LEFT, HORZ, HORZ, HORZ, BOT_RIGHT, TOP_LEFT, 
			HORZ, RED_VERT, HORZ, TOP_RIGHT, VERT, VERT, BOT_LEFT, HORZ, HORZ, TOP_RIGHT]
	
	# create list of mazes, return random maze
	return m1


func assign_input():
	match panel_location:
		0:
			key1 = '1'
			key2 = '2'
			key3 = '3'
		1:
			key1 = 'e'
			key2 = 'r'
			key3 = 't'
		2:
			key1 = '6'
			key2 = '7'
			key3 = '8'
		3:
			key1 = 'j'
			key2 = 'k'
			key3 = 'l'
	
	# Update panel key indicators
	$mx_frame_overlay/key1.text = key1
	$mx_frame_overlay/key2.text = key2
	$mx_frame_overlay/key3.text = key3
