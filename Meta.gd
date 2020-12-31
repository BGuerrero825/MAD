extends Node2D

var panels_active = [false,false,false,false]
var dialTune = load("res://DialTune/DialTune.tscn")
var findSeq = load("res://FindSeq/FindSeq.tscn")

func _ready():
	var newGame = dialTune.instance()
	$StaticScreen/panel_0_spawn.add_child(newGame)
	
	
func _process(delta):
	pass


func _on_SpawnTimer_timeout():
	print("spawned")
