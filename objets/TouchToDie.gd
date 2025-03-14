extends Area2D

class_name TouchToDie  # 定义类名

# 伤害值（设为极大值确保一击必杀）
const SPIKE_DAMAGE := 999

func _ready():
	# 连接信号，当有物体进入区域时触发
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# 当进入的物体是玩家时
	if body is Player:
		# 直接设置玩家生命为0
		body.stats.health = 0
		#音效
		SoundManager.play_sfx("hurt")
		# 清空待处理伤害防止进入HURT状态
		body.pending_damage = null
