/*-------------------------------------------------------------------------------------------------------------------------
	Retrieve playtime
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Playtime"
PLUGIN.Description = "View the playtime of someone or yourself."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "playtime"
PLUGIN.Usage = "[player]"

local time = 0

function PLUGIN:Call( ply, args )
	local uid, pl
	if ( string.match( args[1] or "", "STEAM_[0-5]:[0-9]:[0-9]+" ) ) then
		uid = evolve:UniqueIDBySteamID( args[1] )
		pl = player.GetByUniqueID( uid )
		sid64 = pl:SteamID64()
	else
		pl = evolve:FindPlayer( args[1], ply )
		
		if ( #pl > 1 ) then
			evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( pl, true ), evolve.colors.white, "?" )
			return
		elseif ( #pl == 0 ) then
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayersnoimmunity )
			return
		elseif ( !pl[1]:IsValid() ) then
			evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
			return
		else
			pl = pl[1]
			sid64 = pl:SteamID64()
		end
	end
	
	evolve:GetProperty(sid64, "Playtime", 0, function(timeData)
		time = timeData
	end)
	
	if ( pl and pl:IsValid() ) then
		time = time + os.clock() - 300
		evolve:Notify( ply, evolve.colors.blue, pl:GetProperty( "Nick", "User"), evolve.colors.white, " has spent ", evolve.colors.red, evolve:FormatTime( time ), evolve.colors.white, " on this server, with ", evolve.colors.red, evolve:FormatTime( pl:TimeConnected() ), evolve.colors.white, " this session." )
	else
		evolve:Notify( ply, evolve.colors.blue, pl:GetProperty( "Nick", "User" ), evolve.colors.white, " has spent ", evolve.colors.red, evolve:FormatTime( time ), evolve.colors.white, " on this server." )
	end
end

timer.Create("EV_PlayTimeSave", 300, 0, function()
	for i, ply in pairs( player.GetAll() ) do
		local ptime = 0
		evolve:GetProperty(ply:SteamID64(), "Playtime", 0, function(retdata) ptime = retdata end)
		evolve:SetProperty(ply:SteamID64(), "Playtime", ptime + 300)
		//ply.EV_LastPlaytimeSave = os.clock()
	end
end)

evolve:RegisterPlugin( PLUGIN )
