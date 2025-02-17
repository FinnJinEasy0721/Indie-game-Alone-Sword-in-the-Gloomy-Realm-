extends Enemy#NightBorne 晦境魔镰使

enum State{
	IDLE,
	RUN,
	HURT,
	DYING,
	ATTACK
}

const KNOCKBACK_AMOUNT:=512.0#击退力度
var	pending_damage:Damage#待处理的伤害
@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var floor_checker: RayCast2D = $Graphics/FloorChecker
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var attack_checker: RayCast2D = $Graphics/AttackChecker
@onready var back_player_checker: RayCast2D = $Graphics/BackPlayerChecker

@onready var calm_down_timer: Timer = $CalmDownTimer
@onready var attack_timer: Timer = $AttackTimer


#@onready var bug_timer: Timer = $BugTimer#没用，留着找bug


func can_see_player()-> bool:
	if not player_checker.is_colliding():
		return false
	return player_checker.get_collider() is Player

func tick_physics(state:State,delta:float)->void:
	match  state:
		State.IDLE,State.HURT,State.DYING,State.ATTACK:
			move(0.0,delta)
		#State.WALK:
			#move(max_speed/3,delta)
		State.RUN:
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				direction*=-1
			move(max_speed/2,delta)
			if can_see_player():
				calm_down_timer.start()


func get_next_state(state:State)->int:
	if stats.health==0:
		return StateMachine.KEEP_CURRENT if state==State.DYING else State.DYING
	
	#如果有待处理伤害	
	if pending_damage:
		return State.HURT
	
	match state:
		State.IDLE:
			if can_see_player():
				return State.RUN
			#bug_timer.start()
			#if bug_timer.time_left<=2:
				#return State.WALK
			if state_machine.state_time > 2:#bug!!
				return State.IDLE
				
			#bug_timer.stop()#留着找bug
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				return State.IDLE
				
		State.RUN:
			attack_timer.stop()
			if attack_checker.is_colliding():
				return State.ATTACK
			
			if not can_see_player() and calm_down_timer.is_stopped():
				return State.IDLE
				
		State.HURT:
			if not animation_player.is_playing():
				return State.RUN
				
		State.ATTACK:
			if not attack_checker.is_colliding() and attack_timer.time_left<=0:
				return State.RUN
				attack_timer.stop()
				
			
	return StateMachine.KEEP_CURRENT		
	
	
func transition_state(from:State,to:State)->void:
	#print("[%s] %s => %"[
		#Engine.get_physics_frames(),
		#State.keys()[from] is from !=-1 else "<START>",
		#State.keys()[to],
	#])
	match to:
		State.IDLE:
			animation_player.play("idle")
			if wall_checker.is_colliding():
				direction*=-1#转身
			if back_player_checker.is_colliding():
				direction*=-1#转身
			
		#State.WALK:
			#animation_player.play("walk")
			#if not floor_checker.is_colliding():
				#direction*=-1#转身
			
		State.RUN:
			animation_player.play("run")
			if not floor_checker.is_colliding():
				direction*=-1#转身
			if back_player_checker.is_colliding():
				direction*=-1#转身
			
		State.HURT:
			animation_player.play("hurt")
			stats.health-=pending_damage.amount
			var dir:=pending_damage.source.global_position.direction_to(global_position)#击退方向
			velocity=dir*KNOCKBACK_AMOUNT
			
			#背后攻击立即转身
			if dir.x>0:
				direction=Direction.LEFT
			else:
				direction=Direction.RIGHT
				
			pending_damage=null
			
		State.DYING:
			animation_player.play("die")
			
		State.ATTACK:
			animation_player.play("attack")
			attack_timer.start()


#伤害数值判定
func _on_hurtbox_hurt(hitbox: Variant) -> void:
	pending_damage=Damage.new()
	pending_damage.amount=1#扣血量
	pending_damage.source=hitbox.owner#伤害来源
