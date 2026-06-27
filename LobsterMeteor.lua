-- LobsterMeteor.lua
local LobsterMeteor = {}
LobsterMeteor.__index = LobsterMeteor

function LobsterMeteor:new(x, y, img, imgData)
    local self = setmetatable({}, LobsterMeteor)
    self.image = img
    self.imageData = imgData
    self.x = x
    self.y = y
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    -- Vertical speed based on difficulty (activeGameDifficulty is global)
    local minSpeed, maxSpeed = 300, 500  -- for normal difficulty
    if activeGameDifficulty == "easy" then minSpeed, maxSpeed = 200, 350
    elseif activeGameDifficulty == "hard" then minSpeed, maxSpeed = 450, 650 end
    self.verticalSpeed = love.math.random(minSpeed, maxSpeed)

    -- horizontal speed (Based on Player BASE speed of 300)
    -- Easy: 50%, Normal: 65%, Hard: 80%
    local hSpeedMultiplier = 0.65 -- default normal
    if activeGameDifficulty == "easy" then hSpeedMultiplier = 0.5 end
    if activeGameDifficulty == "hard" then hSpeedMultiplier = 0.8 end
    
    self.horizontalSpeed = 300 * hSpeedMultiplier

    self.dead = false
    self.detectionRange = 450 
    return self
end

function LobsterMeteor:update(dt, playerObj, lasersList)
    -- Vertical Movement
    self.y = self.y + self.verticalSpeed * dt

    -- Horizontal Logic
    local radius = self.detectionRange / 2
    local centerX, centerY = self.x, self.y
    
    local closestEntity = nil
    local closestDist = math.huge
    local entityType = nil -- "player" or "laser"

    -- 1. Check Player
    if playerObj.x > centerX - radius and playerObj.x < centerX + radius and
       playerObj.y > centerY - radius and playerObj.y < centerY + radius then
        local d = math.sqrt((playerObj.x - centerX)^2 + (playerObj.y - centerY)^2)
        if d < closestDist then
            closestDist = d
            closestEntity = playerObj
            entityType = "player"
        end
    end

    -- 2. Check Lasers
    for _, laser in ipairs(lasersList) do
        if laser.x > centerX - radius and laser.x < centerX + radius and
           laser.y > centerY - radius and laser.y < centerY + radius then
            local d = math.sqrt((laser.x - centerX)^2 + (laser.y - centerY)^2)
            if d < closestDist then
                closestDist = d
                closestEntity = laser
                entityType = "laser"
            end
        end
    end

    -- Apply Movement
    if closestEntity then
        if entityType == "player" then
            -- Chase Player
            if self.x < closestEntity.x then
                self.x = self.x + self.horizontalSpeed * dt
            else
                self.x = self.x - self.horizontalSpeed * dt
            end
        elseif entityType == "laser" then
            -- Avoid Laser
            if self.x < closestEntity.x then
                self.x = self.x - self.horizontalSpeed * dt
            else
                self.x = self.x + self.horizontalSpeed * dt
            end
        end
    end

    if self.y > WINDOW_HEIGHT + self.height then
        self.dead = true
    end
end

function LobsterMeteor:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
end

return LobsterMeteor