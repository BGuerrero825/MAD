extends Node2D

export var message := "NULL"
export var completed := false
export var panel_location := 0
export var game_timer := 20

const TUBE_WIDTH = 6
const COLOR_ORANGE = Color('fb9d28')
const COLOR_GREEN = Color('6abe30')
const COLOR_RED = Color('fa0404')
const DARK_GRAY = Color('595652')

const MOVE_SPEED = 25

var key_left_up := '-'
var key_left_down := '-'
var key_right_up := '-'
var key_right_down := '-'
var key_list := []  # populated in assign input
onready var key_labels := [$ui/key_left_up, $ui/key_left_down, $ui/key_right_up, $ui/key_right_down]

onready var ball = load("res://LaserAlign/ball.tscn")

var init_direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	assign_input()
	
	var dir_options = [Vector2(2, -1), Vector2(-2, -1), Vector2(-1, -1), Vector2(1, -1)]
	randomize()
	dir_options.shuffle()
	init_direction = dir_options[-1].normalized()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Input
	if Input.is_action_pressed(key_left_up):
		$reflector_left.position.y -= MOVE_SPEED * delta
		$reflector_left.position.y = clamp($reflector_left.position.y, $laser_frame/top_of_frame.position.y, $laser_frame/bottom_of_frame.position.y)
	elif Input.is_action_pressed(key_left_down):
		$reflector_left.position.y += MOVE_SPEED * delta
		$reflector_left.position.y = clamp($reflector_left.position.y, $laser_frame/top_of_frame.position.y, $laser_frame/bottom_of_frame.position.y)
	
	if Input.is_action_pressed(key_right_up):
		$reflector_right.position.y -= MOVE_SPEED * delta
		$reflector_right.position.y = clamp($reflector_right.position.y, $laser_frame/top_of_frame.position.y, $laser_frame/bottom_of_frame.position.y)
	elif Input.is_action_pressed(key_right_down):
		$reflector_right.position.y += MOVE_SPEED * delta
		$reflector_right.position.y = clamp($reflector_right.position.y, $laser_frame/top_of_frame.position.y, $laser_frame/bottom_of_frame.position.y)
	
	# Aesthetics/Sounds
	for i in range(len(key_list)):
		if Input.is_action_just_pressed(key_list[i]):
			key_labels[i].add_color_override("font_color", COLOR_GREEN)
			$sounds/click_in.play()
		elif Input.is_action_just_released(key_list[i]):
			key_labels[i].add_color_override("font_color", COLOR_ORANGE)
			$sounds/click_out.play()


func _on_spawn_timer_timeout():
	var new_ball = ball.instance()
	$spawn_point.add_child(new_ball)
	new_ball.direction = init_direction


func _on_target_area_entered(_area):
	if not completed:
		completed = true
		$output_bar.set_bar(100)
		$output_bar.set_bar_color("green")
		$output_bar.set_message(message)
		$sounds/completed_beep.play()

func assign_input():
	match panel_location:
		0:
			key_left_up = 'A'
			key_left_down = 'Z'
			key_right_up = 'S'
			key_right_down = 'X'
		1:
			key_left_up = 'E'
			key_left_down = 'D'
			key_right_up = 'R'
			key_right_down = 'F'
		2:
			key_left_up = 'G'
			key_left_down = 'B'
			key_right_up = 'H'
			key_right_down = 'N'
		3:
			key_left_up = 'I'
			key_left_down = 'K'
			key_right_up = 'O'
			key_right_down = 'L'
	
	# Update key_list
	key_list = [key_left_up, key_left_down, key_right_up, key_right_down]
	
	# Update panel key indicators
	$ui/key_left_up.text = key_left_up
	$ui/key_left_down.text = key_left_down
	$ui/key_right_up.text = key_right_up
	$ui/key_right_down.text = key_right_down
	
