class_name World
extends Node2D

@export var bgm:AudioStream

@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var tile_map: TileMap = $TileMap
@onready var player: Player = $Player

func _ready() -> void:
	#var used:=tile_map.get_used_rect()
	#var tile_size:=tile_map.tile_set.tile_size
	#camera_2d.limit_top=used.position.y*tile_size.y
	#camera_2d.limit_right=used.position.x*tile_size.x
	#camera_2d.limit_bottom=used.position.y*tile_size.y
	#camera_2d.limit_left=used.position.x*tile_size.x
	if bgm:
		SoundManager.play_bgm(bgm)

#玩家传送坐标
func update_player(pos:Vector2,direction:Player.Direction)->void:
	player.global_position=pos
	#player.fall_from_y=pos.y#取消landing动画，存在bug
	player.direction=direction
	camera_2d.reset_smoothing()
	camera_2d.force_update_scroll()#4.2后必须加

#测试代码
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_cancel"):#esc
		#Game.back_to_title()
	

func to_dict()->Dictionary:
	var enemies_alive:=[]
	for node in get_tree().get_nodes_in_group("enemies"):
		var path:=get_path_to(node) as String
		enemies_alive.append(path)
		
	return{
		enemies_alive=enemies_alive
	}


func from_dict(dict:Dictionary)->void:
	for node in get_tree().get_nodes_in_group("enemies"):
		var path:=get_path_to(node) as String
		if path not in dict.enemies_alive:
			node.queue_free()
	
