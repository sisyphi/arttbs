Timer = {
    max_value = 15,
    curr_value = 15,
    is_active = false,
}
Timer.__type = 'Timer'

function Timer:new(max_value)
    assert(
        type(max_value) == 'number',
        'Timer:new() requires one number max_value'
    )

    local o = {
        max_value = max_value,
        curr_value = max_value,
        is_active = false
    }

    setmetatable(o, self)
    self.__index = self
    return o
end

function Timer:add(amount)
    if amount < 0 then
        error('ERROR::Add amount less than zero')
    end

    self.curr_value = math.min(self.max_value, self.curr_value + amount)
end

function Timer:sub(amount)
    if amount < 0 then
        error('ERROR::Sub amount less than zero')
    end

    self.curr_value = math.max(0, self.curr_value - amount)
end

function Timer:reset()
    self.curr_value = self.max_value
end

function Timer:start()
    self.is_active = true
end

function Timer:isOutOfTime()
    return self.curr_value <= 0
end

function Timer:stop()
    self.is_active = false
end

function Timer:update(dt)
    if self.is_active then
        self.curr_value = self.curr_value - dt
    end

    if self.curr_value <= 0 then
        self.curr_value = 0
        self:stop()
    end
end
