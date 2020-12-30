extends ReferenceRect

export var key_dial_a_left := 'a'
export var key_dial_a_right := 'd'
export var key_dial_b_left := 'q'
export var key_dial_b_right := 'e'

export var solution_phase := 0
export var solution_freq := 0

# Randomize in _ready() to not be the same as solution
var player_phase := solution_phase
var player_freq := solution_freq


# Called when the node enters the scene tree for the first time.
func _ready():
	
	randomize()
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
	$DialA.text = str(player_phase)
	$DialB.text = str(player_freq)


func _process(delta):
	
	# INPUT
	
	# Left Dial
	if Input.is_action_just_released("z"):
		player_phase = max(player_phase-1, 0)
		draw_graph_2()
	elif Input.is_action_just_released("c"):
		player_phase = min(player_phase+1, 3)
		draw_graph_2()
	
	# Right Dial
	if Input.is_action_just_released("u"):
		player_freq = max(player_freq-1, 0)
		draw_graph_2()
	elif Input.is_action_just_pressed("o"):
		player_freq = min(player_freq+1, 3)
		draw_graph_2()
	
	# Start Download
	if Input.is_action_just_pressed("space"):
		print("phase_match: ", solution_phase == player_phase,  
				"\tfreq_match: ", solution_freq == player_freq)
		print("\tplayer: ", player_phase, " ", player_freq)
		print("\tsolution: ", solution_phase, " ", solution_freq)

