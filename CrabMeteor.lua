-- CrabMeteor.lua
local CrabMeteor = {}
CrabMeteor.__index = CrabMeteor

function CrabMeteor:new(x, y, img, imgData, playerObj)
    local self = setmetatable({}, CrabMeteor)
    self.image = img
    self.imageData = imgData
    self.x = x
    self.y = y
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.player = playerObj

    -- vertical speed based on difficulty (activeGameDifficulty is global)
    local minSpeed, maxSpeed = 300, 500  -- for normal difficulty
    if activeGameDifficulty == "easy" then minSpeed, maxSpeed = 200, 350
    elseif activeGameDifficulty == "hard" then minSpeed, maxSpeed = 450, 650 end
    self.verticalSpeed = love.math.random(minSpeed, maxSpeed)

    -- Horizontal speed (Based on Player BASE speed of 300)
    -- Easy: 25%, Normal: 35%, Hard: 50%
    local hSpeedMultiplier = 0.35 -- default normal
    if activeGameDifficulty == "easy" then hSpeedMultiplier = 0.25 end
    if activeGameDifficulty == "hard" then hSpeedMultiplier = 0.50 end
    
    self.horizontalSpeed = 300 * hSpeedMultiplier

    self.dead = false
    return self
end

function CrabMeteor:update(dt)
    -- Vertical Movement
    self.y = self.y + self.verticalSpeed * dt

    -- Horizontal Movement: Chases player X
    if self.x < self.player.x then
        self.x = self.x + self.horizontalSpeed * dt
    elseif self.x > self.player.x then
        self.x = self.x - self.horizontalSpeed * dt
    end

    if self.y > WINDOW_HEIGHT + self.height then
        self.dead = true
    end
end

function CrabMeteor:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
end

return CrabMeteor