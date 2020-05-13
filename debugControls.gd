extends Control

onready var debugInter = $debugInterface
onready var braidShader = $Effects/BraidRing;


func _on_hideGuiButton_toggled(button_pressed):
		if button_pressed:
			$".".remove_child(debugInter)
		else:	
			$".".add_child(debugInter)


func _on_circleSizeSlider_value_changed(val):
	braidShader.material.set_shader_param("circleSize", val)

func _on_frequencySlider_value_changed(val):
	braidShader.material.set_shader_param("frequency", val)

func _on_zoomPower_value_changed(val):
	braidShader.material.set_shader_param("zoomPower", val)

func _on_depthtMult_value_changed(val):
	braidShader.material.set_shader_param("depth", val)

#TODO: if you want, add pulsePercent and borderLimit sliders


#images and shader selection. already present in the example

func _ready():	
	for c in $Pictures.get_children():
		$debugInterface/Picture.add_item("PIC: " + c.get_name())
	for c in $Effects.get_children():
		$debugInterface/Effect.add_item("FX: " + c.get_name())
	$Pictures.get_child(1).show()


	$debugInterface/circleSizeSlider.value = braidShader.material.get_shader_param("circleSize");
	$debugInterface/frequencySlider.value = braidShader.material.get_shader_param("frequency");
	$debugInterface/zoomPower.value = braidShader.material.get_shader_param("zoomPower");
	$debugInterface/depthtMult.value = braidShader.material.get_shader_param("depth");


func _on_picture_item_selected(ID):
	for c in range($Pictures.get_child_count()):
		if ID == c:
			$Pictures.get_child(c).show()
		else:
			$Pictures.get_child(c).hide()


func _on_effect_item_selected(ID):
	for c in range($Effects.get_child_count()):
		if ID == c:
			$Effects.get_child(c).show()
		else:
			$Effects.get_child(c).hide()
