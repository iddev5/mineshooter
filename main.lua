local Minesweeper = require "minesweeper"
local BulletHell = require "bullethell"

function love.load() 
    math.randomseed(os.time())

    ms = Minesweeper()
    bh = BulletHell()

    mode = "ms"
    ms:load()
    bh:load()
end

function love.mousepressed(x, y, btn)    
    if mode == "ms" then 
        ms:mousepressed(x, y, btn)
    else
        bh:mousepressed(x, y, btn)
    end
end

function love.update(dt)
    if love.keyboard.isDown("space") then
        mode = "bh"
    end

    if mode == "ms" then
        ms:update(dt)
    else
        bh:update(dt)
    end
end

function love.draw()
    if mode == "ms" then
        ms:draw()
    else
        bh:draw()
    end
end
