--[[
    Author: Nicholas Leong
    GitHub: https://github.com/nick-leong
]]

Cell = Class{}

-- Initialization of Cell
function Cell:init(x, y, state)
    self.x = x
    self.y = y
    self.state = state
    self.nextState = 0
end

--[[
    Update function called by main's update function
    Gets alive neighbor count and then decides whether the current Cell lives or dies
]]
function Cell:update(dt)
    
    alive_neighbors = getNeighborCount(self)

    if self.state == 0 then
        if alive_neighbors == 3 then
            self.nextState = 1
        end
    else 
        if alive_neighbors > 3 or alive_neighbors < 2 then
            self.nextState = 0
        elseif alive_neighbors == 2 then
            self.nextState = 1
        end
    end
end

--[[
    Neighbor count function use of display Meta function
]]
function Cell:getNeighborCount()
    return getNeighborCount(self)
end

--[[
    Gets count of neighbors for given Cell
]]
function getNeighborCount(self)
    alive_neighbors = 0

    states = {-1, 0, 1}

    for a=1,3 do
        for b=1,3 do

            if states[a] == states[b] and states[a] == 0 then 
                goto continue 
            end

            xIndex = (self.x + states[a])
            yIndex = (self.y + states[b])

            if (xIndex) < 1 or (xIndex) > VIRTUAL_WIDTH then 
                goto continue 
            end
            if (yIndex) < 1 or (yIndex) > VIRTUAL_HEIGHT then 
                goto continue 
            end

            if cells[xIndex][yIndex].state > 0 then
                alive_neighbors = alive_neighbors + 1
            end

            ::continue::

        end
    end

    return alive_neighbors
end

--[[
    Render current Cell at location
]]
function Cell:render()
    love.graphics.rectangle('fill', self.x, self.y, 1, 1)
end