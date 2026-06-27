-- main.lua

-- Require Class Files
Player        = require "Player"
Laser         = require "Laser"
Meteor        = require "Meteor"
PhoenixMeteor = require "PhoenixMeteor"
TrackerMeteor = require "TrackerMeteor"
CrabMeteor    = require "CrabMeteor"
LobsterMeteor = require "LobsterMeteor"
AnimatedExplosion = require "AnimatedExplosion"

-- ═══════════════════════════════════════════════════════════
--  GUI Colour Palette
-- ═══════════════════════════════════════════════════════════
local C = {
    accent  = { 0.20, 0.76, 1.00 },        -- electric cyan
    dark    = { 0.04, 0.04, 0.14 },        -- panel fill
    border  = { 0.25, 0.30, 0.60, 0.80 }, -- panel border (rgba)
    text    = { 0.90, 0.95, 1.00 },        -- primary text
    textDim = { 0.48, 0.53, 0.72 },        -- subdued labels
    easy    = { 0.15, 0.90, 0.30 },
    normal  = { 1.00, 0.80, 0.10 },
    hard    = { 1.00, 0.22, 0.22 },
}

-- ═══════════════════════════════════════════════════════════
--  GUI Helpers
-- ═══════════════════════════════════════════════════════════

-- Dark translucent panel with a coloured border
local function drawPanel(x, y, w, h, r, alpha)
    r     = r     or 12
    alpha = alpha or 0.88
    love.graphics.setColor(C.dark[1], C.dark[2], C.dark[3], alpha)
    love.graphics.rectangle("fill", x, y, w, h, r, r)
    love.graphics.setColor(C.border[1], C.border[2], C.border[3], C.border[4])
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line", x, y, w, h, r, r)
    love.graphics.setLineWidth(1)
end

-- Styled button with hover glow  (btn.x / btn.y are the CENTRE)
-- gr, gg, gb  override the hover colour (default: cyan accent)
local function drawStyledButton(btn, isHovering, gr, gg, gb)
    gr = gr or C.accent[1]
    gg = gg or C.accent[2]
    gb = gb or C.accent[3]
    local bx = btn.x - btn.width  / 2
    local by = btn.y - btn.height / 2
    local bw, bh = btn.width, btn.height

    if isHovering then
        -- soft outer glow
        love.graphics.setColor(gr, gg, gb, 0.12)
        love.graphics.rectangle("fill", bx - 5, by - 5, bw + 10, bh + 10, 14, 14)
        -- dark navy fill
        love.graphics.setColor(0.07, 0.10, 0.22, 0.96)
        love.graphics.rectangle("fill", bx, by, bw, bh, 10, 10)
        -- bright border in accent colour
        love.graphics.setColor(gr, gg, gb, 0.95)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", bx, by, bw, bh, 10, 10)
        love.graphics.setLineWidth(1)
        -- text in accent colour
        love.graphics.setColor(gr, gg, gb)
    else
        -- fill
        love.graphics.setColor(0.08, 0.08, 0.20, 0.92)
        love.graphics.rectangle("fill", bx, by, bw, bh, 10, 10)
        -- subtle border
        love.graphics.setColor(0.22, 0.22, 0.46, 0.80)
        love.graphics.setLineWidth(1.5)
        love.graphics.rectangle("line", bx, by, bw, bh, 10, 10)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(C.text[1], C.text[2], C.text[3])
    end
    love.graphics.printf(btn.text, bx, btn.y - font:getHeight() / 2, bw, "center")
end

-- Text with a drop-shadow for extra pop (r, g, b default to white)
local function drawShadowText(text, x, y, w, align, r, g, b)
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.printf(text, x + 2, y + 3, w, align)
    love.graphics.setColor(r or 1, g or 1, b or 1)
    love.graphics.printf(text, x, y, w, align)
end

-- ═══════════════════════════════════════════════════════════
--  Pixel Collision Helper
-- ═══════════════════════════════════════════════════════════
function checkPixelCollision(a, b)
    local ax1 = a.x - a.width / 2
    local ay1 = a.y - a.height / 2
    local ax2 = a.x + a.width / 2
    local ay2 = a.y + a.height / 2

    local bx1 = b.x - b.width / 2
    local by1 = b.y - b.height / 2
    local bx2 = b.x + b.width / 2
    local by2 = b.y + b.height / 2

    if not (ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1) then
        return false
    end

    local overlapX1 = math.max(ax1, bx1)
    local overlapY1 = math.max(ay1, by1)
    local overlapX2 = math.min(ax2, bx2)
    local overlapY2 = math.min(ay2, by2)

    local bRot    = b.rotation or 0
    local angleRad = math.rad(-bRot)
    local cos_t   = math.cos(angleRad)
    local sin_t   = math.sin(angleRad)

    for x = math.floor(overlapX1), math.ceil(overlapX2) do
        for y = math.floor(overlapY1), math.ceil(overlapY2) do
            local localAx = math.floor(x - ax1)
            local localAy = math.floor(y - ay1)
            if localAx >= 0 and localAx < a.width and localAy >= 0 and localAy < a.height then
                local _, _, _, a_alpha = a.imageData:getPixel(localAx, localAy)
                if a_alpha > 0 then
                    local relativeBx  = x - b.x
                    local relativeBy  = y - b.y
                    local unrotatedBx = relativeBx * cos_t + relativeBy * sin_t
                    local unrotatedBy = -relativeBx * sin_t + relativeBy * cos_t
                    local localBx     = unrotatedBx + b.width  / 2
                    local localBy     = unrotatedBy + b.height / 2

                    if localBx >= 0 and localBx < b.width and localBy >= 0 and localBy < b.height then
                        local _, _, _, b_alpha = b.imageData:getPixel(math.floor(localBx), math.floor(localBy))
                        if b_alpha > 0 then return true end
                    end
                end
            end
        end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════
