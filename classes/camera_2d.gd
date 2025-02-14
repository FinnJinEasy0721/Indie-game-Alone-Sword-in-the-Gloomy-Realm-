extends Camera2D
#震屏脚本
#制作新场景时将新场景的camera2d节点挂载此脚本

@export var recovery_speed:=16.0#恢复速度，单位px/s
@export var strength:=0.0#震动强度

func _ready() -> void:
	Game.camera_should_shake.connect(func(amount:float):
		strength+=amount	
	)


func _process(delta: float) -> void:
	offset=Vector2(
		randf_range(-strength,+strength),#x
		randf_range(-strength,+strength)#y
	)
	strength=move_toward(strength,0,recovery_speed*delta)
