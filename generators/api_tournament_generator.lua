local base_generator = require("generators/base_tournament_generator")
local json = require("libs/json")
local utils = require("utils")

-- this is just an example of using Bizhawk's comm library to call an external API to get decks and record results
-- comm doesn't allow you to edit the header so authentication needs to be handled by the URL or body unfortunatly
-- comm has the ability to use sockets instead of http but i have no idea how to use that
local api_tournament_generator = {}

api_tournament_generator.new = function(api_url, secret)
    local self = base_generator.new()

    local api_url = api_url
    local secret = secret
    local token = nil

    -- ideally users interacting with a twitch extension during the stream would be prioritized in getting chosen for tournaments
    -- calling "purge" would happen at the start of the stream to clear this
    local function purge()
        if check_token() ~= nil then
	        comm.httpGet(api_url .. "Tournament/Purge?token=" .. token.access_token)
            return true
        end

        return false
    end

    local function get_token()
        local response = json.decode(comm.httpPost(api_url .. "Token", secret))

        if response ~= nil then
            local tyear, tmonth, tday, thour, tmin, tsec = response.expires_in:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")

            local newToken = {
                access_token = response.access_token,
                expires_in = os.time({year=tyear, month=tmonth, day=tday, hour=thour, min=tmin, sec=tsec})
            }
        
            return newToken
        end

        return nil
    end

    local function check_token()
        if token == {} or token == nil then
            token = get_token()
        else
            local d = os.date("*t")
            local t = os.time(d)
            if t > token.expires_in then
                token = get_token()
        end

        return token
    end

    function self.generate(size)
        local new_tournament = {}
	
        if check_token() ~= nil then
            local response = json.decode(comm.httpGet(api_url .. 'Tournament?size=' .. size .. "&token=" .. token.access_token))
            
            for i = 1, #response do
                local entry = response[i]
                entry.navi = utils.decode_navicode(entry.deck.name, entry.deck.code)
                
                table.insert(new_tournament, entry)
            end
        
            return new_tournament
        end

        return nil
    end

    function self.record_results(results)
	    if check_token() ~= nil else
	        comm.httpPost(api_url .. "Tournament/match" .. "?token=" .. token["access_token"], json.encode(results))
            return true
        end

        return false
    end

    purge()
    return self
end

return api_tournament_generator