-- TrackerMeteor.lua
local TrackerMeteor = {}
TrackerMeteor.__index = TrackerMeteor

function TrackerMeteor:new(x, y, targetX, targetY, img, imgData) 
    local self = setmetatable({}, TrackerMeteor)
    self.image = img
    self.imageData = imgData
    self.x = x
    self.y = y
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    
    -- speed based on Player Base Speed (300)
    if activeGameDifficulty == "easy" then
        self.speed = 450 -- 150% of player speed
    elseif activeGameDifficulty == "hard" then
        self.speed = 900 -- 300% of player speed
    else -- normal
        self.speed = 600 -- 200% of player speed
    end
    
    local angle = math.atan2(targetY - y, targetX - x) -- it will cross the point at which the player was located when tracker spawned
    
    self.direction = {
        x = math.cos(angle),
        y = math.sin(angle)
    }
    
    self.rotation = 0 
    self.rotationSpeed = love.math.random(40, 70) 
    self.dead = false
    return self
end

function TrackerMeteor:update(dt)
    self.x = self.x + self.direction.x * self.speed * dt
    self.y = self.y + self.direction.y * self.speed * dt
    
    if self.y > WINDOW_HEIGHT + self.height then
        self.dead = true
    end

    self.rotation = self.rotation + self.rotationSpeed * dt
end

function TrackerMeteor:draw() 
    love.graphics.draw(self.image, self.x, self.y, math.rad(self.rotation), 1, 1, self.width / 2, self.height / 2)
end

return TrackerMeteor