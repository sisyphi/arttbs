Tween = {
    active_tweens = {}
}

function Tween.linear(ratio) return ratio end

function Tween.quad_in(ratio) return ratio ^ 2 end

function Tween.quad_out(ratio) return ratio * (2 - ratio) end

function Tween.cubic_in(ratio) return ratio ^ 3 end

function Tween.quart_in(ratio) return ratio ^ 4 end

function Tween.quint_in(ratio) return ratio ^ 5 end

function Tween:new(o)
    o = o or Tween
    setmetatable(o, self)
    self.__index = self
    return o
end

function Tween:create(setter, from, to, duration, ease, callback)
    assert(type(setter) == 'function', 'Expected setter to be a function, but got ' .. type(setter))
    assert(type(from) == 'number', 'Expected from to be a number, but got ' .. type(from))
    assert(type(to) == 'number', 'Expected to to be a number, but got ' .. type(to))
    assert(type(duration) == 'number', 'Expected duration to be a number, but got ' .. type(duration))
    assert(type(ease) == 'function', 'Expected ease to be a function, but got ' .. type(ease))

    ease = ease or self.linear

    local t = 0
    local diff = to - from

    local update = function(dt)
        if t >= duration then
            setter(to)
            if callback then
                callback()
            end
            return true
        end

        setter(from + diff * ease(t / duration))
        t = t + dt
        return false
    end

    self.active_tweens[#self.active_tweens + 1] = update
end

function Tween:update(dt)
    for idx = #self.active_tweens, 1, -1 do
        if self.active_tweens[idx](dt) then
            table.remove(self.active_tweens, idx)
        end
    end
end
