-- Love functions

function love.load()
    math.randomseed(os.time())
    -- Init constants
    WINDOW_WIDTH = 480
    WINDOW_HEIGHT = 360
    PARTICLE_SIZE = 6
    SHAPE_SIZE = 32
    print("Constants Initialized")

    -- Init global variables
    particleSprites = {}
    shapeSprites = {}
    currentRound = 0
    playerScore = 0
    roundTimer = 0
    waitTimer = 0
    gameState = "Nil"
    print("Global variables initialized")

    -- Init window
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.window.setTitle("Shape Targetting Thing")
    print("Window Initialized")

    startNewRound()
end

function love.update(dt)
    local badSquares = 0
    if (gameState == "InRound") then
        roundTimer = roundTimer - dt
        if (roundTimer <= 0) then
            gameState = "GameOver"
            love.audio.play(love.audio.newSource("audio/gameOver.mp3", "static"))
        end
    elseif (gameState == "RoundTransition") then
        waitTimer = waitTimer - dt
        if (waitTimer <= 0) then
            startNewRound()
        end
    elseif (gameState == "GameOver") then
        for index, instance in ipairs(shapeSprites) do
            if (instance.innocent) then
                destroyShape(instance, index)
            end
        end
    end

    -- Update shape positions
    local positiveBoundaries = {}
    positiveBoundaries.x = WINDOW_WIDTH - SHAPE_SIZE
    positiveBoundaries.y = WINDOW_HEIGHT - SHAPE_SIZE

    for index, shape in ipairs(shapeSprites) do
        shape.x = shape.x + (shape.vx * dt)
        shape.y = shape.y + (shape.vy * dt)
        if (shape.x <= 0) then
            shape.x = 0
            shape.vx = -shape.vx
        elseif (shape.x >= positiveBoundaries.x) then
            shape.x = positiveBoundaries.x
            shape.vx = -shape.vx
        end

        if (shape.y <= 0) then
            shape.y = 0
            shape.vy = -shape.vy
        elseif (shape.y >= positiveBoundaries.y) then
            shape.y = positiveBoundaries.y
            shape.vy = -shape.vy
        end

        if (not shape.innocent) then
            badSquares = badSquares + 1
        end
    end

    -- Update particle positions
    positiveBoundaries.x = WINDOW_WIDTH
    positiveBoundaries.y = WINDOW_HEIGHT

    for index, shape in ipairs(particleSprites) do
        shape.x = shape.x + (shape.vx * dt)
        shape.y = shape.y + (shape.vy * dt)
        if (shape.x <= -PARTICLE_SIZE) or (shape.x >= positiveBoundaries.x) or (shape.y <= -PARTICLE_SIZE) or (shape.y >= positiveBoundaries.y) then
            table.remove(particleSprites, index)
        end
    end

    if (badSquares <= 0 and gameState == "InRound") then
        gameState = "RoundTransition"
        waitTimer = 3
    end
end

function love.draw()
    -- Draw the shapes
    for index, shape in ipairs(shapeSprites) do
        local brightness = 1
        if (pointCollision(love.mouse.getX(), love.mouse.getY(), shape)) then
            brightness = 0.75
        end

        if (shape.innocent) then
            love.graphics.setColor(0, brightness, 0, 1)
        else
            love.graphics.setColor(brightness, 0, 0, 1)
        end

        love.graphics.rectangle("fill", shape.x, shape.y, shape.width, shape.height)

    end

    for index, shape in ipairs(particleSprites) do
        -- Draw particles
        if (shape.innocent) then
            love.graphics.setColor(0, 1, 0, 1)
        else
            love.graphics.setColor(1, 0, 0, 1)
        end

        love.graphics.rectangle("fill", shape.x, shape.y, PARTICLE_SIZE, PARTICLE_SIZE)
    end

    -- Draw text HUD
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Shoot the red squares", 0, 0, WINDOW_WIDTH, "left")
    love.graphics.printf("Spare the green squares", 0, 16, WINDOW_WIDTH, "left")
    love.graphics.printf("Press esc to close the window.", 0, WINDOW_HEIGHT - 14, WINDOW_WIDTH, "left")
    love.graphics.printf("Round " .. currentRound, 0, 0, WINDOW_WIDTH, "right")
    if (gameState == "InRound") then
        love.graphics.printf("Time: " .. math.ceil(roundTimer), 0, 16, WINDOW_WIDTH, "right")
    elseif (gameState == "RoundTransition") then
        love.graphics.printf("Starting next round in " .. math.ceil(waitTimer), 0, 16, WINDOW_WIDTH, "right")
    elseif (gameState == "GameOver") then
        love.graphics.printf("Game over", 0, 16, WINDOW_WIDTH, "right")
        love.graphics.printf("Game Over", 0, (WINDOW_HEIGHT / 2) - 16, WINDOW_WIDTH / 2, "center", 0, 2, 2)
        love.graphics.printf("Press enter/return to play again.", 0, WINDOW_HEIGHT / 2 + 16, WINDOW_WIDTH, "center")
    end
end

function love.mousepressed(x, y)
    for index, instance in ipairs(shapeSprites) do
        if (gameState == "InRound" and pointCollision(x, y, instance)) then
            if (instance.innocent) then
                gameState = "GameOver"
                love.audio.play(love.audio.newSource("audio/gameOver.mp3", "static"))
            end
            destroyShape(instance, index)
            love.audio.play(love.audio.newSource("audio/gunShot.mp3", "static"))
        end
    end
end

function love.keypressed(key)
    if (key == "return" and gameState == "GameOver") then
        shapeSprites = {}
        particleSprites = {}
        currentRound = 0
        startNewRound()
    elseif (key == "escape") then
        love.event.quit()
    end
end

-- Custom functions

function createNewShape()
    -- Create a new shape
    local newShape = {}
    newShape.x = math.random(0, (WINDOW_WIDTH - SHAPE_SIZE))
    newShape.y = math.random(0, (WINDOW_HEIGHT - SHAPE_SIZE))
    newShape.vx = math.random(-128, 128)
    newShape.vy = math.random(-128, 128)
    newShape.width = SHAPE_SIZE
    newShape.height = SHAPE_SIZE
    newShape.innocent = math.random(1, 10) <= 2

    table.insert(shapeSprites, newShape)
    print("New shape created")
end

function destroyShape(shape, index)
    -- Destroy shape
    for index = 1, 24, 1 do
        local newParticle = {}
        newParticle.x = shape.x + (shape.width / 2)
        newParticle.y = shape.y + (shape.height / 2)
        newParticle.vx = math.random(-480, 480)
        newParticle.vy = math.random(-480, 480)
        newParticle.innocent = shape.innocent 
        table.insert(particleSprites, newParticle)
    end

    table.remove(shapeSprites, index)
    love.audio.play(love.audio.newSource("audio/explosion.mp3", "static"))
end

function pointCollision(px, py, shape)
    -- Detect collision using AABB
    return (px >= shape.x) and (py >= shape.y) and (px <= shape.x + shape.width) and (py <= shape.y + shape.height)
end

function startNewRound()
    shapeSprites = {}
    particleSprites = {}
    currentRound = currentRound + 1
    roundTimer = 10 
    for index = 1, 8 + (currentRound * 2), 1 do
        createNewShape()
    end
    gameState = "InRound"
    love.audio.play(love.audio.newSource("audio/spawn.mp3", "static"))
end