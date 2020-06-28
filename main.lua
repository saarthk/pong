push = require 'push'

require 'Paddle'
require 'Ball'

-- Windows resizes the display to 150% of the original
-- so the maximum possible resolution without overflow
-- can be 1280x720, instead of 1920x1080
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- movement speed of paddle
-- multiplied by dt during update
-- to match frame rates across systems
PADDLE_SPEED = 400

function love.load()
    -- set game title to "Pong!"
    love.window.setTitle("Pong!")
    -- seed the RNG with current time (in seconds)
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- sound files
    sounds = {
        ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['win'] = love.audio.newSource('sounds/win.wav', 'static'),
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true,
    })
    -- default font
    smallFont = love.graphics.newFont('font.ttf', 8)
    -- font for displaying winning message
    largeFont = love.graphics.newFont('font.ttf', 16)
    -- font for displaying score of players
    scoreFont = love.graphics.newFont('font.ttf', 32)

    -- initializing player scores
    player1Score = 0
    player2Score = 0

    -- represents the player serving the ball
    servingPlayer =1

    -- instantiate players
    player1 = Paddle:init(5, 30, 5, 50)
    player2 = Paddle:init(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 50)
    -- instantiate ball
    ball = Ball:init(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- game state variable used to transition between different parts of the game
    -- (used for beginning, menus, main game, high score list, etc.)
    -- we will use this to determine behavior during render and update
    gameState = 'start'
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end

    elseif gameState == 'play' then
        -- if ball collides with paddle 1
        if ball:collide(player1) then
            -- ball is placed at the periphery of the paddle
            ball.x = player1.x + 5
            -- x component of the velocity is reversed
            -- and the ball is accelerated in x
            ball.dx = -ball.dx * 1.05

            -- direction of the y component of velocity is maintained
            -- but the magnitude is changed at random
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['hit']:play()
        end

        -- same as player 1's collision detection
        if ball:collide(player2) then
            ball.x = player2.x - 4
            ball.dx = -ball.dx * 1.05
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['hit']:play()
        end


        -- collision detection along the ceiling and floor
        -- using simple math :P
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['hit']:play()

        elseif ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['hit']:play()
        end    

        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1

            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'end'
                sounds['win']:play()
            else
                sounds['score']:play()
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'end'
                sounds['win']:play()
            else
                sounds['score']:play()
                gameState = 'serve'
                ball:reset()
            end
        end
    end


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
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'end' then
            -- on pressing enter after finishing the game
            -- game restarts in the serving position
            gameState = 'serve'
            -- and all objects are reset
            ball:reset()

            player1Score = 0
            player2Score = 0

            -- decide who serves first
            -- depending upon the result of the previous game
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    push:apply('start')
    -- LÖVE 11.0 uses decimal values between 0-1
    -- as opposed to LÖVE 10.2 which uses 0-255
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    displayScore()

    if gameState == 'start' then
        love.graphics.printf(
            'Welcome to Pong!', 
            smallFont, 
            0, 0, VIRTUAL_WIDTH, 'center')
        love.graphics.printf(
            'Press ENTER to start',
            smallFont,
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.line(VIRTUAL_WIDTH / 2, 30, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT)

    elseif gameState == 'serve' then
        love.graphics.printf(
            'SERVE', 
            smallFont, 
            10, 20, VIRTUAL_WIDTH - 10, 'left')
        love.graphics.printf(
            'Player ' .. tostring(servingPlayer) .. "'s serve!",
            smallFont,
            0, 0, VIRTUAL_WIDTH, 'center'
            )
        love.graphics.printf(
            'Press ENTER to serve',
            smallFont,
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.line(VIRTUAL_WIDTH / 2, 30, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT)

    elseif gameState == 'play' then
        love.graphics.printf(
            'PLAY', 
            smallFont, 
            10, 20, VIRTUAL_WIDTH - 10, 'left')
        love.graphics.line(VIRTUAL_WIDTH / 2, 0, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT)

    elseif gameState == 'end' then
        love.graphics.printf(
            'END', 
            smallFont, 
            10, 20, VIRTUAL_WIDTH - 10, 'left')
        love.graphics.printf(
            'Player ' .. tostring(winningPlayer) .. ' wins!',
            largeFont,
            0, 0, VIRTUAL_WIDTH, 'center')
        love.graphics.printf(
            'Press ENTER to restart',
            smallFont,
            0, 16
            , VIRTUAL_WIDTH, 'center')
        love.graphics.line(VIRTUAL_WIDTH / 2, 30, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT)
    end

    -- love.graphics.circle('fill', VIRTUAL_WIDTH / 2 + 6, VIRTUAL_HEIGHT / 2 + 6, 3)

    player1:render()
    player2:render()
    ball:render()
    
    -- set font properties
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    -- print current FPS
    love.graphics.print(
        "FPS: " .. tostring(love.timer.getFPS()),
        10, 10
        )

    push:apply('end')
end

function displayScore()
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
end