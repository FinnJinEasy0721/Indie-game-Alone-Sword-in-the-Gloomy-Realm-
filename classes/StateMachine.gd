class_name StateMachine
extends Node

const KEEP_CURRENT:=-1

var current_state:int=-1:#设置为-1防止状态机产生歧义
	set(v):
		owner.transition_state(current_state,v)
		current_state=v
		
var state_time:float
		
func _ready() -> void:
	await owner.ready#等待owner的ready信号，确保transition_state不出问题
	current_state=0
	
func _physics_process(delta: float) -> void:
	#死循环
	while true:
		var next := owner.get_next_state(current_state) as int
		if next==KEEP_CURRENT:
			break#跳出死循环
		current_state=next
	
	#owner.tick_physics(current_state,delta)
	#state_time+=delta#会出现无法响应的bug
		
	#状态稳定下来后
	owner.tick_physics(current_state,delta)#状态机节点使用方不用再定义physics_process函数了,只需定义tick_physics