--  Spawn Functions
-- ═══════════════════════════════════════════════════════════
function spawnMeteor()
    local x = love.math.random(0, WINDOW_WIDTH)
    local y = love.math.random(-200, -100)
    table.insert(meteors, Meteor:new(x, y, meteorSurf, meteorImageData))
end

function spawnPhoenixMeteor()
    local x = love.math.random(0, WINDOW_WIDTH)
    local y = love.math.random(-200, -100)
    table.insert(phoenixMeteors, PhoenixMeteor:new(x, y, phoenixSurf1, phoenixImageData1, phoenixSurf2, phoenixImageData2))
end

function spawnTrackerMeteor()
    local x = love.math.random(0, WINDOW_WIDTH)
    local y = love.math.random(-200, -100)
    table.insert(trackerMeteors, TrackerMeteor:new(x, y, player.x, player.y, trackerSurf, trackerImageData))
end

function spawnCrabMeteor()
    local x = player.x
    local y = love.math.random(-200, -100)
    table.insert(crabMeteors, CrabMeteor:new(x, y, crabSurf, crabImageData, player))
end

function spawnLobsterMeteor()
    local x = player.x
    local y = love.math.random(-200, -100)
    table.insert(lobsterMeteors, LobsterMeteor:new(x, y, lobsterSurf, lobsterImageData))
end

-- ═══════════════════════════════════════════════════════════
--  UI Drawing
-- ═══════════════════════════════════════════════════════════

function drawSettings()
    love.graphics.draw(settingsBackgroundSurf, 0, 0)

    -- Title (pre-loaded headingFont avoids creating a font every frame)
    love.graphics.setFont(headingFont)
    drawShadowText("SETTINGS", 0, 42, WINDOW_WIDTH, "center",
        C.accent[1], C.accent[2], C.accent[3])
    love.graphics.setFont(font)

    -- Sliders card
    local cardW, cardH = 430, 292
    local cardX = WINDOW_WIDTH / 2 - cardW / 2
    drawPanel(cardX, 148, cardW, cardH, 14)

    local sliders = {
        { name = "Game Music",    val = tempVolMusic,     y = 200 },
        { name = "Explosion SFX", val = tempVolExplosion, y = 280 },
        { name = "Laser SFX",     val = tempVolLaser,     y = 360 },
    }
    local sliderWidth = 300
    local sliderX     = WINDOW_WIDTH / 2 - sliderWidth / 2
    local half        = WINDOW_WIDTH / 2

    for _, s in ipairs(sliders) do
        -- Two-colour label: name (dim) left of centre | percentage (cyan) right of centre
        love.graphics.setColor(C.textDim[1], C.textDim[2], C.textDim[3])
        love.graphics.printf(s.name, 0, s.y - 30, half - 10, "right")
        love.graphics.setColor(C.accent[1], C.accent[2], C.accent[3])
        love.graphics.printf(math.floor(s.val * 100) .. "%", half + 10, s.y - 30, half - 10, "left")

        -- Track groove
        love.graphics.setColor(0.08, 0.08, 0.22, 0.90)
        love.graphics.rectangle("fill", sliderX - 4, s.y - 5, sliderWidth + 8, 10, 5, 5)
        love.graphics.setColor(0.20, 0.20, 0.46, 0.70)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", sliderX - 4, s.y - 5, sliderWidth + 8, 10, 5, 5)

        -- Cyan filled portion
        if s.val > 0 then
            love.graphics.setColor(C.accent[1], C.accent[2], C.accent[3], 0.82)
            love.graphics.rectangle("fill", sliderX, s.y - 3, s.val * sliderWidth, 6, 3, 3)
        end

        -- Handle: dark core + cyan ring + white dot
        local hx = sliderX + s.val * sliderWidth
        love.graphics.setColor(0.04, 0.08, 0.22)
        love.graphics.circle("fill", hx, s.y, 11)
        love.graphics.setColor(C.accent[1], C.accent[2], C.accent[3])
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", hx, s.y, 11)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", hx, s.y, 4)
    end

    -- Save / Back buttons
    local mx, my = love.mouse.getPosition()

    local isHoveringSave =
        mx > (saveButton.x - saveButton.width  / 2) and mx < (saveButton.x + saveButton.width  / 2) and
        my > (saveButton.y - saveButton.height / 2) and my < (saveButton.y + saveButton.height / 2)
    drawStyledButton(saveButton, isHoveringSave, C.easy[1], C.easy[2], C.easy[3])

    local isHoveringBack =
        mx > (backButton.x - backButton.width  / 2) and mx < (backButton.x + backButton.width  / 2) and
        my > (backButton.y - backButton.height / 2) and my < (backButton.y + backButton.height / 2)
    drawStyledButton(backButton, isHoveringBack)

    love.graphics.setColor(1, 1, 1)
