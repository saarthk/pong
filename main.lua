TLfres = require 'tlfres'

require 'Paddle'
require 'Ball'

-- windows resizes the display to 150% of the original
-- so the maximum possible resolution without overflow
-- can be 1280x720, instead of 1920x1080
WINDOW_WIDTH = 864
WINDOW_HEIGHT = 486

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- movement speed of paddle
-- multiplied by dt during update
-- to match frame rates across systems
PADDLE_SPEED = 200
BALL_SPEED_X = 100
BALL_SPEED_Y = 50

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    -- set game title to "Pong!"
    love.window.setTitle("Pong!")
    -- seed the RNG with current time (in seconds)
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('font.ttf', 8)

    -- font for displaying score of players
    scoreFont = love.graphics.newFont('font.ttf', 32)

    -- initializing player scores
    player1Score = 0
    player2Score = 0

    player1 = Paddle:init(5, 30, 5, 20)
    player2 = Paddle:init(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball:init(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- game state variable used to transition between different parts of the game
    -- (used for beginning, menus, main game, high score list, etc.)
    -- we will use this to determine behavior during render and update
    gameState = 'start'
end

function love.update(dt)
    -- player 1 movement
    -- we impart a certain speed to the ball during the update
    -- which determines its new position, under the hood

    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'

            ball:reset()
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
        love.graphics.printf('Hello Play State!', smallFont, 0, 10, VIRTUAL_WIDTH, 'center')
    end

    -- love.graphics.line(VIRTUAL_WIDTH / 2, 0, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT)
    -- love.graphics.circle('fill', VIRTUAL_WIDTH / 2 + 6, VIRTUAL_HEIGHT / 2 + 6, 3)

    player1:render()
    player2:render()

    ball:render()
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

    -- set font properties
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    -- print current FPS
    love.graphics.print(
        "FPS: " .. tostring(love.timer.getFPS()),
        10, 10
        )

    TLfres.endRendering()
end