TLfres = require 'tlfres'

-- windows resizes the display to 150% of the original
-- so the maximum possible resolution without overflow
-- can be 1280x720, instead of 1920x1080
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('font.ttf', 8)

    love.graphics.setFont(smallFont)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.draw()
    TLfres.beginRendering(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    -- LÖVE 11.0 uses decimal values between 0-1
    -- as opposed to LÖVE 10.2 which uses 0-255
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    -- x & y coordinates of the rectangle correspond to 
    -- the TOP-LEFT point rather than the center

    -- left paddle
    love.graphics.rectangle('fill', 10, 30, 5, 20)
    -- right paddle
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)
    -- ball
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    TLfres.endRendering()
end