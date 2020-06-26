TLfres = require 'tlfres'

-- windows resizes the display to 150% of the original
-- so the maximum possible resolution without overflow
-- can be 1280x720, instead of 1920x1080
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- movement speed of paddle
-- multiplied by dt during update
-- to match frame rates across systems
PADDLE_SPEED = 200

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('font.ttf', 8)

    -- font for displaying score of players
    scoreFont = love.graphics.newFont('font.ttf', 32)

    -- initializing player scores
    player1Score = 0
    player2Score = 0

    -- initial paddle positions (along Y-axis)
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50
end

function love.update(dt)
    if love.keyboard.isDown('w') then
        player1Y = player1Y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('s') then
        player1Y = player1Y + PADDLE_SPEED * dt
    end

    if love.keyboard.isDown('up') then
        player2Y = player2Y -PADDLE_SPEED * dt
    elseif love.keyboard.isDown('down') then
        player2Y = player2Y + PADDLE_SPEED * dt
    end
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

    love.graphics.printf('Hello Pong!', smallFont, 0, 5, VIRTUAL_WIDTH, 'center')

    -- draw scores on the screen
    love.graphics.setFont(scoreFont)
    love.graphics.print(
        tostring(player1Score),
        VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 15)
    love.graphics.print(
        tostring(player2Score),
        VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 15)

    -- x & y coordinates of the rectangle correspond to 
    -- the TOP-LEFT point rather than the center
    -- left paddle
    love.graphics.rectangle('fill', 10, player1Y, 5, 20)
    -- right paddle
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)
    -- ball
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    TLfres.endRendering()
end