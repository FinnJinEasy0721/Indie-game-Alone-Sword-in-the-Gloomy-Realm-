extends Interactable#第一关游戏通关的交互按钮

@export_file("*.tscn") var path:String

func interact()->void:
	await get_tree().create_timer(0.5).timeout
	Game.change_scene(path)
	

	
