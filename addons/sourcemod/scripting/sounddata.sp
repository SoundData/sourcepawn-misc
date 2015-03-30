#pragma semicolon 1

#include <sourcemod>
#include <events>
#include <sounddata_send>
#include <functions>

public Plugin:myinfo =
{
  name = "Broadcast Plugin",
  author = "mproetsch",
  description = "Broadcast messages over network to Sounddata Client",
  version = "0.1.0.0",
  url = "https://github.com/orgs/SoundData/"
};

public OnPluginStart()
{
    // Global events for all classes
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("controlpoint_starttouch", Event_Controlpoint_Starttouch, EventHookMode_Pre);
	HookEvent("controlpoint_endtouch", Event_Controlpoint_Endtouch, EventHookMode_Pre);
    HookEvent("object_destroyed", Event_ObjectDestroyed, EventHookMode_Pre);
    HookEvent("ctf_flag_captured", Event_ctfFlagCaptured, EventHookMode_Pre);
    HookEvent("player_teleported", Event_PlayerTeleported, EventHookMode_Pre);

    // Class specific events
    HookEvent("sticky_jump", Event_StickyJump, EventHookMode_Pre); //Demoman Class
    HookEvent("rocket_jump", Event_RocketJump, EventHookMode_Pre); //Soldier Class
    HookEvent("player_ignited", Event_PlayerIgnited, EventHookMode_Pre); //Pyro Class
    HookEvent("player_extinguished", Event_PlayerExtinguished, EventHookMode_Pre); //Medic Class
    HookEvent("air_dash", Event_AirDash, EventHookMode_Pre); //Scout Class
    HookEvent("arrow_impact", Event_ArrowImpact, EventHookMode_Pre); //Sniper/Medic Class's 
    HookEvent("spy_pda_reset", Event_SpyPDAReset, EventHookMode_Pre); //Spy Class

	PrintToServer("Successfully loaded Broadcast Plugin");
	
}


public bool:OnClientConnect(client, String:rejectmsg[], maxlen)
{
	// NOTE: OnClientConnect is some sort of special event.
	// We don't need to bind it in the OnPluginStart() function, it gets called for us for free.
	decl String:buffer[512];
	decl String:cName[64];
	GetClientName(client, cName, 64);
	
	// Form the string we will send over the network
	Format(buffer, 512, "CLIENT_CONNECT##PlayerName##%s", cName);
	
	PrintToServer("[SM] %s connected || sending %s to clients", cName, buffer);
	TellClientAbout(buffer);
	return true;
}

public OnClientDisconnect(client)
{
	// NOTE: OnClientDisconnect is some sort of special event.
	// We don't need to bind it in the OnPluginStart() function, it gets called for us for free.
	decl String:buffer[512];
	decl String:cName[64];
	GetClientName(client, cName, 64);
	
	// Form the string we will send over the network
	Format(buffer, 512, "CLIENT_DISCONNECT##PlayerName##%s", cName);
	
	PrintToServer("[SM] %s disconnected || sending %s to clients", cName, buffer);
	TellClientAbout(buffer);
}

public Action:Event_WeaponFire(Handle:event, const String:name[], bool:dontBroadcast)
{
	// When a weapon is fired, get the username and weapon type
	decl String:cName[64];
	decl String:weapName[64];
	// Need to get userID from event, then get the client number from userID, then finally get the client name from the client number
	new userId = GetEventInt(event, "userid");
	new clientId = GetClientOfUserId(userId);
	GetClientName(clientId, cName, sizeof(cName));
	
	// Get weapon name from event
	GetEventString(event, "weapon", weapName, sizeof(weapName));
	
	// Form the string we will send over the network
	decl String:buffer[512];
	Format(buffer, 512, "WEAPON_FIRE##PlayerName##%s##WeaponName##%s", cName, weapName);
	PrintToServer("[SM] %s fired a %s || sending [%s] to client", cName, weapName, buffer);
	
	// Send
	TellClientAbout(buffer);
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
//Note: When a player dies
//Note: dominated, assister_dominated, revenge, assister_revenge, first_blood, and feign_death no longer exist in this event
//Name:   player_death
//Structure:  
//short   userid  user ID who died
//long    victim_entindex     
//long    inflictor_entindex  ent index of inflictor (a sentry, for example)
//short   attacker    user ID who killed
//string  weapon  weapon name killer used
//short   weaponid    ID of weapon killed used
//long    damagebits  bits of type of damage
//short   customkill  type of custom kill
//short   assister    user ID of assister
//string  weapon_logclassname     weapon name that should be printed on the log
//short   stun_flags  victim's stun flags at the moment of death
//short   death_flags     death flags.
//bool    silent_kill     
//short   playerpenetratecount    
//string  assister_fallback   contains a string to use if "assister" is -1
//short   kill_streak_total   Kill streak count (level)
//short   kill_streak_wep     Kill streak for killing weapon
//short   kill_streak_assist  Kill streak for assister count
//short   kill_streak_victim  Victims kill streak
//short   ducks_streaked  Duck streak increment from this kill
//short   duck_streak_total   Duck streak count for attacker
//short   duck_streak_assist  Duck streak count for assister
//short   duck_streak_victim  (former) duck streak count for victim
//bool    rocket_jump     was the victim rocket jumping 

	decl String:buffer[256]; // this is just a 256-char buffer like the same type used in C strings
	
	// These are the things we will send
	decl String:attackerName[64];
	decl String:victimName[64];
	decl String:assisterName[64];
	new killStreakTotal;
	new isRocketJumping;

	// Populate each field
	GetAttackerName(event, attackerName, 64);
	GetVictimName(event, victimName, 64);
	GetAssisterName(event, assisterName, 64);
	killStreakTotal = GetKillStreakTotal(event);
	isRocketJumping = GetRocketJump(event);

	// Construct the string we will send
	Format(buffer, 256, "PLAYER_DEATH##Attacker##%s##Victim##%s##Assister##%s##KillStreakTotal##%d##RocketJump##%d", attackerName, victimName, assisterName, killStreakTotal, isRocketJumping);
	
	// Send string over the wire to all connected clients
	TellClientAbout(buffer);
	
}

