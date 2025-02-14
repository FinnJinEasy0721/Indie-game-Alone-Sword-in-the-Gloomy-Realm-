extends Interactable
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func interact()->void:
	super()
	
	animation_player.play("activated")
	SoundManager.play_sfx("openbox")
	Game.save_game()
