extends Control

signal message_completed(message_played)

export var message_text := "GOOD MORNING COMRADE.  CONGRATULATIONS ON FINISHING YOUR INITIAL QUALIFICATION. DON’T FORGET TO WRITE DOWN ALL RESULTS YOU COLLECT IN YOUR JOURNAL. THE AMERICANS HAVE BEEN QUIET LATELY SO DON’T EXPECT THAT MUCH ACTIVITY."
export var playing := false


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/Label.percent_visible = 0

func _process(delta):
	if playing:
		show()
		$ColorRect/Label.text = message_text
		$ColorRect/Label.percent_visible += 40 * delta / len(message_text)
		if $ColorRect/Label.percent_visible >= .99: 
			if Input.is_action_just_released("ui_accept"):
				emit_signal("message_completed", message_text)
				playing = false
				$ColorRect/Label.percent_visible = 0
		elif $ColorRect/Label.percent_visible > .001:
			if Input.is_action_just_released("ui_accept"):
				$ColorRect/Label.percent_visible = 1
	if not playing:
		hide()
		$ColorRect/Label.percent_visible = 0
