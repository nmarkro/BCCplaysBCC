local parser = {}

local data = require("data")
local ram = require("RAM")

-- 0x0200483E text box length
-- 0x02004840 points to text box
-- 0x020049C8 text box
-- 0x02004846 bool for text fully drawn(?)

-- read from 0x0200EC0
-- each line has a max of 0x12 characters, 3 total lines
-- char & 0x8000 = terminator
-- char & 0x1000 = red (left side)
-- char & 0x2000 = blue (right side)

-- if you want to log what slots are used each turn
-- left player draws start at 0x0200B952
-- right player draws start at 0x0200B95A
-- each byte is a slot index (4 bytes total)
-- first byte will always be 0 (since you always draw the navi chip)

-- turn # is at 0x0200B82C

function parser.parse_textbox()
    if memory.read_u16_le(0x02004EC8) == 0x0000 then
        return ""
    end

    local str = ""

    for i = 0, 2 do
        local line = ""
        local last_flag = nil
        for j = 0, 17 do
            local chr_byte = memory.read_u16_le(0x02004EC8 + ((i * 0x12 + j) * 2))
            local flag = bit.rshift(bit.band(chr_byte, 0xF000), 0x0C)

            if bit.band(flag, 0x08) == 0x08 then
                -- terminator
                if flag ~= last_flag or j == 17 then
                    if last_flag == 0x01 then
                        line = line .. "[r]"
                    elseif last_flag == 0x02 then
                        line = line .. "[b]"
                    end
                end
                break
            elseif bit.band(flag, 0x01) == 0x01 then
                -- red text (left player)
                if flag ~= last_flag then
                    line = line .. "[r]"
                end
            elseif bit.band(flag, 0x02) == 0x02 then
                -- blue text (right player)
                if flag ~= last_flag then
                    line = line .. "[b]"
                end
            elseif flag == 0x00 then
                -- normal text
                if flag ~= last_flag or j == 17 then
                    if last_flag == 0x01 then
                        line = line .. "[r]"
                    elseif last_flag == 0x02 then
                        line = line .. "[b]"
                    end
                end
            end

            line = line .. data.lookup_tbl[bit.band(chr_byte, 0x0FFF)]
            last_flag = flag
        end
        if line ~= "" then
            str = str .. line
            if i < 2 then
                str = str .. " "
            end
        end
    end

    return str
end

function parser.log_draws()
    local txt = ""
    for i = 0, 1 do
        local line = "Player " .. (i + 1) .. " draw slots: "
        for j = 1, 3 do
            line = line .. memory.readbyte(0x0200B952 + (8 * i) + j) .. " "
        end
        txt = txt .. line .. "\n"
    end
    return txt
end

local prev_text = nil
local last_turn = nil

function parser.run()
    if ram.get_tournament_substate() == 0x05 then
        local turn = memory.readbyte(0x0200B82C)
        if turn ~= 0 and turn ~= last_turn then
            console.log("\n" .. parser.log_draws())
        end
        last_turn = turn

        local text = parser.parse_textbox()
        if text ~= prev_text then
            prev_text = text
            if text ~= "" then
                console.log(text)
            end 
        end
    end
end

return parser