end

function drawMenu()
    love.graphics.draw(menuBackgroundSurf, 0, 0)

    -- Title: larger font, cyan drop-shadow
    love.graphics.setFont(titleFont)
    drawShadowText("SPACE SHOOTER", 0, 88, WINDOW_WIDTH, "center",
        C.accent[1], C.accent[2], C.accent[3])
    love.graphics.setFont(font)

    -- Best-score card
    local scores = scoresByDifficulty[difficulty]
    local pW, pX, pY = 390, WINDOW_WIDTH / 2 - 195, 155
    drawPanel(pX, pY, pW, 72, 10)
    love.graphics.setColor(C.textDim[1], C.textDim[2], C.textDim[3])
    love.graphics.printf("BEST  —  " .. difficulty:upper(), pX, pY + 10, pW, "center")
    love.graphics.setColor(C.text[1], C.text[2], C.text[3])
    love.graphics.printf(
        "Score: " .. scores.highScore .. "     Time: " .. math.floor(scores.highTime) .. "s",
        pX, pY + 38, pW, "center"
    )

    local mx, my = love.mouse.getPosition()

    -- Resume button (shown only when game is paused)
    if Paused then
        local canResume = (difficulty == activeGameDifficulty)
        local isHoveringResume =
            mx > (resumeButton.x - resumeButton.width  / 2) and mx < (resumeButton.x + resumeButton.width  / 2) and
            my > (resumeButton.y - resumeButton.height / 2) and my < (resumeButton.y + resumeButton.height / 2)
        if canResume then
            drawStyledButton(resumeButton, isHoveringResume, C.easy[1], C.easy[2], C.easy[3])
        else
            -- Greyed-out / disabled
            local bx = resumeButton.x - resumeButton.width  / 2
            local by = resumeButton.y - resumeButton.height / 2
            love.graphics.setColor(0.07, 0.07, 0.15, 0.60)
            love.graphics.rectangle("fill", bx, by, resumeButton.width, resumeButton.height, 10, 10)
            love.graphics.setColor(0.25, 0.25, 0.40, 0.40)
            love.graphics.setLineWidth(1.5)
            love.graphics.rectangle("line", bx, by, resumeButton.width, resumeButton.height, 10, 10)
            love.graphics.setLineWidth(1)
            love.graphics.setColor(0.35, 0.35, 0.50, 0.60)
            love.graphics.printf(resumeButton.text, bx, resumeButton.y - font:getHeight() / 2,
                resumeButton.width, "center")
        end
    end

    -- Play button
    local isHoveringPlay =
        mx > (playButton.x - playButton.width  / 2) and mx < (playButton.x + playButton.width  / 2) and
        my > (playButton.y - playButton.height / 2) and my < (playButton.y + playButton.height / 2)
    drawStyledButton(playButton, isHoveringPlay)

    -- Difficulty section label
    love.graphics.setColor(C.textDim[1], C.textDim[2], C.textDim[3])
    love.graphics.printf("DIFFICULTY", 0, 397, WINDOW_WIDTH, "center")

    -- Difficulty buttons
    local diffs      = { "easy", "normal", "hard" }
    local diffColors = { C.easy, C.normal, C.hard }
    local startX     = WINDOW_WIDTH / 2 - 120

    for i, diff in ipairs(diffs) do
        local bx  = startX + (i - 1) * 120
        local by  = WINDOW_HEIGHT / 2 + 130
        local isH = mx > (bx - 50) and mx < (bx + 50) and my > (by - 20) and my < (by + 20)
        local dc  = diffColors[i]

        if difficulty == diff then
            -- Selected: dim tinted fill + bright coloured border
            love.graphics.setColor(dc[1] * 0.18, dc[2] * 0.18, dc[3] * 0.18, 0.95)
            love.graphics.rectangle("fill", bx - 50, by - 20, 100, 40, 8, 8)
            love.graphics.setColor(dc[1], dc[2], dc[3], 1.0)
            love.graphics.setLineWidth(2.5)
            love.graphics.rectangle("line", bx - 50, by - 20, 100, 40, 8, 8)
            love.graphics.setLineWidth(1)
            love.graphics.setColor(dc[1], dc[2], dc[3])
        elseif isH then
            -- Hover: subtle fill + half-bright border
            love.graphics.setColor(0.12, 0.12, 0.28, 0.80)
            love.graphics.rectangle("fill", bx - 50, by - 20, 100, 40, 8, 8)
            love.graphics.setColor(dc[1], dc[2], dc[3], 0.55)
            love.graphics.setLineWidth(1.5)
            love.graphics.rectangle("line", bx - 50, by - 20, 100, 40, 8, 8)
            love.graphics.setLineWidth(1)
            love.graphics.setColor(C.text[1], C.text[2], C.text[3])
        else
            -- Idle: dark fill + muted border
            love.graphics.setColor(0.07, 0.07, 0.18, 0.80)
            love.graphics.rectangle("fill", bx - 50, by - 20, 100, 40, 8, 8)
            love.graphics.setColor(0.20, 0.20, 0.42, 0.65)
            love.graphics.setLineWidth(1.5)
            love.graphics.rectangle("line", bx - 50, by - 20, 100, 40, 8, 8)
            love.graphics.setLineWidth(1)
            love.graphics.setColor(C.textDim[1], C.textDim[2], C.textDim[3])
        end
        love.graphics.printf(diff:upper(), bx - 50, by - font:getHeight() / 2, 100, "center")
    end

    -- Settings button (bottom-left corner)
    local isHoveringSettings =
        mx > (settingsButton.x - settingsButton.width  / 2) and mx < (settingsButton.x + settingsButton.width  / 2) and
        my > (settingsButton.y - settingsButton.height / 2) and my < (settingsButton.y + settingsButton.height / 2)
    drawStyledButton(settingsButton, isHoveringSettings)

    love.graphics.setColor(1, 1, 1)
