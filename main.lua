--[[
    Author: Nicholas Leong
    GitHub: https://github.com/nick-leong
]]

push = require 'dependencies/push'
Class = require 'dependencies/class'
require 'classes/Cell'

-- Window size
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 800

-- Virtual Size used by Push
VIRTUAL_WIDTH = 200
VIRTUAL_HEIGHT = 200


--[[
    Load function for initialization of Gamestate, fonts, window, cells
]]
function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle("Conway's Game of Life")

    -- set RNG seed for usage of RNG in cell creation state if wanted
    math.randomseed(os.time())

    -- initialize retro fonts
    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    largeFont = love.graphics.newFont('fonts/font.ttf', 16)
    scoreFont = love.graphics.newFont('fonts/font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- Setup screen with Virtual Width as 1/4 of window dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- Initialize Cells
    cells = {}

    for i=1,VIRTUAL_HEIGHT do
        cells[i] = {}

        for j=1,VIRTUAL_WIDTH do

            cells[i][j] = Cell(i,j, 0)

        end

    end

    -- Initial meta info state is off
    -- Turning this on will tell draw function to display FPS, and state info
    showMetaInfo = false

    -- Initial gameState is paused (Alternates between play and pause) 
    -- [play - true; pause - false]
    gameState = false
end

--[[
    Resize Window
]]
function love.resize(w, h)
    push:resize(w, h)
end


--[[
    Updates the current game board at a rate of 60FPS
    Only updates cell states every 1/2 second

    Also allows the update of Cell states based on mouse click, if the gameState is paused (gameState = false)
]]
time_count = 0
update_rate = 30
function love.update(dt)

    love.timer.sleep(1/60 - dt)
    time_count = time_count + 1

    if gameState then
        if time_count % update_rate == 0 then
            updateAllCells()
            time_count = 0
        end
    elseif gameState == false then
        if love.mouse.isDown(1) then
            local mouseX, mouseY = love.mouse.getPosition()
            local xCell = math.floor(mouseX / 4)
            local yCell = math.floor(mouseY / 4)
            cells[xCell][yCell].state = 1
        end
    end

end

--[[
    Updates all cells
    Stage 1: Change nextState field in Cell objects in Cell Matrix
    Stage 2: Overwrite state field with nextState field
]]
function updateAllCells()
    for i=1,VIRTUAL_HEIGHT do
        for j=1,VIRTUAL_WIDTH do
            cells[i][j]:update(dt)
        end
    end

    for i=1,VIRTUAL_HEIGHT do
        for j=1,VIRTUAL_WIDTH do
            cells[i][j].state = cells[i][j].nextState
        end
    end

end

--[[
    Clears all cells
]]
function clearCells()
    for i=1,VIRTUAL_HEIGHT do
        for j=1,VIRTUAL_WIDTH do
            cells[i][j].state = 0
        end
    end
end

--[[
    Detects keypress event
    Space will toggle play and pause gameStates
    Right, aka Right Arrow Key, will advance the cells' states by 1 stage
    Up, aka Up Arrow Key, will increase the update rate
    Down, aka Down Arrow Key, will decrease the update rate
    Back tick, aka `, will toggle meta info state
    Escape will exit game
]]
function love.keypressed(key)
    -- Exit
    if key == 'escape' then

        love.event.quit()

    -- Toggle gameState
    elseif key == 'space' then

        gameState = not gameState

    -- advance by 1 stage
    elseif key == 'right' then

        if gameState == false then
            updateAllCells()
        end

    elseif key == 'up' then

        if update_rate > 3 then
            update_rate = update_rate - 3
        end

    elseif key == 'down' then

        if update_rate < 60 then
            update_rate = update_rate + 3
        end

    elseif key == 'delete' or key == 'backspace' then

        clearCells()

    elseif key == '`' then

        showMetaInfo = not showMetaInfo

    end
end

--[[
    Draws cells
    Display meta information if showMetaInfo is in true state
]]
function love.draw()
    
    -- begin drawing with push, in our virtual resolution
    push:apply('start')

    love.graphics.clear(10, 10, 10, 255)

    for i=1,VIRTUAL_HEIGHT do
        for j=1,VIRTUAL_WIDTH do
            if cells[i][j].state == 1 then
                love.graphics.setColor(200, 200, 200, 255)
                cells[i][j]:render()
            end
        end
    end

    -- display FPS for debugging; simply comment out to remove
    if showMetaInfo then
        displayMeta()
    end

    -- end our drawing to push
    push:apply('end')
end

--[[
    Renders the current FPS.
]]
function displayMeta()

    -- display FPS
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)

    -- displays neighbor count for the mouse hovered cell
    local mouseX, mouseY = love.mouse.getPosition()
    local xCell = math.floor(mouseX / 4)
    local yCell = math.floor(mouseY / 4)

    if (xCell > 200 or xCell < 1) or (yCell > 200 or yCell < 1) then
        love.graphics.print('N#: ?', 10, 20)
    else
        love.graphics.print('N#: ' .. tostring(cells[xCell][yCell]:getNeighborCount()), 10, 20)
    end

    -- displays update rate of cell states
    love.graphics.print('Rate: ' .. string.format("%.2f", tostring(update_rate/60)) .. 's', 10, 30)

end