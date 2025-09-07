require('Vector2')

Action = {
    name = 'Default',
    dir = Vec2:new(0, 0),
    effects = {}
}

local function rotate(vec2, rot_dir)
    if rot_dir:equals(Vec2:new(0, -1)) then return vec2 end
    if rot_dir:equals(Vec2:new(1, 0)) then return vec2:invert():reflect() end
    if rot_dir:equals(Vec2:new(0, 1)) then return vec2:reflect() end
    if rot_dir:equals(Vec2:new(-1, 0)) then return vec2:invert() end
end

function Action:new(o)
    o = o or Action
    setmetatable(o, self)
    self.__index = self
    return o
end

function Action:execute(origin, rot_dir, grid)
    assert(
        type(origin) == 'table' and origin.__type == 'Vector2',
        'Expected origin to be Vector2, got ' .. type(origin)
    )

    assert(
        type(rot_dir) == 'table' and rot_dir.__type == 'Vector2',
        'Expected rot_dir to be Vector2, got ' .. type(rot_dir)
    )
    for idx = #self.effects, 1, -1 do
        local curr_eff = self.effects[idx]
        local grid_pos = origin:add(rotate(curr_eff.pos, rot_dir))

        if not grid:is_oobs(grid_pos) then
            local entity = grid.cells[grid_pos.y][grid_pos.x]

            if entity ~= nil then
                curr_eff:add_health(entity, curr_eff.health)

                local rot_move_dir = rotate(curr_eff.move_dir, rot_dir)
                local end_move_pos = entity.pos:add(rot_move_dir)
                if not grid:is_oobs(end_move_pos) and grid:get_cell(end_move_pos) == nil then
                    curr_eff:move(entity, rot_move_dir)
                end
            end
        end
    end
end
