extends HBoxContainer#血条ui

@export var stats:Stats
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var eased_health_bar: TextureProgressBar = $HealthBar/EasedHealthBar


func _ready() -> void:
	if not stats:
		stats=Game.player_stats
		
	stats.health_changed.connect(update_health)
	update_health(true)
	
	#4.2以后，防止bug
	tree_exited.connect(func ():
		stats.health_changed.disconnect(update_health)
	)


func update_health(sikp_anim:=false)->void:
	var percentage:=stats.health/float(stats.max_health)
	health_bar.value=percentage
	
	#取消每次传送不是满血时的掉血动画
	if sikp_anim:
		eased_health_bar.value=percentage
	else:
		#血条消失动画
		create_tween().tween_property(eased_health_bar,"value",percentage,0.3)
