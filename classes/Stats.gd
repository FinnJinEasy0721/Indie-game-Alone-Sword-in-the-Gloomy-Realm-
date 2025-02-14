class_name Stats#角色的统计信息:血量、攻击力、防御力等
extends Node

signal  health_changed

@export var max_health:int =3

@onready var health:int=max_health:#加入onready初始化防止max_health改变时health不改变
	set(v):
		v=clampi(v,0,max_health)
		if health==v:
			return
		health=v
		health_changed.emit()


func to_dict()->Dictionary:
	return{
		max_health=max_health,
		health=health
	}
	
func from_dict(dict:Dictionary)->void:
	max_health-dict.max_health
	health=dict.health
