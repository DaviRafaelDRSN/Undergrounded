extends KinematicBody

const GRAVITY = -24.8
var vel = Vector3()
var MAX_SPEED = 5.0
const JUMP_SPEED = 12
const ACCEL = 4.5
onready var footsteps = $Footsteps

var dir = Vector3()

var is_crouching = false

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var walking = false

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.1

func _ready():
	camera = $CameraPivot/Camera
	rotation_helper = $CameraPivot

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("ui_up"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("ui_down"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	if input_movement_vector.x != 0 or input_movement_vector.y != 0:
		walking = true
	else:
		walking = false
		
	if walking and !footsteps.playing:
		footsteps.play()
	if not walking and footsteps.playing:
		footsteps.stop()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------
	# Running
	if Input.is_action_pressed("movement_run"):
		MAX_SPEED = 10.0
		footsteps.pitch_scale = 2
		footsteps.unit_db = 10.000
	if Input.is_action_just_released("movement_run"):
		MAX_SPEED = 5.0
		footsteps.pitch_scale = 1
		footsteps.unit_db = 5.000
	# ----------------------------------
	# Crouching
	if Input.is_action_pressed("movement_crouch"):
		is_crouching = true
		MAX_SPEED = 2.0
		footsteps.pitch_scale = 0.75
		footsteps.unit_db = -10.000
	elif Input.is_action_just_released("movement_crouch"):
		is_crouching = false
		MAX_SPEED = 5.0
		footsteps.pitch_scale = 1
		footsteps.unit_db = 5.000
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	if is_crouching:
		vel.y = 0 # Impede o pulo enquanto agachado
		# Define a altura do objeto ao agachar (ajuste conforme necessário)
		var target_height = 0.5 # Altura desejada quando agachado
		self.scale.y = lerp(self.scale.y, target_height, 0.1) # Ajuste a velocidade do agachamento aqui
	else:
		# Se não estiver agachando, use a altura padrão
		vel.y += delta * GRAVITY
		var standing_height = 1.0 # Altura padrão quando não agachado
		self.scale.y = lerp(self.scale.y, standing_height, 0.1)

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
