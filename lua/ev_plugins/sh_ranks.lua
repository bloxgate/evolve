/*-------------------------------------------------------------------------------------------------------------------------
	Ranking
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Ranking"
PLUGIN.Description = "Promote and demote people."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "rank"
PLUGIN.Usage = "<player> [rank]"
PLUGIN.Privileges = { "Ranking", "Rank modification" }

function PLUGIN:PerformRank(ply, pl, args)
	if ( #pl <= 1 ) then
		pl = pl[1]			
		if ( pl ) then
			if ( #args <= 1 ) then
				evolve:Notify( ply, evolve.colors.blue, pl.Nick, evolve.colors.white, " is ranked as ", evolve.colors.red, evolve.ranks[ pl.Rank ].Title, evolve.colors.white, "." )
			else
				if ( evolve.ranks[ args[2] ] ) then
					if ( !ply:IsValid() or ply:IsListenServerHost() or evolve.ranks[ args[2] ].Immunity < evolve.ranks[ ply:EV_GetRank() ].Immunity ) then
						if ( pl.Ply ) then
							if ( ply:EV_BetterThan( pl.Ply ) ) then
								pl.Ply:EV_SetRank( args[2] )
							else
								evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers2 )
								return
							end
						else
							evolve:GetProperty(pl.SteamID64, "Rank", "guest", function(rank)
								if ( tonumber( evolve.ranks[ ply:EV_GetRank() ].Immunity ) > tonumber( evolve.ranks[rank].Immunity ) ) then
									evolve:SetProperty( pl.SteamID64, "Rank", args[2] )
									evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has set the rank of ", evolve.colors.red, pl.Nick, evolve.colors.white, " to " .. evolve.ranks[ args[2] ].Title .. "." )
								else
									evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers2 )
								end
							end)
						end							
					else
						evolve:Notify( ply, evolve.colors.red, "You can't rank someone higher or equal to yourself!" )
					end
				else
					evolve:Notify( ply, evolve.colors.red, "Unknown rank specified." )
				end
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( evolve:FindPlayer( args[1], ply, false, true ), true ), evolve.colors.white, "?" )
	end
end

function PLUGIN:Call( ply, args )
	if ( #args <= 1 or ply:EV_HasPrivilege( "Ranking" ) ) then
		local pl = {}
		if ( string.match( args[1] or "", "STEAM_[0-5]:[0-9]:[0-9]+" ) ) then
			local steamid64 = util.SteamIDTo64(args[1])
			if ( steamid64 ) then
				local p = evolve:GetBySteamID64(steamid64)
				if ( p ) then
					pl = { { SteamID64 = steamid64, Nick = p:Nick(), Rank = p:EV_GetRank(), Ply = p } }
					self:PerformRank(ply, pl, args)
				else
					evolve:GetProperty(steamid64, "Nick", nil, function(nick)
						evolve:GetProperty(steamid64, "Rank", "guest", function(rank)
							pl = { { SteamID64 = steamid64, Nick = nick, Rank = rank } }
							self:PerformRank(ply, pl, args)
						end)
					end)
				end
			end
		else
			for _, p in ipairs( evolve:FindPlayer( args[1], ply, false, true ) ) do
				table.insert( pl, { SteamID64 = p:SteamID64(), Nick = p:Nick(), Rank = p:EV_GetRank(), Ply = p } )
			end
			self:PerformRank(ply, pl, args)
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "rank", players[1], arg )
	else		
		local ranks = {}
		for id, info in pairs( evolve.ranks ) do
			table.insert( ranks, { info.Title, id, Immunity = info.Immunity } )
		end
		table.SortByMember( ranks, "Immunity", function( a, b ) return a > b end )
		
		return "Rank", evolve.category.administration, ranks
	end
end

evolve:RegisterPlugin( PLUGIN )