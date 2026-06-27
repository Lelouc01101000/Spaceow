-- PhoenixMeteor.lua
local PhoenixMeteor = {}
PhoenixMeteor.__index = PhoenixMeteor

function PhoenixMeteor:new(x, y, img1, imgData1, img2, imgData2) 
    local self = setmetatable({}, PhoenixMeteor)
    
    -- Store resources for swapping
    self.img1 = img1
    self.data1 = imgData1
    self.img2 = img2
    self.data2 = imgData2

    self.image = self.img1
    self.imageData = self.data1
    self.x = x
    self.y = y
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.lives = 2 
    
    -- speed based on difficulty (activeGameDifficulty is global)
    local minSpeed, maxSpeed = 300, 500  -- for normal difficulty
    if activeGameDifficulty == "easy" then minSpeed, maxSpeed = 200, 350
    elseif activeGameDifficulty == "hard" then minSpeed, maxSpeed = 450, 650 end
    
    self.speed = love.math.random(minSpeed, maxSpeed) * 0.5 
    
    local dirX = love.math.random() - 0.5 
    self.direction = { x = dirX, y = 1 }
    
    self.rotation = 0 
    self.rotationSpeed = love.math.random(20, 50)
    self.dead = false
    return self
end

function PhoenixMeteor:hit()
    self.lives = self.lives - 1
    if self.lives == 1 then
        self.image = self.img2
        self.imageData = self.data2
        self.width = self.image:getWidth()
        self.height = self.image:getHeight()
    elseif self.lives <= 0 then
        self.dead = true
    end
end

function PhoenixMeteor:update(dt)
    self.x = self.x + self.direction.x * self.speed * dt
    self.y = self.y + self.direction.y * self.speed * dt
    
    if self.y > WINDOW_HEIGHT + self.height then
        self.dead = true
    end

    self.rotation = self.rotation + self.rotationSpeed * dt
end

function PhoenixMeteor:draw() 
    love.graphics.draw(self.image, self.x, self.y, math.rad(self.rotation), 1, 1, self.width / 2, self.height / 2)
end

return PhoenixMeteor