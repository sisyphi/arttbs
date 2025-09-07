Helper = {}

function Helper.hex_to_rgba(hex)
    assert(type(hex) == 'string', 'Expected hex to be a string, but got ' .. type(hex))

    hex = hex:gsub('#', '')
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    local a = 1
    if #hex == 8 then
        a = tonumber(hex:sub(7, 8), 16) / 255
    end
    return r, g, b, a
end
