extends CanvasLayer

onready var mat: Material = ($PixelizationShader as TextureRect).get_material()
var pixel_size: float = 1.0

var increment_ammount: float = 0.5
var upper_limit: float = 999999.0
var lower_limit: float = 1.0


func _ready():
	mat.set_shader_param("pixel_size", pixel_size)
	
func _input(event):
	
	if event.is_action_pressed("shader_effect_up"):
		effect_up()
		
	if event.is_action_pressed("shader_effect_down"):
		effect_down()

func effect_up(ammount = increment_ammount):
	pixel_size = clamp(pixel_size + ammount, lower_limit, upper_limit)
	apply_effect()
	
func effect_down(ammount = increment_ammount):
	pixel_size = clamp(pixel_size - ammount, lower_limit, upper_limit)
	apply_effect()

func apply_effect():
	mat.set_shader_param("pixel_size", pixel_size)