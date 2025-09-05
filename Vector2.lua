Vec2 = {
    x = 0, y = 0,
}
Vec2.__type = 'Vector2'

function Vec2:new(x, y)
    assert(
        type(x) == 'number' and type(y) == 'number',
        'Vec2:new() requires two numbers (x, y)'
    )

    local o = { x = x, y = y }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Vec2:equals(vec2)
    return self.x == vec2.x and self.y == vec2.y
end

function Vec2:add(vec2)
    return Vec2:new(self.x + vec2.x, self.y + vec2.y)
end

function Vec2:mult(vec2)
    return Vec2:new(self.x * vec2.x, self.y * vec2.y)
end

function Vec2:reflect()
    return Vec2:new(-self.x, -self.y)
end

function Vec2:invert()
    return Vec2:new(self.y, self.x)
end

function Vec2:format()
    return '(' .. self.x .. ',' .. self.y .. ')'
end
