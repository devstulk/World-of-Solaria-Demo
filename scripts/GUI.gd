extends CanvasLayer

signal start_game

@onready var title = $title
@onready var game_menu = $game_menu
@onready var credits_text = $credits_text
@onready var controls_text = $controls_text
@onready var start_btn = $game_menu/start_btn
@onready var game_over_menu = $game_over_menu
@onready var pause_menu = $pause_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	_show_menu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _show_menu():
	credits_text.hide()
	controls_text.hide()
	game_over_menu.hide()
	title.show()
	game_menu.show()
	pause_menu.hide()


func _on_exit_btn_pressed():
	get_tree().quit()


func _on_credits_btn_pressed():
	credits_text.show()
	title.hide()
	game_menu.hide()
	pause_menu.hide()
	game_over_menu.hide()


func _on_controls_btn_pressed():
	controls_text.show()
	title.hide()
	game_menu.hide()
	pause_menu.hide()
	game_over_menu.hide()


func _on_credits_text_meta_clicked(meta):
	OS.shell_open(meta)


func _on_start_btn_pressed():
	start_game.emit()


func _show_pause_menu():
	pause_menu.show()
	title.hide()
	game_menu.hide()
	credits_text.hide()
	controls_text.hide()
	show()

func _show_game_over_menu():
	game_menu.hide()
	title.hide()
	pause_menu.hide()
	game_over_menu.show()
	show()


func _on_back_to_menu_pressed():
	get_tree().reload_current_scene()
