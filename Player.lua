-- Player.lua
local Player = {}
Player.__index = Player

function Player:new(x, y, img, imgData)
    local self = setmetatable({}, Player)
    self.image = img
    self.imageData = imgData 
    self.x = x
    self.y = y
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
  
    self.speed = 300  -- Base speed 

    -- Cooldown for laser shot
    self.canShoot = true
    self.cooldownDuration = 0.35 
    self.laserShootTime = 0
    
    return self
end

function Player:update(dt) 
    -- Movement logic
    local dx, dy = 0, 0
    
    -- Arrow keys OR WASD
    if love.keyboard.isDown('right') or love.keyboard.isDown('d') then dx = 1 end
    if love.keyboard.isDown('left') or love.keyboard.isDown('a') then dx = -1 end
    if love.keyboard.isDown('down') or love.keyboard.isDown('s') then dy = 1 end
    if love.keyboard.isDown('up') or love.keyboard.isDown('w') then dy = -1 end

    -- Sprint Logic (Shift)
    -- actual movement uses this local variable
    local currentMoveSpeed = self.speed
    if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
        currentMoveSpeed = 475
    end

    -- Normalizing diagonal movement
    local length = math.sqrt(dx * dx + dy * dy)
    if length > 0 then
        dx = dx / length
        dy = dy / length
    end

    self.x = self.x + dx * currentMoveSpeed * dt
    self.y = self.y + dy * currentMoveSpeed * dt

    -- Screen boundaries (using globals defined in main)
    self.x = math.max(self.width / 2, math.min(WINDOW_WIDTH - self.width / 2, self.x))
    self.y = math.max(self.height / 2, math.min(WINDOW_HEIGHT - self.height / 2, self.y))

    -- Cooldown logic
    if not self.canShoot then 
        self.laserShootTime = self.laserShootTime - dt 
        if self.laserShootTime <= 0 then 
            self.canShoot = true
        end
    end
end

function Player:shoot(lasersTable, laserSurf, laserData, laserSound)
    if self.canShoot then
        -- We access the global Laser class here, or pass it in.
        -- Laser should be global by the time this is called.
        table.insert(lasersTable, Laser:new(self.x, self.y - self.height / 2, laserSurf, laserData))
        self.canShoot = false 
        self.laserShootTime = self.cooldownDuration 
   
        laserSound:clone():play() 
    end
end

function Player:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
end

return Player