public Action:Event_Controlpoint_Starttouch(Handle:event, const String:name[], bool:dontBroadcast)
{
//Note: When a player enters a capture point zone
//Name:   controlpoint_starttouch
//Structure:  
//short   player  entindex of the player
//short   area    index of the control point area 
	decl String:playerName[64];
	GetPlayerName(event, playerName, 64);
	
	decl String:buffer[128];
	Format(buffer, 128, "CONTROLPOINT_STARTTOUCH##PlayerName##%s", playerName);
	TellClientAbout(buffer);
}

public Action:Event_Controlpoint_Endtouch(Handle:event, const String:name[], bool:dontBroadcast)
{
//Note: When a player leaves a capture point zone
//Name:   controlpoint_endtouch
//Structure:  
//short   player  entindex of the player
//short   area    index of the control point area 
	decl String:playerName[64];
	GetPlayerName(event, playerName, 64);

	decl String:buffer[128];
	Format(buffer, 128, "CONTROLPOINT_ENDTOUCH##PlayerName##%s", playerName);
	TellClientAbout(buffer);
}

public Action:Event_ObjectDestroyed(Handle:event, const String:name[], bool:dontBroadcast)
{
//Note: When a player destroys an object
//Name:   object_destroyed
//Structure:  
//short   userid  user ID who died
//short   attacker    user ID who killed
//short   assister    user ID of assister
//string  weapon  weapon name killer used
//short   weaponid    id of the weapon used
//short   objecttype  type of object destroyed
//short   index   index of the object destroyed
//bool    was_building    object was being built when it died 
    decl String:playerName[64];
    GetPlayerName(event, playerName, 64);

    decl String:buffer[128];
    Format(buffer, 128, "OBJECT_DESTROYED##PlayerName##%s", playerName);
    TellClientAbout(buffer);
}

public Action:Event_ctfFlagCaptured(Handle:event, const String:name[], bool:dontBroadcast)
{
//Note: When a flag is captured by a player
//Name:   ctf_flag_captured
//Structure:  
//short   capping_team    
//short   capping_team_score 
    decl String:playerName[64];
    GetPlayerName(event, playerName, 64);

    decl String:buffer[128];
    Format(buffer, 128, "CTF_FLAG_CAPTURED!##PlayerName##%s", playerName);
    TellClientAbout(buffer);
}

public Action:Event_PlayerTeleported(Handle:event, const String:name[], bool:dontBroadcast)
{
//Note: Sent when a player is teleported
//Name:   player_teleported
//Structure:  
//short   userid  userid of the player
//short   builderid   userid of the player who built the teleporter
//float   dist    distance the player was teleported 
   decl String:playerName[64];
   GetPlayerName(event, playerName, 64);

   decl String:buffer[128];
   Format(buffer, 128, "Player_Teleported!##PlayerName##%s", playerName);
   TellClientAbout(buffer); 
}

public Action:Event_PlayerIgnited(Handle:event, const String:name[], bool:dontBroadcast)
{
//Note: sent when a player is ignited, only to the two players involved
//Name:   player_ignited
//Structure:  
//byte    pyro_entindex   entindex of the pyro who ignited the victim
//byte    victim_entindex     entindex of the player ignited by the pyro
//byte    weaponid    weaponid of the weapon used 
    decl String:playerName[64];
    GetPlayerName(event, playerName, 64);

    decl String:buffer[128];
    Format(buffer, 128, "Pyro_Ignited:##PlayerName##%s", playerName);
}

