function love.load()
    math.randomseed(os.time())
    -- Init Constants
    WINDOW_MODE = {
        WIDTH = 480,
        HEIGHT = 360,
    }
    -- Init global variables
    reactionTime = {
        recent = nil,
        best = nil,
        average = nil,
        list = {},
    }
    recordingTimer = math.random(2, 5)
    print("Global Variables Initialized")
    -- Init game window
    love.window.setMode(WINDOW_MODE.WIDTH, WINDOW_MODE.HEIGHT)
    love.window.setTitle("Reaction Test Game")
    love.window.setIcon(love.image.newImageData("iconRTG.png"))
    print("Game Window Initialized")
end

function love.update(dt)
    -- Decrement timer.
    recordingTimer = recordingTimer - dt
    -- Calculate average reaction time.
    local total = 0
    for i = 1, #reactionTime.list do
        total = total + reactionTime.list[i]
    end
    if (#reactionTime.list > 0) then
        reactionTime.average = total / #reactionTime.list
    else
        reactionTime.average = 0
    end
end

function love.draw()
    love.graphics.printf("Reaction Test Game", 5, 340, WINDOW_MODE.WIDTH, "left")
    -- Draw variable data.
    love.graphics.printf("Click the screen when it turns green.", 0, 10, WINDOW_MODE.WIDTH, "center")
    love.graphics.printf("Recent reaction time (seconds): " .. string.format("%.2f", reactionTime.recent or 0), 0, 30, WINDOW_MODE.WIDTH, "center")
    love.graphics.printf("Best reaction time (seconds): " .. string.format("%.2f", reactionTime.best or 0), 0, 50, WINDOW_MODE.WIDTH, "center")
    love.graphics.printf("Average reaction time (seconds): " .. string.format("%.2f", reactionTime.average or 0), 0, 70, WINDOW_MODE.WIDTH, "center")
    -- Draw key shortcuts notes.
    love.graphics.printf("Press Enter/Return to reset data.", WINDOW_MODE.WIDTH - 260, WINDOW_MODE.HEIGHT - 40, 250, "right")
    love.graphics.printf("Press Escape to close the window.", WINDOW_MODE.WIDTH - 260, WINDOW_MODE.HEIGHT - 20, 250, "right")
    if (recordingTimer > 0) then -- Draw for awaiting state
        love.graphics.setBackgroundColor(1, 0, 0)
    else -- Draw for reaction state
        love.graphics.setBackgroundColor(0, 1, 0)
    end
end

function love.mousepressed(x, y, button)
    if (recordingTimer > 0) then
        -- Perform actions for improper input.
        love.audio.play(love.audio.newSource("audio/improperInput.mp3", "static"))
        print("Improper button input")
    else
        -- Perform actions for proper input.
        reactionTime.recent = math.abs(recordingTimer)
        if (reactionTime.best == nil or reactionTime.recent < reactionTime.best) then
            reactionTime.best = reactionTime.recent
            print("Best reaction time beat/set")
        else 
            print("Best reaction time not beat")
        end
        reactionTime.list[#reactionTime.list + 1] = reactionTime.recent
        love.audio.play(love.audio.newSource("audio/properInput.mp3", "static"))
        print("Proper button input")
    end
    recordingTimer = math.random(2, 5)
end

function love.keypressed(key)
    if (key == "return") then
        -- Reset data.
        reactionTime.recent = nil
        reactionTime.list = {}
        reactionTime.best = nil
        reactionTime.average = 0
        love.audio.play(love.audio.newSource("audio/dataReset.mp3", "static"))
        print("Data reset")
    elseif (key == "escape") then
        -- Close window.
        print("Close window")
        love.event.quit()
    end
end