end

-- ═══════════════════════════════════════════════════════════
--  Collision Logic  (unchanged)
-- ═══════════════════════════════════════════════════════════
function checkAllCollisions()
    local function handlePlayerDeath()
        gameState = "gameOver"
        Paused = false
        local currentScore = math.floor(score)
        local scores = scoresByDifficulty[activeGameDifficulty]
        if currentScore > scores.highScore then scores.highScore = currentScore end
        if timeAlive > scores.highTime then scores.highTime = timeAlive end
    end

    -- Player Collisions
    for i = #meteors,        1, -1 do if checkPixelCollision(player, meteors[i])        then handlePlayerDeath() end end
    for i = #phoenixMeteors, 1, -1 do if checkPixelCollision(player, phoenixMeteors[i]) then handlePlayerDeath() end end
    for i = #trackerMeteors, 1, -1 do if checkPixelCollision(player, trackerMeteors[i]) then handlePlayerDeath() end end
    for i = #crabMeteors,    1, -1 do if checkPixelCollision(player, crabMeteors[i])    then handlePlayerDeath() end end
    for i = #lobsterMeteors, 1, -1 do if checkPixelCollision(player, lobsterMeteors[i]) then handlePlayerDeath() end end

    -- Laser Collisions
    for i = #lasers, 1, -1 do
        local laser    = lasers[i]
        local laserHit = false

        if not laserHit then
            for j = #meteors, 1, -1 do
                local meteor = meteors[j]
                if checkPixelCollision(laser, meteor) then
                    laser.dead = true; meteor.dead = true
                    table.insert(explosions, AnimatedExplosion:new(meteor.x, meteor.y, explosionFrames))
                    explosionSound:clone():play()
                    meteorsDestroyed = meteorsDestroyed + 1
                    score    = score + 50
                    laserHit = true
                    break
                end
            end
        end

        if not laserHit then
            for j = #phoenixMeteors, 1, -1 do
                local pMeteor = phoenixMeteors[j]
                if checkPixelCollision(laser, pMeteor) then
                    laser.dead = true
                    pMeteor:hit()
                    if pMeteor.dead then
                        table.insert(explosions, AnimatedExplosion:new(pMeteor.x, pMeteor.y, explosionFrames))
                        meteorsDestroyed = meteorsDestroyed + 1
                        score = score + 150
                    end
                    explosionSound:clone():play()
                    laserHit = true
                    break
                end
            end
        end

        if not laserHit then
            for j = #trackerMeteors, 1, -1 do
                local tMeteor = trackerMeteors[j]
                if checkPixelCollision(laser, tMeteor) then
                    laser.dead = true; tMeteor.dead = true
                    table.insert(explosions, AnimatedExplosion:new(tMeteor.x, tMeteor.y, explosionFrames))
                    explosionSound:clone():play()
                    meteorsDestroyed = meteorsDestroyed + 1
                    score    = score + 500
                    laserHit = true
                    break
                end
            end
        end

        if not laserHit then
            for j = #crabMeteors, 1, -1 do
                local cMeteor = crabMeteors[j]
                if checkPixelCollision(laser, cMeteor) then
                    laser.dead = true; cMeteor.dead = true
                    table.insert(explosions, AnimatedExplosion:new(cMeteor.x, cMeteor.y, explosionFrames))
                    explosionSound:clone():play()
                    meteorsDestroyed = meteorsDestroyed + 1
                    score    = score + 250
                    laserHit = true
                    break
                end
            end
        end

        if not laserHit then
            for j = #lobsterMeteors, 1, -1 do
                local lMeteor = lobsterMeteors[j]
                if checkPixelCollision(laser, lMeteor) then
                    laser.dead = true; lMeteor.dead = true
                    table.insert(explosions, AnimatedExplosion:new(lMeteor.x, lMeteor.y, explosionFrames))
                    explosionSound:clone():play()
                    meteorsDestroyed = meteorsDestroyed + 1
                    score    = score + 250
                    laserHit = true
                    break
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════
--  HUD elements
-- ═══════════════════════════════════════════════════════════

