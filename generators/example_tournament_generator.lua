local base_generator = require("generators/base_tournament_generator")

local example_tournament_generator = {}

example_tournament_generator.new = function()
    local self = base_generator.new()

    function self.generate()
        local tournament = {}

        for i = 1, 16 do
            local navi = {}
            for j = 0, 13 do
                navi[j] = 1
            end
            navi[1] = 0xC8

            tournament[i] = {
                navi = navi,
                deck = {
                    name = "" .. i
                },
                display_name = "TEST " .. i
            }
        end

        return tournament
    end

    function self.record_results(results)
        return true
    end

    return self
end

return example_tournament_generator