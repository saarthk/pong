-- Represents class Paddle
Paddle = {
    dy = 0,

    update = function (self, dt)
        if self.dy < 0 then
            self.y = math.max(0, self.y + self.dy * dt)
        else
            self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
        end
    end,

    render = function (self)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end
}

function Paddle:init(x, y, w, h)
    o = {x = x, y = y, width = w, height = h}
    self.__index = self
    setmetatable(o, self)
    return o
end