function displayScore()
    local scoreText = tostring(math.floor(score))
    local txt       = love.graphics.newText(font, scoreText)
    local tw        = txt:getWidth()
    local th        = txt:getHeight()
    local cx        = WINDOW_WIDTH / 2
    local cy        = WINDOW_HEIGHT - 50
    local px, py    = 22, 9
    local panelW    = math.max(tw + px * 2, 110)
    local panelH    = th + py * 2

    -- Dark panel with cyan border
    love.graphics.setColor(C.dark[1], C.dark[2], C.dark[3], 0.88)
    love.graphics.rectangle("fill",
        cx - panelW / 2, cy - panelH / 2, panelW, panelH, 10, 10)
    love.graphics.setColor(C.accent[1], C.accent[2], C.accent[3], 0.80)
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line",
        cx - panelW / 2, cy - panelH / 2, panelW, panelH, 10, 10)
    love.graphics.setLineWidth(1)

    -- Score value
    love.graphics.setColor(C.text[1], C.text[2], C.text[3])
    love.graphics.printf(scoreText, 0, cy - th / 2, WINDOW_WIDTH, "center")
    love.graphics.setColor(1, 1, 1)
end

function drawInGameMenuButton()
    local mx, my = love.mouse.getPosition()
    local isH =
        mx > (inGameMenuButton.x - inGameMenuButton.width  / 2) and
        mx < (inGameMenuButton.x + inGameMenuButton.width  / 2) and
        my > (inGameMenuButton.y - inGameMenuButton.height / 2) and
        my < (inGameMenuButton.y + inGameMenuButton.height / 2)
    drawStyledButton(inGameMenuButton, isH)
    love.graphics.setColor(1, 1, 1)
end

function drawGameOver()
    love.graphics.draw(gameOverBackgroundSurf, 0, 0)
    local finalScore = math.floor(score)
    local time       = math.floor(timeAlive)

    -- Stats card
    local cardW, cardH = 420, 248
    local cardX = WINDOW_WIDTH / 2 - cardW / 2
    local cardY = 205
    drawPanel(cardX, cardY, cardW, cardH, 16)

    -- "GAME OVER" heading: red, drop-shadow
    love.graphics.setFont(headingFont)
    drawShadowText("GAME OVER", 0, cardY + 18, WINDOW_WIDTH, "center", 1.0, 0.22, 0.22)
    love.graphics.setFont(font)

    -- Divider line
    love.graphics.setColor(C.border[1], C.border[2], C.border[3], C.border[4])
    love.graphics.setLineWidth(1)
    love.graphics.line(cardX + 24, cardY + 74, cardX + cardW - 24, cardY + 74)

    -- Score row
    love.graphics.setColor(C.textDim[1], C.textDim[2], C.textDim[3])
    love.graphics.printf("SCORE", 0, cardY + 84, WINDOW_WIDTH, "center")
    love.graphics.setColor(C.text[1], C.text[2], C.text[3])
    love.graphics.printf(tostring(finalScore), 0, cardY + 106, WINDOW_WIDTH, "center")

    -- Time row
    love.graphics.setColor(C.textDim[1], C.textDim[2], C.textDim[3])
    love.graphics.printf("TIME SURVIVED", 0, cardY + 140, WINDOW_WIDTH, "center")
    love.graphics.setColor(C.text[1], C.text[2], C.text[3])
    love.graphics.printf(time .. "s", 0, cardY + 162, WINDOW_WIDTH, "center")

    -- Difficulty row (coloured by level)
    love.graphics.setColor(C.textDim[1], C.textDim[2], C.textDim[3])
    love.graphics.printf("DIFFICULTY", 0, cardY + 196, WINDOW_WIDTH, "center")
    local dc
    if     activeGameDifficulty == "easy"   then dc = C.easy
    elseif activeGameDifficulty == "normal" then dc = C.normal
    elseif activeGameDifficulty == "hard"   then dc = C.hard
    else                                         dc = C.text end
    love.graphics.setColor(dc[1], dc[2], dc[3])
    love.graphics.printf(activeGameDifficulty:upper(), 0, cardY + 218, WINDOW_WIDTH, "center")

    -- Replay / Menu buttons (positions untouched for hit-test compatibility)
    local mx, my = love.mouse.getPosition()
    local isHR =
        mx > (replayButton.x - replayButton.width  / 2) and mx < (replayButton.x + replayButton.width  / 2) and
        my > (replayButton.y - replayButton.height / 2) and my < (replayButton.y + replayButton.height / 2)
    drawStyledButton(replayButton, isHR, C.easy[1], C.easy[2], C.easy[3])

    local isHM =
        mx > (menuButton.x - menuButton.width  / 2) and mx < (menuButton.x + menuButton.width  / 2) and
        my > (menuButton.y - menuButton.height / 2) and my < (menuButton.y + menuButton.height / 2)
    drawStyledButton(menuButton, isHM)

    love.graphics.setColor(1, 1, 1)
end

-- ═══════════════════════════════════════════════════════════
--  Game Reset  (unchanged)
-- ═══════════════════════════════════════════════════════════
function resetGame()
    gameState = "playing"
    Paused    = false
    activeGameDifficulty = difficulty
    timeAlive        = 0
    meteorsDestroyed = 0
    score            = 0
    lasers           = {}
    meteors          = {}
    phoenixMeteors   = {}
    trackerMeteors   = {}
    crabMeteors      = {}
    lobsterMeteors   = {}
    explosions       = {}

    player = Player:new(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 1.5, playerSurf, playerImageData)

    spawnRateConfig = {
        easy   = { start = 0.75, min = 0.25  },
        normal = { start = 0.5,  min = 0.175 },
        hard   = { start = 0.3,  min = 0.1   },
    }
    baseSpawnTimer = spawnRateConfig[activeGameDifficulty].start

    meteorSpawnTimer  = 0
    phoenixSpawnTimer = 0
    trackerSpawnTimer = 0
    crabSpawnTimer    = 0
    lobsterSpawnTimer = 0
