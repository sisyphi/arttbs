Grid = {
    col_num = 1,
    row_num = 1,
    cells = {}
}

local ENTITY_SYMBOLS = {
    EMPTY = '_',
    ENTITY = 'E',
    ERROR = 'x',
}

function Grid:new(o)
    o = o or Grid
    setmetatable(o, self)
    self.__index = self
    return o
end

function Grid:update_entities(entities)
    for row = 1, self.row_num do
        self.cells[row] = {}
        for col = 1, self.col_num do
            self.cells[row][col] = nil

            for _, entity in ipairs(entities) do
                if entity.pos:equals(Vec2:new(col, row)) then
                    self.cells[row][col] = entity
                    goto continue
                end
            end
            ::continue::
        end
    end
end

function Grid:print_debug()
    for row = 1, self.row_num do
        for col = 1, self.col_num do
            if self.cells[row][col] == nil then
                io.write(ENTITY_SYMBOLS.EMPTY .. ' ')
            elseif self.cells[row][col].__type == 'Entity' then
                io.write(ENTITY_SYMBOLS.ENTITY .. ' ')
            else
                io.write(ENTITY_SYMBOLS.ERROR .. ' ')
            end
        end
        print('')
    end
    print('')
end

function Grid:draw(pos, width, height)
    assert(type(pos) == 'table' and pos.__type == 'Vector2', 'Expected pos to be Vector2, got ' .. type(pos))
    assert(type(width) == 'number', 'Expected width to be number, got ' .. type(width))
    assert(type(height) == 'number', 'Expected height to be number, got ' .. type(height))

    love.graphics.push('all')
    love.graphics.translate(pos.x, pos.y)
    for row = 1, self.row_num do
        for col = 1, self.col_num do
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle('fill', (col - 1) * width, (row - 1) * height, width, height)
        end
    end
    love.graphics.pop()
end

function Grid:is_oobs(pos, offset)
    assert(type(pos) == 'table' and pos.__type == 'Vector2', 'Expected pos to be Vector2, got ' .. type(pos))

    offset = offset or 0
    return
        (pos.x < (1 - offset) or pos.x > (self.col_num + offset)) or
        (pos.y < (1 - offset) or pos.y > (self.row_num + offset))
end

function Grid:get_cell(pos)
    assert(type(pos) == 'table' and pos.__type == 'Vector2', 'Expected pos to be Vector2, got ' .. type(pos))

    if self:is_oobs(pos) then
        return error('Position is out of bounds')
    end

    return self.cells[pos.y][pos.x]
end
