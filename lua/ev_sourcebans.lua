--[[
	ENABLE SOURCE BANS?
	true OR false
]]--

local SourceBansEnabled = false

--[[
	STOP EDITING AGAIN HERE
]]--

if ( SourceBansEnabled ) then

require( "sourcebans" )

--[[
	EDIT THE FOLLOWING INFO
]]--

sourcebans.SetConfig( "hostname", "127.0.0.1" )
sourcebans.SetConfig( "username", "root" )
sourcebans.SetConfig( "password", "" )
sourcebans.SetConfig( "database", "sourcebans" )
sourcebans.SetConfig( "dbprefix", "sb" )
sourcebans.SetConfig( "portnumb", 3306 )
sourcebans.SetConfig( "serverid", 1 )

--[[
	STOP EDITING HERE
]]--

sourcebans.Activate()

local function syncBans()
	local update = evolve.database:query("UPDATE evolve SET BanReason = NULL, BanEnd = NULL, BanAdmin = NULL")
	update:start()
	sourcebans.GetAllActiveBans( function( bans )
		for _, ban in ipairs( bans ) do			
			local steamid64 = util.SteamIDTo64(ban.SteamID)
			local admin
			if ban.AdminID == "STEAM_ID_UNKNOWN" then
				admin = 0
			else
				admin = util.SteamIDFrom64(ban.AdminID)
			end
			local query = evolve.database:query("UPDATE evolve SET BanReason = "..sql.SQLStr(ban.BanReason)..", BanEnd = "..ban.End..", BanAdmin = "..admin.." WHERE SteamID64 = "..steamid64.." LIMIT 1;")
			query:start()
		end
	end )
end
timer.Create( "EV_SourceBansSync", 300, 0, syncBans )
timer.Simple( 1, syncBans )

end
