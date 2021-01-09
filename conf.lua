io.stdout:setvbuf("no")

function love.conf(t)
    t.window.width = 1280
    t.window.height = 720
    t.window.fullscreen = false
    t.window.resizable = true
    t.window.display = 1
    t.window.vsync = 1
    t.window.title = "Anarchy"
end