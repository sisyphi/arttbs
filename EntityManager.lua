EntityManager = {
    entities = {}
}
EntityManager.__type = 'EntityManager'

function EntityManager:new(o)
    o = o or EntityManager
    setmetatable(o, self)
    self.__index = self
    return o
end

function EntityManager:add_entity(ent)
    assert(type(ent) == 'table' and ent.__type == 'Entity', 'Expected ent to be Entity, but got ' .. type(ent))
    table.insert(self.entities, ent)
end

function EntityManager:clear_entities()
    for idx = #self.entities, 1, -1 do
        table.remove(self.entities, idx)
    end
end

function EntityManager:update_entities(width, height)
    for idx = #self.entities, 1, -1 do
        local curr_ent = self.entities[idx]
        if curr_ent.health <= 0 then
            table.remove(self.entities, idx)
        end
        curr_ent.render_pos = Vec2:new((curr_ent.pos.x - 1) * width, (curr_ent.pos.y - 1) * height)
    end
end

function EntityManager:draw(width, height)
    for idx = #self.entities, 1, -1 do
        local curr_ent = self.entities[idx]
        if curr_ent.category == 'player' then curr_ent:draw(width, height, '#4f8fba') end
        if curr_ent.category == 'enemy' then curr_ent:draw(width, height, '#da863e') end
    end
end