public Action:Event_StickyJump(Handle:event, const String:name[], bool:dontBroadcast)
{
//Name:   sticky_jump
//Structure:  
//short   userid  
//bool    playsound 
    decl String:playerName[64];
    GetPlayerName(event, playerName, 64);

    decl String:buffer[128];
    Format(buffer, 128, "Demoman_sticky_jumped:##PlayerName##%s", playerName);
}

public Action:Event_RocketJump(Handle:event, const String:name[], bool:dontBroadcast)
{
//Name:   rocket_jump
//Structure:  
//short   userid  
//bool    playsound  
	decl String:playerName[64];
	GetPlayerName(event, playerName, 64);

	decl String:buffer[128];
	Format(buffer, 128, "Soldier_sticky_jumped:##PlayerName##%s", playerName);
}

public Action:Event_PlayerExtinguished(Handle:event, const String:name[], bool:dontBroadcast)
{
//Note: sent when a burning player is extinguished by a medic
//Name:   player_extinguished
//Structure:  
//byte    victim  entindex of the player that was extinguished
//byte    healer  entindex of the player who did the extinguishing 
    decl String:playerName[64];
    GetPlayerName(event, playerName, 64);

    decl String:buffer[128];
    Format(buffer, 128, "Medic_extinguished_player:##PlayerName##%s", playerName);
}

public Action:Event_AirDash(Handle:event, const String:name[], bool:dontBroadcast)
{
//Note: Called when a scout Performs Double Jump
//Name:   air_dash
//Structure:  
//byte    player 
    decl String:playerName[64];
    GetPlayerName(event, playername, 64);

    decl String:buffer[128];
    Format(buffer, 128, "Scout_air_dashed:##PlayerName##%s", playerName);
}

public Action:Event_ArrowImpact(Handle:event, const String:name[], bool:dontBroadcast)
{
//Note: When a player is hit by a Sniper's Huntsman arrow or Medic's Crusader's Crossbow arrow
//Name:   arrow_impact
//Structure:  
//short   attachedEntity  
//short   shooter     
//short   boneIndexAttached   
//float   bonePositionX   
//float   bonePositionY   
//float   bonePositionZ   
//float   boneAnglesX     
//float   boneAnglesY     
//float   boneAnglesZ     
//short   projectileType  
//bool    isCrit 
    decl String:playerName[64];
    GetPlayerName(event, playerName, 64);

    decl String:buffer[128];
    Format(buffer, 128, "Arrow_impact:##PlayerName%s", playerName);
}

public Action:Event_SpyPDAReset(Handle:event, const String:name[], bool:dontBroadcast)
{
//Name:   spy_pda_reset
//Structure:  
//
// AlliedMods wiki didn't have info on this one... Maybe just print out SPY_PDA_RESET##name... idk
    decl String:playerName[64];
    GetPlayerName(event, playerName, 64);

    decl String:buffer[128];
    Format(buffer 128, "Spy_reset_PDA:##PlayerName%s", playerName);
}

// Write the "attacker" field from the event into the buffer string
// Use this form if the event uses "user IDs" in the event keys instead of "entindex"es
GetAttackerName(Handle:event, String:buffer[], bufferSize)
{
	new attackerUserId = GetEventInt(event, "attacker");
	new attackerClientId = GetClientOfUserId(attackerUserId);
	GetClientName(attackerClientId, buffer, bufferSize);
}


// Write the "victim" (in the evnt struct, the "userid" to buffer
// Uses User ID's, not entindexes
GetVictimName(Handle:event, String:buffer[], bufferSize)
{
	new victimUserId = GetEventInt(event, "userid");
	new victimClientId = GetClientOfUserId(victimUserId);
	GetClientName(victimClientId, buffer, bufferSize);
}

// Write the "assister" to the buffer
// Uses userID's, not entindex
GetAssisterName(Handle:event, String:buffer[], bufferSize)
{
	new assisterUserId = GetEventInt(event, "assister");
	new assisterClientId = GetClientOfUserId(assisterUserId);
	GetClientName(assisterClientId, buffer, bufferSize);
}

// Returns a cell getting kill streak total of the event
GetKillStreakTotal(Handle:event)
{
	return GetEventInt(event, "kill_streak_total");
}

// Returns a bool telling whether a rocket jump occured in this event
bool:GetRocketJump(Handle:event)
{
	return GetEventBool(event, "rocket_jump");	
}

// Gets player name from the entity index specified in the event
// Use this function if the event uses entindexes
GetPlayerName(Handle:event, String:buffer[], bufferSize)
{
	new playerEntIdx = GetEventInt(event, "player");
	GetClientName(playerEntIdx, buffer, bufferSize);
}