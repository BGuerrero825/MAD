extends Node2D


export var current_level := 0
export var message_prompt_list := []

var active = false

# Called when the node enters the scene tree for the first time.
#func _ready():
#	print(message_prompt_list)
#	print(message_answer_list)


func _process(delta):
	if visible and not active:
		active = true
		
		print(message_prompt_list)
		# [FREQ: 4, SAT: 2, CODE: 4, SER: 1, ORD: 3]
		var answer_list = []
		var message_list_without_answers = []
		for message in message_prompt_list:
			answer_list.append(int(message[-1]))
#			message_list_without_answers.append(message[0:-1])
		print(answer_list)
		print(message_list_without_answers)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
