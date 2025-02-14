extends RayCast2D

@onready var must_die: RayCast2D = $"."
@onready var must_die_2: RayCast2D = $"../MustDie2"
@onready var must_die_3: RayCast2D = $"../MustDie3"


func TouchToDie()-> void:
	if must_die or must_die_2 or must_die_3.is_colliding():
		pending_damage.amount=10#扣血量
	return player_checker.get_collider() is Player
