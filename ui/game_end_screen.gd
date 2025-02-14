extends Control

const LINES:=[
	"大丈夫生于乱世",
	"当带三尺剑",
	"立不世之功",
]

var current_line:=-1
var tween:Tween

@onready var label: Label = $Label

func _ready() -> void:
	show_line(0)
	SoundManager.play_bgm(preload("res://素材/SFX and BGM/06 - Victory!.mp3"))
	

func _input(event: InputEvent) -> void:
	if tween.is_running():
		return
	
	if (
		event is InputEventKey or
		event is InputEventMouseButton
	):
		if event.is_pressed() and not event.is_echo():#echo回显事件ddddddddddddd
			if current_line+1<LINES.size():
				show_line(current_line+1)
			else:
				Game.back_to_title()


func show_line(line:int)->void:
	current_line=line
	
	tween=create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	if line>0:
		tween.tween_property(label,"modulate:a",0,1)
	else:
		label.modulate.a=0
		
	tween.tween_callback(label.set_text.bind(LINES[line]))
	tween.tween_property(label,"modulate:a",1,1)
