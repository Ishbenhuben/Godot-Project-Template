extends Node

func adjust_bus_volume(bus:String, volume:float) -> void:
	volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume))
