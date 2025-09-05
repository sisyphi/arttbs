require('Vector2')

-- Will have a position with respect to its origin, and its effects on that position (damage, knockback, status, etc.)
Effect = {
    pos = Vec2:new(0, 0),
    health = 0,
    move_dir = Vec2:new(0, -1)
}

function Effect:new(o)
    o = o or Effect
    setmetatable(o, self)
    self.__index = self
    return o
end

function Effect:add_health(entity, health)
    assert(type(entity) == 'table' and entity.__type == 'Entity', 'Expected entity to be Entity, got ' .. type(entity))

    entity:add_health(health)
end

function Effect:move(entity, move_dir)
    assert(type(entity) == 'table' and entity.__type == 'Entity', 'Expected entity to be Entity, got ' .. type(entity))

    entity:move(move_dir)
end
