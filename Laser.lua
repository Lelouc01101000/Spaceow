-- Laser.lua
local Laser = {}
Laser.__index = Laser

function Laser:new(x, y, img, imgData) 
    local self = setmetatable({}, Laser)
    self.image = img
    self.imageData = imgData 
    self.x = x
    self.y = y 
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.speed = 400
    self.dead = false 
    
    return self
end

function Laser:update(dt)
    self.y = self.y - self.speed * dt
    if self.y < 0 - self.height then
        self.dead = true
    end
end

function Laser:draw() 
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
end

return Laser