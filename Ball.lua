-- Represents Ball class
Ball = {
    reset = function (self)
        -- position vector of the ball
        self.x = VIRTUAL_WIDTH / 2 - 2
        self.y = VIRTUAL_HEIGHT / 2 - 2

        -- velocity vector of the ball
        self.dx = math.random(2) == 1 and -BALL_SPEED_X or BALL_SPEED_X
        self.dy = math.random(-BALL_SPEED_Y, BALL_SPEED_Y)
    end,

    update = function (self, dt)
        -- updates the ball's position
        -- scaled by time elapsed between consecutive frames
        -- to make the movement framerate independent
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
    end,

    render = function (self)
        -- renders the ball on the screen
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end
}

function Ball:init(x, y, w, h)
    -- initialize a new instance of the ball
    o = {
        -- random values are assigned to the velocity vector at the time of initialization
        dx = math.random(1) == 2 and -BALL_SPEED_X or BALL_SPEED_X,
        dy = math.random(-BALL_SPEED_Y, BALL_SPEED_Y),

        x = x,
        y = y,
        width = w,
        height = h,
    }
    -- sets the metatable of newly instantiated ball object
    -- to the ball prototype(class)
    self.__index = self
    setmetatable(o, self)
    
    return o
end