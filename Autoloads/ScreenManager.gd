extends Node

signal loading_screen_has_exited()

@onready var animator = $LoadingScreenAnimation

@onready var load_timer = $Timer
const LOAD_TIMER_INTERVAL = 0.1

var next_screen_path : String
var animation : String

func _ready() -> void:
	load_timer.wait_time = LOAD_TIMER_INTERVAL
	load_timer.stop()

func load_screen(screen_path:String) -> void:
	ResourceLoader.load_threaded_request(screen_path)

func go_to_screen(screen_path:String, animation_:="default") -> void:
	animator.play(animation_+"_start")
	animation = animation_
	next_screen_path = screen_path
	if not ResourceLoader.has_cached(screen_path):
		load_screen(screen_path)
	load_timer.start()

func _check_load_progress() -> void:
	var load_progress = []
	var load_status = ResourceLoader.load_threaded_get_status(next_screen_path, load_progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			load_timer.stop()
			printerr("Invalid Resource")
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			print("Loading progress: ", load_progress[0] * 100)
		ResourceLoader.THREAD_LOAD_FAILED:
			load_timer.stop()
			printerr("Loading Failed")
		ResourceLoader.THREAD_LOAD_LOADED:
			load_timer.stop()
			_finished_loading()
			
func _finished_loading() -> void:
	var new_screen = ResourceLoader.load_threaded_get(next_screen_path).instantiate()
	var old_screen = get_tree().current_scene
	var data = old_screen.get_screen_data()
	
	new_screen.set_screen_data(data)
	get_tree().root.call_deferred("add_child",new_screen)
	get_tree().set_deferred("current_scene", new_screen)
	old_screen.queue_free()
	
	if animator.is_playing():
		await animator.animation_finished
	animator.play(animation+"_end")
	await animator.animation_finished
	loading_screen_has_exited.emit()
