require('Vector2')

Entity = {
    pos = Vec2:new(1, 1),
    move_dir = Vec2:new(0, 0),
    rot_dir = Vec2:new(0, -1),
    render_pos = Vec2:new(16, 16),
    health = 1,
    actions = {},
    ai = {},
}
Entity.__type = 'Entity'

local ROT_DIR = {
    VEC = {
        Vec2:new(0, -1),
        Vec2:new(1, 0),
        Vec2:new(0, 1),
        Vec2:new(-1, 0),
    },
    KEY = {
        NORTH = 1,
        EAST = 2,
        SOUTH = 3,
        WEST = 4,
    }
}

function Entity:new(o)
    o = o or Entity
    setmetatable(o, self)
    self.__index = self
    return o
end

function Entity:move(move_dir)
    self.pos.x = self.pos.x + move_dir.x
    self.pos.y = self.pos.y + move_dir.y
end

function Entity:rotate(rot_dir)
    local rot_idx = 0
    for idx, rd in ipairs(ROT_DIR.VEC) do
        if rd:equals(self.rot_dir) then
            rot_idx = idx
            goto continue
        end
    end
    ::continue::
    self.rot_dir = ROT_DIR.VEC[(rot_idx + rot_dir - 1) % #ROT_DIR.VEC + 1]
end

function Entity:take_turn(grid)
    if self.ai then
        self.ai:decide(self, grid)
    end
end

function Entity:add_health(val)
    self.health = self.health + val
end

function Entity:draw(width, height)
    love.graphics.push('all')
    love.graphics.translate(self.render_pos.x, self.render_pos.y)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, width, height)
    love.graphics.pop()
end

-- TODO::Determine collision effects, should be defined inside Entity creation
