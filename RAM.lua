local ram = {}

local data = require("data")

-- Addresses
ram.addr = {}

ram.addr.fastforward = 0x020051A4
ram.addr.state = 0x020070F0
ram.addr.substate = 0x020070F1
ram.addr.tournament_state = 0x0200B78C
ram.addr.tournament_substate = 0x0200B78D
ram.addr.tournament_block = 0x0200B7A0

ram.addr.name_interrupts = { 0x0801EF32, 0x0801EFC6 }
ram.addr.music_interrupt = 0x0804A2DE

ram.addr.background = 0x0200B81A

ram.addr.navi_registration_table = 0x0200790C

ram.addr.left_navi_index = 0x0200B824
ram.addr.left_player_registration_index = 0x0200B7BC
ram.addr.left_player_name = ram.addr.navi_registration_table + (0x1C * 0x7E) + 14
ram.addr.left_player_mugshot = 0x0200B7B0
ram.addr.left_player_registration_enabler = ram.addr.navi_registration_table + (0x1C * 0x7E) + 25

ram.addr.right_navi_index = 0x0200B826
ram.addr.right_player_registration_index = 0x0200B7BE
ram.addr.right_player_name = ram.addr.navi_registration_table + (0x1C * 0x7F) + 14
ram.addr.right_player_mugshot = 0x0200B7B2
ram.addr.right_player_registration_enabler = ram.addr.navi_registration_table + (0x1C * 0x7F) + 25

ram.addr.winner = 0x0200B814

function ram.is_fastforward()
    return memory.read_u8(ram.addr.fastforward)
end

function ram.get_state()
    return memory.read_u8(ram.addr.state)
end
function ram.set_state(value)
    memory.write_u8(ram.addr.state, value)
end

function ram.get_substate()
    return memory.read_u8(ram.addr.substate)
end
function ram.set_substate(value)
    memory.write_u8(ram.addr.substate, value)
end

function ram.get_tournament_state()
    return memory.read_u8(ram.addr.tournament_state)
end
function ram.set_tournament_state(value)
    memory.write_u8(ram.addr.tournament_state, value)
end

function ram.get_tournament_substate()
    return memory.read_u8(ram.addr.tournament_substate)
end
function ram.set_tournament_substate(value)
    memory.write_u8(ram.addr.tournament_substate, value)
end

function ram.get_tournament_block()
    return memory.read_u8(ram.addr.tournament_block)
end
function ram.set_tournament_block(value)
    memory.write_u8(ram.addr.tournament_block, value)
end

function ram.get_background()
    return memory.read_u8(ram.addr.background)
end
function ram.set_background(value)
    memory.write_u8(ram.addr.background, value)
end

function ram.get_left_navi_index()
    return memory.readbyte(ram.addr.left_navi_index)
end
function ram.get_right_navi_index()
    return memory.readbyte(ram.addr.right_navi_index)
end

function ram.did_left_win()
    return bit.rshift(memory.readbyte(ram.addr.winner), 4) == 1
end

function ram.write_string(address, s, terminate, maxlen)
    local i = 1
    while (i <= s:len() and i <= maxlen) do
        local found = false
        for key in pairs(data.tbl) do
            if not found then
                if s:sub(i, i + key:len() - 1) == key then
                    memory.write_u16_le(address, data.tbl[key])
                    address = address + 2
                    i = i + key:len()
                    found = true
                end
            end
        end
        if not found then
            return false
        end
    end
    if terminate then
        memory.write_u16_le(address, 0x8000)
        address = address + 2
    end
    return true
end

function ram.get_navi_registration_address(navi_index)
    return ram.addr.navi_registration_table + (0x1C * navi_index)
end

-- use slot 126 for left name
function ram.write_left_name(name, navi_chip)
    local slot = 0x7E
    local base_addr = ram.get_navi_registration_address(slot)
    -- Set left player's name to registration #126
    memory.write_u16_le(ram.addr.left_player_registration_index, 0x2000 + slot)
    -- Write registration #126 name (11 chars)
    ram.write_string(base_addr + 0x0E, name, true, 11)
    -- Enable registration #126
    local flag = memory.readbyte(base_addr + 0x19)
    flag = bit.bor(flag, 0x40)
    memory.writebyte(base_addr + 0x19, flag)

    -- Set mugshot 1
    memory.write_u16_le(ram.addr.left_player_mugshot, navi_chip - 0xC8)
end

-- use slot 127 for right name
function ram.write_right_name(name, navi_chip)
    local slot = 0x7F
    local base_addr = ram.get_navi_registration_address(slot)
    -- Set right player's name to registration #127
    memory.write_u16_le(ram.addr.right_player_registration_index, 0x2000 + slot)
    -- Write registration #127 name (11 chars)
    ram.write_string(base_addr + 0x0E, name, true, 11)
    -- Enable registration #127
    local flag = memory.readbyte(base_addr + 0x19)
    flag = bit.bor(flag, 0x40)
    memory.writebyte(base_addr + 0x19, flag)

    -- Set mugshot 2
    memory.write_u16_le(ram.addr.right_player_mugshot, navi_chip - 0xC8)
end

function ram.write_navis(tournament)
    -- write decks starting at slot #1
    for i = 1, #tournament do
        local navi_addr = ram.get_navi_registration_address(i)
        local player = tournament[i]

        ram.write_navi_registration(navi_addr, player)
    end
end

function ram.write_navi_registration(address, player)
    memory.writebyte(address + 0x00, player.navi[0])                -- Operator
    memory.writebyte(address + 0x01, player.navi[1])                -- Base Navi
    for j = 1, 12 do                                                -- Chips
        memory.writebyte(address + 0x01 + j, player.navi[j])
    end
    ram.write_string(address + 0x0E,  player.deck.name, true, 4)
    memory.writebyte(address + 0x17, 0x80)                          -- ???
    memory.writebyte(address + 0x18, player.navi[13])               -- Code type ???
    memory.writebyte(address + 0x19, 1)                             -- Enabler ???
end

return ram