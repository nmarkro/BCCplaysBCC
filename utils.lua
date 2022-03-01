local utils = {}

local data = require("data")

function utils.decode_navicode(code_name, code)
    local name_bytes = {0, 0, 0, 0}

    for i = 1, #code_name do
        local c = code_name:sub(i,i)
        name_bytes[i] = data.char_table[c]
    end

    code = code:gsub("-", "")

    local pass_bytes = {}
    for i = 1, 24 do
        pass_bytes[i] = data.pass_chars:find(code:sub(i,i)) - 1
    end

    local data = {}
    for i = 14, 0, -1 do
        local b = 0
        for j = 24, 1, -1 do
            local v = pass_bytes[j] + b * 36
            pass_bytes[j] = bit.rshift(v, 8)
            b = bit.band(v, 0xFF)
        end
        data[i] = b
    end

    for i = 0, 13 do
        data[i] = bit.bxor(data[i], name_bytes[bit.band(i, 3) + 1])
    end

    data = utils.shift(data, name_bytes[2] + name_bytes[4])

    for i = 0, 13 do
        data[i] = bit.bxor(data[i], name_bytes[bit.band(i, 3) + 1])
    end
    data = utils.unshift(data, name_bytes[1] + name_bytes[3])

    return data
end

function utils.shift(data, bits)
    local u = bit.band(bit.rshift(bits, 3), 0xF)
    local l = bit.band(bits, 0x7)

    local r = {}
    for i = 0, 13 do
        local magic1 = bit.band(bit.lshift(data[(i + u    ) % 14],      l) , 0xFF)
        local magic2 = bit.band(bit.rshift(data[(i + u + 1) % 14], (8 - l)), 0xFF)
        r[i] = bit.bor(magic1, magic2)
    end

    return r
end

function utils.unshift(data, bits)
    if bits ~= 0 then
        local data2 = {}
        for i = 0, 13 do
            data2[(i + 2) % 14] = data[i]
        end
        data = data2
    end
    return utils.shift(data, -1 * bits)
end

return utils