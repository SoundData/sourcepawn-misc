#pragma semicolon 1

#include <sourcemod>
#include <events>
#include <sounddata_send>

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
	HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Pre);
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
	SounddataSend(buffer);
	return true;
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
	PrintToServer("[SM] %s fired a %s || sending [%s] to clients", cName, weapName, buffer);
	
	// Send
	SounddataSend(buffer);
}
