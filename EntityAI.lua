EntityAI = {}
EntityAI.__type = 'EntityAI'

EntityAI.Pace = {
    steps = 0,
    max_steps = 0,
    move_dir = Vec2:new(0, 0),
}

function EntityAI.Pace:new(o)
    o = o or EntityAI.Pace
    setmetatable(o, self)
    self.__index = self
    return o
end

function EntityAI.Pace:decide(entity, grid)
    local move_pos = entity.pos:add(self.move_dir)

    if not grid:is_oobs(move_pos) and grid:get_cell(move_pos) == nil then
        self.steps = self.steps + 1
        entity:move(self.move_dir)
    end

    if self.steps == self.max_steps then
        self.move_dir = self.move_dir:reflect()
        self.steps = 0
    end
end
