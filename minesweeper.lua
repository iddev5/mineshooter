local Object = require "deps.classic"
local Minesweeper = Object:extend()

local rows = 9
local cols = 9
local size = 50
local bombs_count = 18

local Cell = Object:extend()

function Cell:new()
    self.opened = false
    self.bomb = false
    self.value = 0
end

function in_bounds(x, y) 
    return x > 0 and x <= cols and y > 0 and y <= rows
end

function Minesweeper:load() 
    self.first_click = true

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    local total_w = rows * size
    local total_h = cols * size

    self.origin_x = w/2 - size - total_w/2 
    self.origin_y = h/2 - size - total_h/2
end

function Minesweeper:generate_grid() 

    local cells = {}
    for i=1,rows do
        local row = {}
        for j=1,cols do
            table.insert(row, Cell())
        end
        table.insert(cells, row)
    end

    local mx, my = love.mouse.getPosition()
    local gy = math.floor(my / size)
    local gx = math.floor(mx / size)



    function gen_bomb()
        local pos_x = math.random(1, cols)
        local pos_y = math.random(1, rows)

        local abs_x = math.abs(pos_x - gx)
        local abs_y = math.abs(pos_y - gy)

        -- TODO: fix bomb spawning
        if abs_x <= 1 or abs_y <= 1 then
            gen_bomb()
        elseif cells[pos_y][pos_x].bomb then
            gen_bomb()
        else
            cells[pos_y][pos_x].bomb = true
        end
    end

    for i=1,bombs_count do
        gen_bomb()
    end

    for i=1,rows do
        for j=1,cols do
            for i1=i-1,i+1 do
                for j1=j-1,j+1 do
                    if i1 ~= i or j1 ~= j then


                        if (in_bounds(j1, i1)) then
                            local cell = cells[i1][j1]
                            if cell.bomb then
                                cells[i][j].value = cells[i][j].value + 1
                                
                            end

                        
                            
                        end

                       
                    end
                end
            end
        end
    end

    self.cells = cells
end

function Minesweeper:mousepressed(x, y, btn)
    if self.first_click then
        self.first_click = false
        self:generate_grid()
    end

    x = x - self.origin_x
    y = y - self.origin_y

    local grid_x = math.floor(x / size)
    local grid_y = math.floor(y / size)
    local cell_x = grid_x * size
    local cell_y = grid_y * size

    if in_bounds(grid_x, grid_y) then
        local cell = self.cells[grid_y][grid_x]
        if cell.bomb then
            mode = "bh"
        else
            cell.opened = true
        end
    end

end

function Minesweeper:dbg_print_grid()

    for i=1,rows do
        for j=1,cols do
            io.write(tostring(self.cells[j][i].opened), ' ')
        end
        print()
    end

end

function Minesweeper:update(dt) 
    
end

function Minesweeper:draw()

    if self.cells ~= nil then
        for i=1,rows do
            for j=1,cols do
                local cell = self.cells[i][j]

                if cell.opened then
                    love.graphics.setColor(1, 0, 0)
                else
                    love.graphics.setColor(0, 1, 0)
                end

                local pos_x = self.origin_x + size * j
                local pos_y = self.origin_y + size * i

                love.graphics.rectangle("line", 
                    pos_x, pos_y,
                    size - 5, size - 5)
                
                local radius = (size - 10) / 2
                if cell.bomb then
                    love.graphics.print("bomb", pos_x, pos_y);
                    -- love.graphics.circle("line",
                        -- pos_x + radius + 2.5, pos_y + radius + 2.5, radius)
                else
                    love.graphics.print(tostring(cell.value), pos_x, pos_y)
                end
            end
        end
    end
end


return Minesweeper