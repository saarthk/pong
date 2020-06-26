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

    -- seed the RNG with current time (in seconds)
    math.randomseed(os.time())

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

    -- velocity and position variables
    ballX = VIRTUAL_WIDTH / 2 - 2
    ballY = VIRTUAL_HEIGHT / 2 - 2

    -- initialize the ball with random velocity components
    ballDX = math.random(2) == 1 and 100 or -100
    ballDY = math.random(-50, 50)

    -- game state variable used to transition between different parts of the game
    -- (used for beginning, menus, main game, high score list, etc.)
    -- we will use this to determine behavior during render and update
    gameState = 'start'
end

function love.update(dt)
    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('s') then
        player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('down') then
        player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
    end

    -- update ball position as per the velocity components
    -- only if in the play state
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'

            ballX = VIRTUAL_WIDTH / 2 - 2
            ballY = VIRTUAL_HEIGHT / 2 - 2

            ballDX = math.random(1) == 2 and 100 or -100
            ballDY = math.random(-50, 50) * 1.5
        end
    end
end

function love.draw()
    TLfres.beginRendering(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    -- LÖVE 11.0 uses decimal values between 0-1
    -- as opposed to LÖVE 10.2 which uses 0-255
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    love.graphics.setColor(1, 1, 1)

    if gameState == 'start' then
        love.graphics.printf('Hello Start State!', smallFont, 0, 10, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Hello Play State', smallFont, 0, 10, VIRTUAL_WIDTH, 'center')
    end

    -- draw scores on the screen
    love.graphics.setFont(scoreFont)
    love.graphics.print(
        tostring(player1Score),
        VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 10)
    love.graphics.print(
        tostring(player2Score),
        VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 10)

    -- x & y coordinates of the rectangle correspond to 
    -- the TOP-LEFT point rather than the center
    -- left paddle
    love.graphics.rectangle('fill', 10, player1Y, 5, 20)
    -- right paddle
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)
    -- ball
    love.graphics.rectangle('fill', ballX, ballY, 4, 4)

    TLfres.endRendering()
end