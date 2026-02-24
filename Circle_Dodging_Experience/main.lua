function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return (x1 < x2 + w2) and (x2 < x1 + w1) and (y1 < y2 + h2) and (y2 < y1 + h1)
end

function initGlobals()
    playerSprite = {x = 215, y = 155, width = 30, height = 30, dead = false}
    circleSprites = {}
    particleSprites = {}
    playerScore = 0
    spawnTimer = 0.1
end

function love.load()
    math.randomseed(os.time())
    -- Init variables
    CIRCLE_RADIUS = 10
    PARTICLE_SIZE = 5
    print("Constants initalized")
    initGlobals()
    -- Init window
    love.window.setMode(480, 360)
    love.window.setTitle("Circle Dodging Experience")
    love.window.setIcon(love.image.newImageData("iconCDE.png"))
    print("Window initalized")
end

function love.update(dt)
    -- Define movement table.
    local movement = {vx = 0, vy = 0, speed = 250}
    if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
        movement.vx = movement.vx + 1
    end

    if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) then
        movement.vy = movement.vy + 1
    end

    if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
        movement.vx = movement.vx - 1
    end

    if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) then
        movement.vy = movement.vy - 1
    end

    -- Normalize diagonal movement.
    local magnitude = math.sqrt(movement.vx^2 + movement.vy^2)
    if (magnitude > 1) then
        movement.vx = movement.vx / magnitude
        movement.vy = movement.vy / magnitude
    end

    -- Move the player.
    playerSprite.x = playerSprite.x + (movement.vx * movement.speed) * dt
    playerSprite.y = playerSprite.y + (movement.vy * movement.speed) * dt

    -- Keep the player inside the window.
    local positiveBoundaries = {}
    positiveBoundaries[1] = love.graphics.getWidth() - playerSprite.width
    positiveBoundaries[2] = love.graphics.getHeight() - playerSprite.height

    if (playerSprite.x < 0) then
        playerSprite.x = 0
    elseif (playerSprite.x > positiveBoundaries[1]) then
        playerSprite.x = positiveBoundaries[1]
    end

    if (playerSprite.y < 0) then
        playerSprite.y = 0
    elseif (playerSprite.y > positiveBoundaries[2]) then
        playerSprite.y = positiveBoundaries[2]
    end

    -- Tick spawn timer.
    spawnTimer = spawnTimer - dt
    if (spawnTimer <= 0) then
        table.insert(circleSprites, {x = 0, y = 0, vx = math.random(0, 300), vy = math.random(0, 300)})
        spawnTimer = 0.1
    end

    -- Update circles.
    positiveBoundaries[1] = love.graphics.getWidth() + CIRCLE_RADIUS
    positiveBoundaries[2] = love.graphics.getHeight() + CIRCLE_RADIUS

    for index, circle in ipairs(circleSprites) do
        circle.x = circle.x + (circle.vx * dt)
        circle.y = circle.y + (circle.vy * dt)
        if (checkCollision(playerSprite.x, playerSprite.y, playerSprite.width, playerSprite.height, 
        circle.x - CIRCLE_RADIUS, circle.y - CIRCLE_RADIUS, CIRCLE_RADIUS * 2, CIRCLE_RADIUS * 2) and (not playerSprite.dead)) then
            playerSprite.dead = true
            index = 0
            while index < 20 do
                table.insert(particleSprites, {x = playerSprite.x + playerSprite.width / 2, y = playerSprite.y + playerSprite.height / 2,
                vx = math.random(-300, 300), vy = math.random(-300, 300)})
                index = index + 1
            end
            love.audio.play(love.audio.newSource("audio/playerExplosion.mp3", "static"))
        elseif (circle.x > positiveBoundaries[1]) or (circle.y > positiveBoundaries[2]) then
            table.remove(circleSprites, index)
            if (not playerSprite.dead) then
                playerScore = playerScore + 1
                love.audio.play(love.audio.newSource("audio/scorePoint.mp3", "static"))
            end
        end
    end

    -- Update particles.
    positiveBoundaries[1] = love.graphics.getWidth() + PARTICLE_SIZE
    positiveBoundaries[2] = love.graphics.getHeight() + PARTICLE_SIZE

    for index, particle in ipairs(particleSprites) do
        particle.x = particle.x + (particle.vx * dt)
        particle.y = particle.y + (particle.vy * dt)
        if ((particle.x < -PARTICLE_SIZE or particle.x > positiveBoundaries[1]) or (particle.y < -PARTICLE_SIZE or particle.y > positiveBoundaries[2])) then
            table.remove(particleSprites, index)
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0, 0, 1)
    -- Draw player.
    if (not playerSprite.dead) then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", playerSprite.x, playerSprite.y, playerSprite.width, playerSprite.height)
    end
    -- Draw circles.
    love.graphics.setColor(1, 0, 0, 1)
    for index, circle in ipairs(circleSprites) do
        love.graphics.ellipse("fill", circle.x, circle.y, CIRCLE_RADIUS, CIRCLE_RADIUS)
    end

    -- Print score.
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.printf(playerScore, -480 * 2, 0, 480, "right", 0, 3)

    -- Draw particles.
    love.graphics.setColor(1, 1, 1, 1)
    for index, particle in ipairs(particleSprites) do
        love.graphics.rectangle("fill", particle.x, particle.y, 5, 5)
    end

    -- Print instructions.
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Move around with Arrow Keys/WASD.", 10, 10)
    love.graphics.print("Avoid the red circles.", 10, 30)

    -- Draw death message, if nessecary.
    love.graphics.setColor(1, 1, 1, 1)
    if (playerSprite.dead) then
        love.graphics.printf("You died, press enter/return to replay the game.", 0, 280, 480, "center")
        love.graphics.printf("Alternatively, you can press escape to close the window.", 0, 300, 480, "center")
    end
end

function love.keypressed(key)
    -- Carry out functions if the play is dead.
    if (playerSprite.dead) then
        if (key == "return") then
            initGlobals()
            love.audio.play(love.audio.newSource("audio/gameRestart.mp3", "static"))
            print("Replay game")
        elseif (key == "escape") then
            print("Quit game")
            love.event.quit()
        end
    end
end