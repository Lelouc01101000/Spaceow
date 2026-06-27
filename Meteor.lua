-- Meteor.lua
local Meteor = {}
Meteor.__index = Meteor

function Meteor:new(x, y, img, imgData) 
    local self = setmetatable({}, Meteor)
    self.image = img
    self.imageData = imgData
    self.x = x
    self.y = y
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    
    -- speed based on difficulty (activeGameDifficulty is global)
    local minSpeed, maxSpeed = 300, 500  -- for normal difficulty
    if activeGameDifficulty == "easy" then minSpeed, maxSpeed = 200, 350
    elseif activeGameDifficulty == "hard" then minSpeed, maxSpeed = 450, 650 end
    
    self.speed = love.math.random(minSpeed, maxSpeed)
    
    -- Direction
    local dirX = love.math.random() - 0.5 
    self.direction = { x = dirX, y = 1 }
    
    self.rotation = 0 
    self.rotationSpeed = love.math.random(20, 50)
    self.dead = false
    return self
end

function Meteor:update(dt)
    self.x = self.x + self.direction.x * self.speed * dt
    self.y = self.y + self.direction.y * self.speed * dt
    
    if self.y > WINDOW_HEIGHT + self.height then
        self.dead = true
    end

    self.rotation = self.rotation + self.rotationSpeed * dt
end

function Meteor:draw() 
    love.graphics.draw(self.image, self.x, self.y, math.rad(self.rotation), 1, 1, self.width / 2, self.height / 2)
end

return Meteor