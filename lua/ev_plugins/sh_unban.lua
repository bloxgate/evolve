/*-------------------------------------------------------------------------------------------------------------------------
	Unban a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Unban"
PLUGIN.Description = "Unban a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "unban"
PLUGIN.Usage = "<steamid|nick>"
PLUGIN.Privileges = { "Unban" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Unban" ) ) then
		if ( args[1] ) then
			local steamid
			
			if ( string.match( args[1], "STEAM_[0-5]:[0-9]:[0-9]+" ) ) then
				steamid = util.SteamIDTo64(args[1])
			else
				evolve:Notify( ply, evolve.colors.red, "Invalid SteamID!")
				return
			end
			
			if steamid then
				evolve:IsBanned( steamid, function(found, banned)
					if found then
						evolve:GetProperty(steamid, "Nick", "<Unknown>", function(nick)
							if banned then
								evolve:UnBan(steamid, ply:SteamID())
								evolve:Notify( evolve.colors.blue, ply:Nick(), color_white, " has unbanned ", evolve.colors.red, nick, color_white, "." )
							else
								evolve:Notify( ply, evolve.colors.red, nick .. " is not currently banned." )
							end
						end)
					else
						evolve:Notify( ply, evolve.colors.red, "No matching players found!" )
					end
				end)

			else
				evolve:Notify( ply, evolve.colors.red, "Invalid SteamID!")
			end
		else
			evolve:Notify( ply, evolve.colors.red, "You need to specify a SteamID!" )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

evolve:RegisterPlugin( PLUGIN )