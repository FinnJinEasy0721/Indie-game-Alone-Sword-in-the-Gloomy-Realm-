class_name Enemy
extends CharacterBody2D


enum Direction{
	LEFT=-1,
	RIGHT=+1,
}

@export var direction:=Direction.LEFT:
	set(v):
		direction=v
		#初始化
		if not is_node_ready():
			await ready
		graphics.scale.x=direction#设置x正方向不水平翻转图片
@export var max_speed:float=180
@export var acceleration:float=2000#敌人加速度

var default_gravity:=ProjectSettings.get("physics/2d/default_gravity") as float

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var stats: Stats = $Stats

func _ready() -> void:
	add_to_group("enemies")#父节点分组也行


func move(speed:float,delta:float)->void:
	velocity.x=move_toward(velocity.x,speed*direction,acceleration*delta)
	velocity.y+=default_gravity*delta
	
	move_and_slide()

#敌人死亡调用函数删除实体，在AnimationPlayer里以添加关键帧的方法调用
func die()->void:
	queue_free()
