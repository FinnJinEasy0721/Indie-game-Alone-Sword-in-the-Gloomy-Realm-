extends "res://World/world.gd"

#这个函数以后的每一个关卡都要添加
func _ready() -> void:
	super._ready()  # 确保调用父类原有逻辑
	await get_tree().process_frame# 延迟一帧确保场景完全加载
	Game.player_stats.health = Game.player_stats.max_health#恢复生命值
	Game.save_game()#调用全局
