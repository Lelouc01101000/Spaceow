-- AnimatedExplosion.lua
local AnimatedExplosion = {}
AnimatedExplosion.__index = AnimatedExplosion

function AnimatedExplosion:new(x, y, frames)
    local self = setmetatable({}, AnimatedExplosion)
    self.frames = frames
    self.x = x
    self.y = y
    self.frameIndex = 1
    self.animationSpeed = 20 
    self.dead = false
    return self
end

function AnimatedExplosion:update(dt) 
    self.frameIndex = self.frameIndex + self.animationSpeed * dt
    if self.frameIndex > #self.frames then
        self.dead = true
    end
end

function AnimatedExplosion:draw()
    local currentFrame = self.frames[math.floor(self.frameIndex)] 
    if currentFrame then
        local w = currentFrame:getWidth()
        local h = currentFrame:getHeight()
        love.graphics.draw(currentFrame, self.x, self.y, 0, 0.25, 0.25, w / 2, h / 2)
    end
end

return AnimatedExplosion