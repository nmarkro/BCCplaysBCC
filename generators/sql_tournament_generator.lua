local base_generator = require("generators/base_tournament_generator")
local utils = require('utils')

local sql_tournament_generator = {}

sql_tournament_generator.new = function(db_path)
    local self = base_generator.new()

    SQL.opendatabase(db_path)

    function self.generate()
        local query = SQL.readcommand("SELECT username, twitchName, code, codeName FROM navicodes ORDER BY RANDOM() LIMIT 16")
        
        local tournament = {}

        for i = 0, 15 do
            tournament[i + 1] = {
                navi = utils.decode_navicode(query["codeName " .. i], query["code " .. i]),
                deck = {
                    name = query["codeName " .. i],
                    code = query["code " .. i]
                },
                display_name = query["twitchName " .. i],
                username = query["username " .. i]
            }
        end

        return tournament
    end

    function self.record_results(results)
        SQL.writecommand("UPDATE navicodes SET wins = wins + 1, totalGames = totalGames + 1 WHERE username = \"" .. results.winner.username .. "\"")
        SQL.writecommand("UPDATE navicodes SET totalGames = totalGames + 1 WHERE username = \"" .. results.loser.username .. "\"")
    end

    return self
end

return sql_tournament_generator