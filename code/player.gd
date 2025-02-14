class_name Player
extends CharacterBody2D

enum Direction{
	LEFT=-1,
	RIGHT=+1
}

enum State{
	IDLE,
	RUNNING,
	JUMP,
	FALL,
	LANDING,
	ATTACK_1,
	ATTACK_2,
	ATTACK_3,
	HURT,
	DYING
}
const GROUND_STATE:=[State.IDLE,State.RUNNING,State.LANDING,State.ATTACK_1,State.ATTACK_2,State.ATTACK_3]
const RUN_SPEED:=160.0
const JUMP_VELOCITY:=-340.0#跳跃高度
const FLOOR_ACCELERATION:=RUN_SPEED/0.2#完全静止到加速到RUN_SPEED需要0.2秒
const AIR_ACCELERATION:=RUN_SPEED/0.02#空中摩擦力
const KNOCKBACK_AMOUNT:=512.0

@export var can_combo:=false

#传送后人物朝向
@export var direction:=Direction.RIGHT:
	set(v):
		direction=v
		if not is_node_ready():
			await ready#安全访问graphics
		graphics.scale.x=direction

var is_combo_requested:=false
var pending_damage:Damage
var default_gravity:=ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick:=false
var interacting_with:Array[Interactable]#交互数组，防止交互时重叠导致第二次交互不显示E提示

@onready var graphics: Node2D = $Graphics#后补报错，修bug
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer
@onready var state_machine: Node = $StateMachine
@onready var stats: Node =Game.player_stats
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var interaction_icon: AnimatedSprite2D = $InteractionIcon
@onready var game_over_screen: Control = $CanvasLayer/GameOverScreen
@onready var pause_screen: Control = $CanvasLayer/PauseScreen

#func _ready() -> void:
	#stand(default_gravity)
	


#事件回调函数，用于实现丝滑连跳
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
		
	#长按w跳更高，短按w跳更低
	if event.is_action_released("jump"):
		jump_request_timer.stop()
		if velocity.y<JUMP_VELOCITY/2:
			velocity.y=JUMP_VELOCITY/2
			
	if event.is_action_pressed("attack") and can_combo:
		is_combo_requested=true
		
	if event.is_action_pressed("interact") and interacting_with:
		interacting_with.back().interact()
		
	if event.is_action_pressed("pause"):
		pause_screen.show_pause()


func tick_physics(state:State,delta:float) -> void:
	interaction_icon.visible=not interacting_with.is_empty()
	
	match state:
		State.IDLE:
			move(default_gravity,delta)
			
		State.RUNNING:
			move(default_gravity,delta)
			
		State.JUMP:
			move(0.0 if is_first_tick else default_gravity,delta)#0.0指关掉重力，这里是第一帧关掉重力影响
			
		State.FALL:
			move(default_gravity,delta)
			
		State.LANDING:
			stand(delta)
		
		State.ATTACK_1,State.ATTACK_2,State.ATTACK_3:
			stand(delta)
		
		State.HURT,State.DYING:
			stand(delta)
	
	is_first_tick=false


func move(gravity:float,delta:float)->void:
	var movement:=Input.get_axis("move_left","move_right")
	var acceleration:=FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x=move_toward(velocity.x,movement*RUN_SPEED,acceleration*delta)#水平移动加速度
	velocity.y+=gravity*delta
	
	if not is_zero_approx(movement):
		direction=Direction.LEFT if movement<0 else Direction.RIGHT
		#sprite_2d.flip_h=movement<0
	
	move_and_slide()
	#if global_position.y>120:
		#die()


#取消落地前landing动画的僵值	
func stand(delta:float)->void:
	var acceleration:=FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x=move_toward(velocity.x,0.0,acceleration*delta)
	velocity.y+=default_gravity*delta
	
	move_and_slide()
	

func die()->void:
	game_over_screen.show_game_over()
	
	
#交互注册
func register_interactable(v:Interactable)->void:
	if state_machine.current_state==State.DYING:#死亡状态不接受interactable交互
		return
	if v in interacting_with:
		return
	interacting_with.append(v)
