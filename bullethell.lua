local Object = require "deps.classic"

local BulletHell = Object:extend()

local speed = 250
local bullet_speed = 450
local size = 50
local enemy_timer_begin = 0.5
local enemy_speed = 325

local Bullet = Object:extend()

function Bullet:new(x, y, dir)
    self.x = x
    self.y = y
    self.dir = dir
end

function Bullet:check_collision(entity)
    if (self.x >= entity.x) and (self.x <= entity.x + entity.size) and (self.y >= entity.y) and (self.y <= entity.y + entity.size) then
        return true
    end
    return false
end

function Bullet:update(dt, entities)
    -- TODO: check for out of screen bounds
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    if (self.x > w or self.x < 0) and (self.y > h or self.y < 0) then
        return false
    end

    self.x = self.x + bullet_speed * math.cos(self.dir) * dt
    self.y = self.y + bullet_speed * math.sin(self.dir) * dt

    for idx, ent in ipairs(entities) do
        if self:check_collision(ent) then
            table.remove(entities, idx)
            return false
        end
    end

    return true
end

function Bullet:draw()
    love.graphics.rectangle("fill", self.x, self.y, 10, 10)
end

local Enemy = Object:extend()

function Enemy:new(x, y)
    self.x = x
    self.y = y
    self.size = 40
    self.range = 200
    self.bullets = {}
end

function Enemy:update(dt, bh)
    local diff_x = bh.pos_x - self.x
    local diff_y = bh.pos_y - self.y
    local dist = math.sqrt(diff_x * diff_x + diff_y * diff_y)

    local angle = math.atan2(diff_y, diff_x)
    if dist >= self.range then
        self.x = self.x + math.cos(angle) * enemy_speed * dt
        self.y = self.y + math.sin(angle) * enemy_speed * dt
    else 
        table.insert(self.bullets, Bullet(self.x, self.y, angle))
    end

    for idx, blt in ipairs(self.bullets) do
        blt:update(dt, {})
    end
end

function Enemy:draw()
    love.graphics.rectangle("line", self.x, self.y, self.size, self.size)

    for _, blt in ipairs(self.bullets) do
        blt:draw()
    end
end

function BulletHell:load()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    self.pos_x = w/2 - size/2
    self.pos_y = h/2 - size/2

    self.bullets = {}
    self.enemies = {}

    self.enemies_count = 0
    self.enemy_timer = enemy_timer_begin;
end

function BulletHell:mousepressed(x, y, btn)
    local dir_rot = math.atan2(y - self.pos_y, x - self.pos_x)
    table.insert(self.bullets, Bullet(self.pos_x + size/2, self.pos_y + size/2, dir_rot))
end

function BulletHell:get_max_enemies()
    return 20
end

function BulletHell:spawn_enemy()
    local w = love.graphics.getWidth()
    local pos_y = math.random(0, love.graphics.getHeight())
    local side = math.random(0, 1)
    if side > 0.5 then
        table.insert(self.enemies, Enemy(w + 50, pos_y))
    else
        table.insert(self.enemies, Enemy(-50, pos_y))
    end
end

function BulletHell:update(dt)
    if love.keyboard.isDown("w") then
        self.pos_y = self.pos_y -  speed * dt
    elseif love.keyboard.isDown("s") then
        self.pos_y = self.pos_y + speed * dt
    elseif love.keyboard.isDown("a") then
        self.pos_x = self.pos_x - speed * dt
    elseif love.keyboard.isDown("d") then
        self.pos_x = self.pos_x + speed * dt
    end

    self.enemy_timer = self.enemy_timer - dt
    if self.enemy_timer <= 0 then
        self:spawn_enemy()
        self.enemy_timer = enemy_timer_begin
    end

    for idx, blt in ipairs(self.bullets) do
        if blt:update(dt, self.enemies) == false then
            table.remove(self.bullets, idx)
        end
    end

    for _, enm in ipairs(self.enemies) do
        enm:update(dt, self)
    end
end

function BulletHell:draw()
    love.graphics.rectangle("line", self.pos_x, self.pos_y, size, size)

    for _, blt in ipairs(self.bullets) do
        blt:draw()
    end

    for _, enm in ipairs(self.enemies) do
        enm:draw()
    end
end

return BulletHell