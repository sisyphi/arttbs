InputBuffer = {
    size = 1,
    queue = {}
}

function InputBuffer:new(o)
    o = o or EntityManager
    setmetatable(o, self)
    self.__index = self
    return o
end

function InputBuffer:push(key)
    if #self.queue >= self.size then
        table.remove(self.queue, 1)
    end
    table.insert(self.queue, #self.queue + 1, key)
end

function InputBuffer:pop()
    local input = self.queue[#self.queue]
    table.remove(self.queue, #self.queue)
    return input
end

function InputBuffer:flush()
    return table.move(self.queue, 1, #self.queue, 1, {})
end

function InputBuffer:clear()
    for idx in pairs(self.queue) do
        self.queue[idx] = nil
    end
end

function InputBuffer:print_debug()
    io.write('input_buffer: (')
    for idx, input in ipairs(self.queue) do
        if idx < #self.queue then
            io.write(input .. ', ')
        else
            io.write(input)
        end
    end
    print(')')
end