#取消注册
func unregister_interactable(v:Interactable)->void:
	interacting_with.erase(v)

			
func get_next_state(state:State)->int:
	if stats.health==0:
		return StateMachine.KEEP_CURRENT if state==State.DYING else State.DYING
	
	#如果有待处理伤害	
	if pending_damage:
		return State.HURT
		
	var can_jump:=is_on_floor() or coyote_timer.time_left>0
	var should_jump:=can_jump and jump_request_timer.time_left>0
	if should_jump:
		return State.JUMP
	
	if state in GROUND_STATE and not is_on_floor():
		return State.FALL
		
	var movement:=Input.get_axis("move_left","move_right")
	var is_still:=is_zero_approx(movement) and is_zero_approx(velocity.x)
	
	match state:
		State.IDLE:
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK_1
			if not is_still:
				return State.RUNNING
			
		State.RUNNING:
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK_1
			if is_still:
				return State.IDLE
			
		State.JUMP:
			if velocity.y>=0:
				return State.FALL
			
		State.FALL:
			if is_on_floor():
				return State.LANDING if is_still else State.RUNNING
				
		State.LANDING:
			if not is_still:
				return State.RUNNING
			if not animation_player.is_playing():
				return State.IDLE	
				
		State.ATTACK_1:
			if not animation_player.is_playing():
				return State.ATTACK_2 if is_combo_requested else State.IDLE
				
		State.ATTACK_2:
			if not animation_player.is_playing():
				return State.ATTACK_3 if is_combo_requested else State.IDLE
				
		State.ATTACK_3:
			if not animation_player.is_playing():
				return State.IDLE
				
		State.HURT:
			if not animation_player.is_playing():
				return State.IDLE

	return StateMachine.KEEP_CURRENT


func transition_state(from:State, to:State)->void:
	if from not in GROUND_STATE and to in GROUND_STATE:
		coyote_timer.stop()
		
	match to:
		State.IDLE:
			animation_player.play("idle")
			
		State.RUNNING:
			animation_player.play("running")
			
		State.JUMP:
			animation_player.play("jump")
			SoundManager.play_sfx("jump")
			velocity.y=JUMP_VELOCITY
			coyote_timer.stop()
			jump_request_timer.stop()
			
		State.FALL:
			animation_player.play("fall")
			if from in GROUND_STATE:
				coyote_timer.start()#郊狼时间，离开地面0.1秒内也可以跳跃，场景树CoyoteTimer里修改判断时间
				
		State.LANDING:
			animation_player.play("landing")
			
		State.ATTACK_1:
			animation_player.play("a1")
			is_combo_requested=false
			SoundManager.play_sfx("a1")
		
		State.ATTACK_2:
			animation_player.play("a2")
			is_combo_requested=false
			SoundManager.play_sfx("a2")
			
		State.ATTACK_3:
			animation_player.play("a3")
			is_combo_requested=false
			SoundManager.play_sfx("a3")
			
		State.HURT:
			animation_player.play("hurt")
			SoundManager.play_sfx("hurt")
			Game.shake_camera(4)
			stats.health-=pending_damage.amount
			var dir:=pending_damage.source.global_position.direction_to(global_position)#击退方向
			velocity=dir*KNOCKBACK_AMOUNT

			pending_damage=null
			invincible_timer.start()
			
		State.DYING:
			animation_player.play("die")
			invincible_timer.stop()
			interacting_with.clear()#清空交互数组
				
	is_first_tick=true


func _on_hurtbox_hurt(hitbox: Variant) -> void:
	#受伤后无敌
	if invincible_timer.time_left>0:
		return
	
	pending_damage=Damage.new()
	pending_damage.amount=1#扣血量
	pending_damage.source=hitbox.owner#伤害来源
	

func _on_hitbox_hit(hurtbox: Variant) -> void:
	#攻击敌人震动强度
	Game.shake_camera(2)
	#顿帧
	Engine.time_scale=0.01
	await get_tree().create_timer(0.05,true,false,true).timeout
	Engine.time_scale=1
