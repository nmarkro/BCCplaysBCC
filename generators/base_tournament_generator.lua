-- generators handle making tournaments and recording the results of individual matches
-- abstract-ish class to show what common functions are expected from generators
local base_tournament_generator = {}

base_tournament_generator.new = function()
    local self = {}

    function self.generate()
        error("Not Implemented")
    end

    function self.record_results(results)
        error("Not Implemented")
    end

    return self
end

return base_tournament_generator