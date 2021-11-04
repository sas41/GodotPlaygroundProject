extends KinematicBody

## Movement Related Variables
var velocity                      : Vector3 = Vector3()
var default_up_vector             : Vector3 = Vector3(0,1,0)

var spectating_speed              : float   = 10.00
var spectating_accelaration       : float   = 5

## Camera Related Variables
var mouse_movement_event          : InputEventMouseMotion

var mouse_sensitivity             : float   = 0.5

var mouse_invert_horizontal       : int     = -1
var mouse_invert_vertical         : int     = -1

var camera_vertical_angle         : float   = 0
var camera_horizontal_angle       : float   = 0
var camera_vertical_limit         : float   = 90

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event) -> void:
	if event is InputEventMouseMotion:
		mouse_movement_event = event

func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	move(delta)
	
	if(mouse_movement_event != null && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		move_camera(mouse_movement_event as InputEventMouseMotion)
		mouse_movement_event = null

func move(delta):
	var direction : Vector3 = Vector3()
	var aim : Basis = self.get_global_transform().basis
	
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
	if Input.is_action_pressed("move_up"):
		direction.y += 1
	if Input.is_action_pressed("move_down"):
		direction.y -= 1
		
	direction = direction.normalized()
	
	velocity = velocity.linear_interpolate(direction * spectating_speed, spectating_accelaration * delta)

	self.velocity = self.move_and_slide(velocity,  default_up_vector)

func move_camera(event):
	var horizontal_change : float = event.relative.x * mouse_sensitivity * mouse_invert_horizontal
	rotate_y(deg2rad(horizontal_change))

	var vertical_change : float = event.relative.y * mouse_sensitivity * mouse_invert_vertical
	
	if ((vertical_change + camera_vertical_angle < camera_vertical_limit) and (vertical_change + camera_vertical_angle > -camera_vertical_limit)):
		($Camera as Camera).rotate_x(deg2rad(vertical_change))
		camera_vertical_angle += vertical_change
