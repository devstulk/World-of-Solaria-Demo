extends Node2D

@onready var spawn_slime = $spawn_slime
@onready var path_spawn_follow = $path_spawn/path_spawn_follow
@onready var GUI = $GUI

const SLIME = preload("res://scenes/slime.tscn")

var slime_count = 5
var slime_limit = 5
var game_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("pause") and game_started:
		_pause_game()


func _pause_game():
	get_tree().paused = true
	GUI._show_pause_menu()
	

func _spawn_slime():
	var slime = SLIME.instantiate()
	path_spawn_follow.progress_ratio = randf_range(0, 1)
	slime.position = path_spawn_follow.position
	find_child("florest").add_child(slime)
	slime_count += 1

func _on_spawn_slime_timeout():
	if slime_count < slime_limit:
		_spawn_slime()


func _on_gui_start_game():
	GUI.hide()
	get_tree().paused = false
	game_started = true
