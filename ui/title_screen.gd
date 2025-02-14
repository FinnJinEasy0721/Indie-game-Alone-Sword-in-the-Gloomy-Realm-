extends Control
@onready var v: VBoxContainer = $v
@onready var new_game: Button = $v/NewGame
@onready var load_game: Button = $v/LoadGame

func _ready() -> void:
	load_game.disabled=not Game.has_save()
	
	new_game.grab_focus()#一开始获取键盘焦点
	
	##菜单方框跟着鼠标走，而不是鼠标点击后再出现方框
	#for button:Button in v.get_children():
		#button.mouse_entered.connect(button.grab_focus)
		
	SoundManager.setup_ui_sounds(self)
	SoundManager.play_bgm(preload("res://素材/SFX and BGM/22 - The Final of The Fantasy.mp3"))


func _on_new_game_pressed() -> void:
	Game.new_game()


func _on_load_game_pressed() -> void:
	Game.load_game()


func _on_exit_game_pressed() -> void:
	get_tree().quit()
