local data = {}

data.char_table = {
    [' '] = 0x00,
    ['0'] = 0x01,
    ['1'] = 0x02,
    ['2'] = 0x03,
    ['3'] = 0x04,
    ['4'] = 0x05,
    ['5'] = 0x06,
    ['6'] = 0x07,
    ['7'] = 0x08,
    ['8'] = 0x09,
    ['9'] = 0x0A,
    ['■'] = 0x0A,
    ['ア'] = 0x0B,
    ['イ'] = 0x0C,
    ['ウ'] = 0x0D,
    ['エ'] = 0x0E,
    ['オ'] = 0x0F,
    ['カ'] = 0x10,
    ['キ'] = 0x11,
    ['ク'] = 0x12,
    ['ケ'] = 0x13,
    ['コ'] = 0x14,
    ['サ'] = 0x15,
    ['シ'] = 0x16,
    ['ス'] = 0x17,
    ['セ'] = 0x18,
    ['ソ'] = 0x19,
    ['タ'] = 0x1A,
    ['チ'] = 0x1B,
    ['ツ'] = 0x1C,
    ['テ'] = 0x1D,
    ['ト'] = 0x1E,
    ['ナ'] = 0x1F,
    ['ニ'] = 0x20,
    ['ヌ'] = 0x21,
    ['ネ'] = 0x22,
    ['ノ'] = 0x23,
    ['ハ'] = 0x24,
    ['ヒ'] = 0x25,
    ['フ'] = 0x26,
    ['ヘ'] = 0x27,
    ['ホ'] = 0x28,
    ['マ'] = 0x29,
    ['ミ'] = 0x2A,
    ['ム'] = 0x2B,
    ['メ'] = 0x2C,
    ['モ'] = 0x2D,
    ['ヤ'] = 0x2E,
    ['ユ'] = 0x2F,
    ['ヨ'] = 0x30,
    ['ラ'] = 0x31,
    ['リ'] = 0x32,
    ['ル'] = 0x33,
    ['レ'] = 0x34,
    ['ロ'] = 0x35,
    ['ワ'] = 0x36,
    ['ヲ'] = 0x39,
    ['ン'] = 0x3A,
    ['ガ'] = 0x3B,
    ['ギ'] = 0x3C,
    ['グ'] = 0x3D,
    ['ゲ'] = 0x3E,
    ['ゴ'] = 0x3F,
    ['ザ'] = 0x40,
    ['ジ'] = 0x41,
    ['ズ'] = 0x42,
    ['ゼ'] = 0x43,
    ['ゾ'] = 0x44,
    ['ダ'] = 0x45,
    ['ヂ'] = 0x46,
    ['ヅ'] = 0x47,
    ['デ'] = 0x48,
    ['ド'] = 0x49,
    ['バ'] = 0x4A,
    ['ビ'] = 0x4B,
    ['ブ'] = 0x4C,
    ['ベ'] = 0x4D,
    ['ボ'] = 0x4E,
    ['パ'] = 0x4F,
    ['ピ'] = 0x50,
    ['プ'] = 0x51,
    ['ペ'] = 0x52,
    ['ポ'] = 0x53,
    ['ァ'] = 0x54,
    ['ィ'] = 0x55,
    ['ゥ'] = 0x56,
    ['ェ'] = 0x57,
    ['ォ'] = 0x58,
    ['ッ'] = 0x59,
    ['ャ'] = 0x5A,
    ['ュ'] = 0x5B,
    ['ョ'] = 0x5C,
    ['A'] = 0x5E,
    ['B'] = 0x5F,
    ['C'] = 0x60,
    ['D'] = 0x61,
    ['E'] = 0x62,
    ['F'] = 0x63,
    ['G'] = 0x64,
    ['H'] = 0x65,
    ['I'] = 0x66,
    ['J'] = 0x67,
    ['K'] = 0x68,
    ['L'] = 0x69,
    ['M'] = 0x6A,
    ['N'] = 0x6B,
    ['O'] = 0x6C,
    ['P'] = 0x6D,
    ['Q'] = 0x6E,
    ['R'] = 0x6F,
    ['S'] = 0x70,
    ['T'] = 0x71,
    ['U'] = 0x72,
    ['V'] = 0x73,
    ['W'] = 0x74,
    ['X'] = 0x75,
    ['Y'] = 0x76,
    ['Z'] = 0x77,
    ['ー'] = 0x78,
    ['-'] = 0x78,
}
data.pass_chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function load_table(path)
    local tbl = {}
    local lookup_tbl = {}
    local count = 0
    local maxLen = 0

    -- Open the table file
    local file = assert(io.open(path, "r"))
    for line in file:lines() do
        -- Extract key and value from line
        local key = line:match("^([0-9A-F]+)=")
        local value = line:match("^[0-9A-F]+=(.+)")

        -- Ignore invalid lines
        if (key ~= nil and value ~= nil) then
            -- Reverse the byte string
            local yek = ""
            for b in key:gmatch("..") do
                yek = b .. yek
            end

            -- Increase max length
            local len = value:len()
            if (len > maxLen) then
                maxLen = len
            end

            -- Add the byte string to the table
            yek = tonumber(yek, 16)
            tbl[value] = yek
            lookup_tbl[yek] = value
            count = count + 1
        end
     end
    file:close()

    print("Loaded " .. count .. " chars from " .. path)
    return tbl, lookup_tbl, maxLen
end

data.tbl, data.lookup_tbl, data.tbl_maxLen = load_table("bcc-utf8.tbl")

return data
