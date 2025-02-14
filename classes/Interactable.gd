class_name Interactable#可交互逻辑
extends Area2D

signal interacted

func _init() -> void:
	#把碰撞层和碰撞遮罩清零
	collision_layer=0
	collision_mask=0
	set_collision_mask_value(2,true)
	#定义信号连接
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func interact()->void:
	print("[Interact]%s"%name)#打印信号，排查bug
	interacted.emit()

#交互注册
func _on_body_entered(player:Player)->void:
	player.register_interactable(self)
func _on_body_exited(player:Player)->void:
	player.unregister_interactable(self)
