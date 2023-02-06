extends CharacterBody3D

@onready var sun_check_cast_origin: Marker3D # = reference to the Marker3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var directional_light: DirectionalLight3D
var camera: Camera3D

# replace this with the reference to to sun_blocked variable in the PostProcessingStack
var sun_blocked

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")



func _process(delta: float) -> void:
	check_for_sun_visible()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()


func object_is_intersecting_sun():
	var space_state = get_world_3d().direct_space_state
	var effective_sun_position = directional_light.global_transform.basis.z * camera.far
	effective_sun_position += camera.global_position
	
	var ray_origin = sun_check_cast_origin.global_position
	var ray_end = effective_sun_position
	
	var parameters: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	
	var ray_array = space_state.intersect_ray(parameters)
	
	if ray_array.has("collider"):
		return true
	
	return false
	


func check_for_sun_visible():
	sun_blocked = object_is_intersecting_sun()
