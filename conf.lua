function love.conf(t)
	t.identity = "bulet heck"
	t.version = "11.0"

	t.audio.mixwithsystem = false

	t.window.title = "bulet heck!!"
	t.window.icon = "assets/sprites/o.png"
	t.window.width = 800
	t.window.height = 400

	t.modules.joystick = false
	t.modules.physics = false
end