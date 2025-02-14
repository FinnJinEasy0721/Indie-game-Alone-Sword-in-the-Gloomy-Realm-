class_name Hitbox
extends Area2D

signal hit(hurtbox)

#调试函数
func _init() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hurtbox:Hurtbox)->void:
	print("[Hit] %s => %s"%[owner.name,hurtbox.owner.name])#测试代码
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self)
	
