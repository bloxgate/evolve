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
		time = time + os.clock() - pl.EV_LastPlaytimeSave
		evolve:Notify( ply, evolve.colors.blue, pl:GetProperty( "Nick", "User"), evolve.colors.white, " has spent ", evolve.colors.red, evolve:FormatTime( time ), evolve.colors.white, " on this server, with ", evolve.colors.red, evolve:FormatTime( pl:TimeConnected() ), evolve.colors.white, " this session." )
	else
		evolve:Notify( ply, evolve.colors.blue, pl:GetProperty( "Nick", "User" ), evolve.colors.white, " has spent ", evolve.colors.red, evolve:FormatTime( time ), evolve.colors.white, " on this server." )
	end
end

timer.Create( "EV_PlayTimeSave", 300, 0, function()
	for _, ply in ipairs( player.GetAll() ) do
        -- Check for bad PlayTime values and set them back to 0, usually only for catching new players spawning with negative values.
        if(ply:GetProperty( "PlayTime" ) < 0) then
          ply:SetProperty( "PlayTime", 0)
        end
        
        ply:SetProperty( "LastJoin", os.time() )
        clock = os.clock()
        last = ply.EV_LastPlaytimeSave or os.clock()
        
        -- When the clock flips negative/positive, we don't want large differences between the old clock value stored in last.
        if((clock < 0 && last > 0) || (clock > 0 && last < 0)) then 
          last = os.clock()
        end
        
        -- Set the PlayTime value to the absoulte difference in clock times.
        ply:SetProperty( "PlayTime", ply:GetProperty( "PlayTime" ) + 300 )
        ply.EV_LastPlaytimeSave = os.clock()
    end
    
    //evolve:CommitProperties()
end )

evolve:RegisterPlugin( PLUGIN )
