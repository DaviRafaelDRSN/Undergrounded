extends SpotLight

var on = true
var audioserver: AudioStreamPlayer

func _ready():
	# Obter o nó AudioStreamPlayer chamado "Click"
	audioserver = $Click
	# Desativar o loop do áudio

func _process(delta):
	if Input.is_action_just_pressed("flashlight"):
		# Reproduzir o som
		audioserver.play()
		# Alternar o estado da lanterna
		on = not on
		
		if on:
			# Ligar a lanterna
			show()
		else:
			# Desligar a lanterna
			hide()