end

-- ═══════════════════════════════════════════════════════════
--  LÖVE Callbacks
-- ═══════════════════════════════════════════════════════════
function love.load()
    WINDOW_WIDTH, WINDOW_HEIGHT = 1200, 630
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { vsync = true })
    love.window.setTitle("spaceow")

    -- Images
    backgroundSurf         = love.graphics.newImage('images/background1.jpg')
    gameOverBackgroundSurf = love.graphics.newImage('images/background.jpg')
    menuBackgroundSurf     = love.graphics.newImage('images/menu_background.png')
    settingsBackgroundSurf = love.graphics.newImage('images/settings_background.jpg')
    playerSurf             = love.graphics.newImage('images/shimeji.png')
    meteorSurf             = love.graphics.newImage('images/egg_one.png')
    laserSurf              = love.graphics.newImage('images/fish1.png')
    phoenixSurf1           = love.graphics.newImage('images/lemon_meteor_1.png')
    phoenixSurf2           = love.graphics.newImage('images/lemon_meteor_2.png')
    trackerSurf            = love.graphics.newImage('images/tracker_meteor.png')
    crabSurf               = love.graphics.newImage('images/crab_meteor.png')
    lobsterSurf            = love.graphics.newImage('images/lobster_meteor.png')

    -- ImageData for pixel-perfect collision
    playerImageData   = love.image.newImageData('images/shimeji.png')
    meteorImageData   = love.image.newImageData('images/egg_one.png')
    laserImageData    = love.image.newImageData('images/fish1.png')
    phoenixImageData1 = love.image.newImageData('images/lemon_meteor_1.png')
    phoenixImageData2 = love.image.newImageData('images/lemon_meteor_2.png')
    trackerImageData  = love.image.newImageData('images/tracker_meteor.png')
    crabImageData     = love.image.newImageData('images/crab_meteor.png')
    lobsterImageData  = love.image.newImageData('images/lobster_meteor.png')

    -- Fonts: pre-loaded once so draw functions don't recreate them every frame
    font        = love.graphics.newFont("images/Oxanium-Bold.ttf", 20)
    headingFont = love.graphics.newFont("images/Oxanium-Bold.ttf", 40)
    titleFont   = love.graphics.newFont("images/Oxanium-Bold.ttf", 56)
    love.graphics.setFont(font)

    -- Explosion frames
    ExplosionImageCount = 8
    explosionFrames = {}
    for i = 0, ExplosionImageCount do
        table.insert(explosionFrames, love.graphics.newImage("images/explosion/" .. i .. ".png"))
    end

    -- Audio
    laserSound     = love.audio.newSource("audio/mewo.mp3",        "static")
    explosionSound = love.audio.newSource("audio/eggsplotion.mp3", "static")
    gameMusic      = love.audio.newSource("audio/gamesong1.mp3",   "stream")

    currentVolLaser     = 0.3
    currentVolExplosion = 0.4
    currentVolMusic     = 0.1
    laserSound:setVolume(currentVolLaser)
    explosionSound:setVolume(currentVolExplosion)
    gameMusic:setVolume(currentVolMusic)
    gameMusic:setLooping(true)
    gameMusic:play()

    -- Buttons (positions unchanged — referenced by love.mousepressed hit-tests)
    replayButton     = { x = WINDOW_WIDTH / 2,      y = WINDOW_HEIGHT / 2 + 180, width = 150, height = 50, text = "Replay"   }
    menuButton       = { x = WINDOW_WIDTH / 2,      y = WINDOW_HEIGHT / 2 + 240, width = 150, height = 50, text = "Menu"     }
    playButton       = { x = WINDOW_WIDTH / 2,      y = WINDOW_HEIGHT / 2 + 50,  width = 150, height = 50, text = "Play"     }
    resumeButton     = { x = WINDOW_WIDTH / 2,      y = WINDOW_HEIGHT / 2 - 20,  width = 150, height = 50, text = "Resume"   }
    inGameMenuButton = { x = 70,                    y = WINDOW_HEIGHT - 40,       width = 100, height = 40, text = "Menu"     }
    settingsButton   = { x = 70,                    y = WINDOW_HEIGHT - 40,       width = 100, height = 40, text = "Settings" }
    saveButton       = { x = WINDOW_WIDTH / 2 - 80, y = WINDOW_HEIGHT - 100,      width = 150, height = 50, text = "Save"     }
    backButton       = { x = WINDOW_WIDTH / 2 + 80, y = WINDOW_HEIGHT - 100,      width = 150, height = 50, text = "Back"     }

    activeSlider     = nil
    tempVolMusic     = currentVolMusic
    tempVolExplosion = currentVolExplosion
    tempVolLaser     = currentVolLaser

    difficulty           = "normal"
    activeGameDifficulty = "normal"
    scoresByDifficulty   = {
        easy   = { highScore = 0, highTime = 0 },
        normal = { highScore = 0, highTime = 0 },
        hard   = { highScore = 0, highTime = 0 },
    }

    Paused = false
    resetGame()
    gameState = "menu"
end

