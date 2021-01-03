extends Node2D

var panels_active = [false,false,false,false]
var dialTune = load("res://DialTune/DialTune.tscn")
var findSeq = load("res://FindSeq/FindSeq.tscn")

func _ready():
	#spawn a random game in a random location at the start
	var newGame = dialTune.instance()
	$StaticScreen/panel_2_spawn.add_child(newGame)
	$StaticScreen/cover_2.visible = false
	
func _process(delta):
	pass

func _on_SpawnTimer_timeout():
	# on timer interval spawn a random new game into a random available location
	var newGame = findSeq.instance()
	$StaticScreen/panel_1_spawn.add_child(newGame)
	$StaticScreen/cover_1.visible = false
