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
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("controlpoint_starttouch", Event_Controlpoint_Starttouch, EventHookMode_Pre);
	HookEvent("controlpoint_endtouch", Event_Controlpoint_Endtouch, EventHookMode_Pre);
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
	decl String:playerName[64];
	GetPlayerName(event, playerName, 64);
	
	decl String:buffer[128];
	Format(buffer, 128, "CONTROLPOINT_STARTTOUCH##PlayerName##%s", playerName);
	TellClientAbout(buffer);
}

public Action:Event_Controlpoint_Endtouch(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:playerName[64];
	GetPlayerName(event, playerName, 64);

	decl String:buffer[128];
	Format(buffer, 128, "CONTROLPOINT_ENDTOUCH##PlayerName##%s", playerName);
	TellClientAbout(buffer);
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