function love.update(dt)
    if gameState == "playing" and not Paused then
        timeAlive = timeAlive + dt
        score     = score + (10 * dt)

        -- Dynamic Spawn Timer
        local config     = spawnRateConfig[activeGameDifficulty]
        local targetTime = 300
        local t          = math.min(timeAlive, targetTime) / targetTime
        local ease       = t * t
        baseSpawnTimer   = config.start - (config.start - config.min) * ease

        meteorSpawnRate  = baseSpawnTimer
        phoenixSpawnRate = baseSpawnTimer * 12
        trackerSpawnRate = baseSpawnTimer * 31
        crabSpawnRate    = baseSpawnTimer * 25
        lobsterSpawnRate = baseSpawnTimer * 63

        -- Spawn Timers
        meteorSpawnTimer  = meteorSpawnTimer  + dt
        if meteorSpawnTimer  > meteorSpawnRate  then spawnMeteor();        meteorSpawnTimer  = 0 end
        phoenixSpawnTimer = phoenixSpawnTimer + dt
        if phoenixSpawnTimer > phoenixSpawnRate then spawnPhoenixMeteor(); phoenixSpawnTimer = 0 end
        trackerSpawnTimer = trackerSpawnTimer + dt
        if trackerSpawnTimer > trackerSpawnRate then spawnTrackerMeteor(); trackerSpawnTimer = 0 end
        crabSpawnTimer    = crabSpawnTimer    + dt
        if crabSpawnTimer    > crabSpawnRate    then spawnCrabMeteor();    crabSpawnTimer    = 0 end
        lobsterSpawnTimer = lobsterSpawnTimer + dt
        if lobsterSpawnTimer > lobsterSpawnRate then spawnLobsterMeteor(); lobsterSpawnTimer = 0 end

        -- Entity Updates
        player:update(dt)

        for i = #lasers, 1, -1 do
            lasers[i]:update(dt)
            if lasers[i].dead then table.remove(lasers, i) end
        end
        for i = #meteors, 1, -1 do
            meteors[i]:update(dt)
            if meteors[i].dead then table.remove(meteors, i) end
        end
        for i = #phoenixMeteors, 1, -1 do
            phoenixMeteors[i]:update(dt)
            if phoenixMeteors[i].dead then table.remove(phoenixMeteors, i) end
        end
        for i = #trackerMeteors, 1, -1 do
            trackerMeteors[i]:update(dt)
            if trackerMeteors[i].dead then table.remove(trackerMeteors, i) end
        end
        for i = #crabMeteors, 1, -1 do
            crabMeteors[i]:update(dt)
            if crabMeteors[i].dead then table.remove(crabMeteors, i) end
        end
        for i = #lobsterMeteors, 1, -1 do
            lobsterMeteors[i]:update(dt, player, lasers)
            if lobsterMeteors[i].dead then table.remove(lobsterMeteors, i) end
        end
        for i = #explosions, 1, -1 do
            explosions[i]:update(dt)
            if explosions[i].dead then table.remove(explosions, i) end
        end

        checkAllCollisions()

    elseif gameState == "settings" then
        if love.mouse.isDown(1) and activeSlider then
            local mx, my  = love.mouse.getPosition()
            local sliderWidth = 300
            local sliderX     = WINDOW_WIDTH / 2 - sliderWidth / 2
            local val         = (mx - sliderX) / sliderWidth
            if val < 0 then val = 0 end
            if val > 1 then val = 1 end
            if activeSlider == "music"     then tempVolMusic     = val end
            if activeSlider == "explosion" then tempVolExplosion = val end
            if activeSlider == "laser"     then tempVolLaser     = val end
        else
            activeSlider = nil
        end
    end
end

function love.draw()
    if gameState == "menu" then
        drawMenu()
    elseif gameState == "settings" then
        drawSettings()
    elseif gameState == "playing" then
        love.graphics.draw(backgroundSurf, 0, 0)

        -- Game entities
        player:draw()
        for _, m  in ipairs(meteors)        do m:draw()  end
        for _, pm in ipairs(phoenixMeteors) do pm:draw() end
        for _, tm in ipairs(trackerMeteors) do tm:draw() end
        for _, cm in ipairs(crabMeteors)    do cm:draw() end
        for _, lm in ipairs(lobsterMeteors) do lm:draw() end
        for _, l  in ipairs(lasers)         do l:draw()  end
        for _, e  in ipairs(explosions)     do e:draw()  end

        displayScore()
        drawInGameMenuButton()

        -- Controls hint panel (top-left)
        local lh = font:getHeight() + 5
        drawPanel(10, 10, 215, 5 * lh + 14, 8, 0.72)
        love.graphics.setColor(C.textDim[1], C.textDim[2], C.textDim[3])
        love.graphics.printf("WASD -> movement",   20, 18 + 0 * lh, 200, "left")
        love.graphics.printf("Space -> Shoot",     20, 18 + 1 * lh, 200, "left")
        love.graphics.printf("Shift -> Sprint",    20, 18 + 2 * lh, 200, "left")
        love.graphics.printf("P -> Pause/Unpause", 20, 18 + 3 * lh, 200, "left")
        love.graphics.printf("M -> Menu",          20, 18 + 4 * lh, 200, "left")

        -- Pause overlay
        if Paused then
            love.graphics.setColor(0, 0, 0, 0.60)
            love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

            local pW, pH = 280, 90
            drawPanel(WINDOW_WIDTH / 2 - pW / 2, WINDOW_HEIGHT / 2 - pH / 2, pW, pH, 14)

            love.graphics.setFont(headingFont)
            drawShadowText("PAUSED", 0, WINDOW_HEIGHT / 2 - 20, WINDOW_WIDTH, "center",
                C.accent[1], C.accent[2], C.accent[3])
            love.graphics.setFont(font)
        end

        love.graphics.setColor(1, 1, 1)

    elseif gameState == "gameOver" then
        drawGameOver()
    end
