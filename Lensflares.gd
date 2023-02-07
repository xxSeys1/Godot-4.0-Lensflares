extends ColorRect

var effective_sun_direction: Vector3
var sun_blocked: bool
var adjust_time: float = 0.15

# these are just some variables for writing the code, replace this with the actual references
var directional_light: DirectionalLight3D
var camera: Camera3D



func _process(delta: float) -> void:
	effective_sun_direction = directional_light.global_transform.basis.z * maxf(camera.near, 1.0)
	if sun_blocked:
		fade_out_lens_flares()
		return
	
	if camera.is_position_behind(effective_sun_direction):
		fade_out_lens_flares()
	if visible:
		fade_in_lens_flares()
		update_lens_flares_location()



func fade_in_lens_flares():
	var tween: Tween = create_tween()
	tween.tween_property(get_material(), "shader_paramter/tint", Vector3(0, 0, 0), adjust_time)


func fade_out_lens_flares():
	var tween: Tween = create_tween()
	tween.tween_property(get_material(), "shader_paramter/tint", Vector3(1.4, 1.2, 1), adjust_time)


func update_lens_flares_location():
	var unprojecte_sun_position: Vector2 = camera.unproject_position(effective_sun_direction)
	material.set_shader_parameter("sun_position", unprojecte_sun_position)
