extends Interactable

func interact()->void:
	super()
	await  get_tree().create_timer(0.5).timeout
	Game.change_scene("res://ui/game_end_screen.tscn",{
		duration=1,
	})
