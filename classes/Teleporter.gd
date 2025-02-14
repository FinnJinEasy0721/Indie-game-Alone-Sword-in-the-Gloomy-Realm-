class_name Teleporter#传送器
extends Interactable

@export_file("*.tscn") var path:String
@export var entry_point:String


func interact()->void:
	super()
	SoundManager.play_sfx("GateOpen")
	Game.change_scene(path,{entry_point=entry_point})
