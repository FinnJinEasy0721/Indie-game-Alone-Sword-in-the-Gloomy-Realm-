class_name EntryPoint#传送点
extends Marker2D

@export var direction:=Player.Direction.RIGHT

func _ready() -> void:
	add_to_group("entry_points")
