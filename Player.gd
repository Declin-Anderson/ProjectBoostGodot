extends RigidBody3D

## How much vertical force to apply when moving
@export_range(750.0, 3000.0) var thrust: float = 1000.0
## How much horizontal force to apply when moving
@export var torque_thrust: float = 100.0

# Boolean that checks for when scenes are transitioning
var is_transitioning: bool = false

# References to nodes
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# When w or spacebar is pressed, there is a vertical force applied to the rocket ship
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if rocket_audio.playing == false:
			rocket_audio.play()
	else:
		rocket_audio.stop()
		booster_particles.emitting = false
		
	# When a or left arrow is pressed, there is a horizontal force applied to the rocket ship to make it lean left
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))
		right_booster_particles.emitting = true
	else:
		right_booster_particles.emitting = false
	
	# When d or right arrow is pressed, there is a horizontal force applied to the rocket ship to make it lean right
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * delta))
		left_booster_particles.emitting = true
	else:
		left_booster_particles.emitting = false
	
	# escape is pressed closes the game
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
# A function that is called when the rocketship collides with the scenary
func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		
		if "Hazard" in body.get_groups():
			crash_squence()
		
# A function for when the ship collides with anything other than the launch or landing pad
func crash_squence() -> void:
	print("Kaboom!")
	explosion_audio.play()
	explosion_particles.emitting = true
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
	
# A function for when the ship collides with the landing pad and proceeds to the next level
func complete_level(next_level_file) -> void:
	print("Level Complete")
	success_audio.play()
	success_particles.emitting = true
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(
		get_tree().change_scene_to_file.bind(next_level_file)
	)