end

function love.keypressed(key)
    if key == "space" then
        if gameState == "playing" and not Paused then
            player:shoot(lasers, laserSurf, laserImageData, laserSound)
        end
    end
    if key == "p" then if gameState == "playing" then Paused = not Paused end end
    if key == "m" then if gameState == "playing" then gameState = "menu"; Paused = true end end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if gameState == "menu" then
            if Paused then
                local isHoveringResume = x > (resumeButton.x - resumeButton.width/2) and x < (resumeButton.x + resumeButton.width/2) and y > (resumeButton.y - resumeButton.height/2) and y < (resumeButton.y + resumeButton.height/2)
                if isHoveringResume and (difficulty == activeGameDifficulty) then
                    gameState = "playing"
                    Paused = true
                end
            end
            local isHoveringPlay = x > (playButton.x - playButton.width/2) and x < (playButton.x + playButton.width/2) and y > (playButton.y - playButton.height/2) and y < (playButton.y + playButton.height/2)
            if isHoveringPlay then
                if Paused and timeAlive > 0 then
                    local currentScore = math.floor(score)
                    local scores = scoresByDifficulty[activeGameDifficulty]
                    if currentScore > scores.highScore then scores.highScore = currentScore end
                    if timeAlive > scores.highTime then scores.highTime = timeAlive end
                end
                resetGame()
            end
            local isHoveringSettings = x > (settingsButton.x - settingsButton.width/2) and x < (settingsButton.x + settingsButton.width/2) and y > (settingsButton.y - settingsButton.height/2) and y < (settingsButton.y + settingsButton.height/2)
            if isHoveringSettings then
                gameState = "settings"
                tempVolMusic = currentVolMusic; tempVolExplosion = currentVolExplosion; tempVolLaser = currentVolLaser
            end
            local diffs  = { "easy", "normal", "hard" }
            local startX = WINDOW_WIDTH / 2 - 120
            for i, diff in ipairs(diffs) do
                local btnX = startX + (i - 1) * 120
                local btnY = WINDOW_HEIGHT / 2 + 130
                if x > (btnX - 50) and x < (btnX + 50) and y > (btnY - 20) and y < (btnY + 20) then difficulty = diff end
            end

        elseif gameState == "settings" then
            local sliderWidth = 300
            local sliderX = WINDOW_WIDTH / 2 - sliderWidth / 2
            local function checkSlider(sy) return x >= sliderX and x <= sliderX + sliderWidth and y >= sy - 15 and y <= sy + 15 end
            if checkSlider(200) then activeSlider = "music"     end
            if checkSlider(280) then activeSlider = "explosion" end
            if checkSlider(360) then activeSlider = "laser"     end

            local isHoveringSave = x > (saveButton.x - saveButton.width/2) and x < (saveButton.x + saveButton.width/2) and y > (saveButton.y - saveButton.height/2) and y < (saveButton.y + saveButton.height/2)
            if isHoveringSave then
                currentVolMusic = tempVolMusic; currentVolExplosion = tempVolExplosion; currentVolLaser = tempVolLaser
                gameMusic:setVolume(currentVolMusic); explosionSound:setVolume(currentVolExplosion); laserSound:setVolume(currentVolLaser)
                gameState = "menu"
            end
            local isHoveringBack = x > (backButton.x - backButton.width/2) and x < (backButton.x + backButton.width/2) and y > (backButton.y - backButton.height/2) and y < (backButton.y + backButton.height/2)
            if isHoveringBack then gameState = "menu" end

        elseif gameState == "playing" then
            local isHoveringMenu = x > (inGameMenuButton.x - inGameMenuButton.width/2) and x < (inGameMenuButton.x + inGameMenuButton.width/2) and y > (inGameMenuButton.y - inGameMenuButton.height/2) and y < (inGameMenuButton.y + inGameMenuButton.height/2)
            if isHoveringMenu then
                gameState = "menu"
                Paused = true
            else
                if not Paused then player:shoot(lasers, laserSurf, laserImageData, laserSound) end
            end

        elseif gameState == "gameOver" then
            local isHoveringReplay = x > (replayButton.x - replayButton.width/2) and x < (replayButton.x + replayButton.width/2) and y > (replayButton.y - replayButton.height/2) and y < (replayButton.y + replayButton.height/2)
            if isHoveringReplay then resetGame() end
            local isHoveringMenu = x > (menuButton.x - menuButton.width/2) and x < (menuButton.x + menuButton.width/2) and y > (menuButton.y - menuButton.height/2) and y < (menuButton.y + menuButton.height/2)
            if isHoveringMenu then gameState = "menu"; Paused = false end
        end
    end
end
