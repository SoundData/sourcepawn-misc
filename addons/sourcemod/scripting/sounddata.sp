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

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	// Tell SourcePawn to map the native function "ConstructMessage" (defined in sounddata_send.inc)
	// to the function Native_ConstructMessage, as implemented below
   CreateNative("ConstructMessage", Native_ConstructMessage);
   
   // Return success to allow other plugins to load
   return APLRes_Success;
}


public OnPluginStart()
{
	HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
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
	PrintToServer("[SM] %s fired a %s || sending [%s] to client", cName, weapName, buffer);
	
	// Send
	SounddataSend(buffer);
}

public Action:Event_PlayerDeath()
{
	// decl String:buffer[512]; // this is just a 512-char buffer like the same type used in C strings
	// decl String:attackerName[64];
	// decl String:
	// GetAttackerName(attackerName, 64);
	// Format(buffer, 512, "PLAYER_DEATH##Attacker##%s##Victim##%s##Assister##%s##KillStreakTotal##%d##RocketJump##%d", attackerName, vicName, assisterName, ksTotal, rocketJump);
	
	decl String:command[4096]; //4096 bytes = 4kb
	ConstructMessage(command, 4096, "PLAYER_DEATH", AttackerName, VictimName, AssisterName, KillStreamTotal, IsRocketJumping);
	SounddataSend(command);
	
	//FormEventString(command, "PLAYER_DEATH", "Attacker", "Victim", "Assister", "KillStreakTotal", "RocketJump");
}

Native_ConstructMessage(Handle:plugin, numParams)
{
	for (new i = 3; i < numParams; i++)
	{
		// Note: probably doing it this way will be too slow.
		// We know that we have (numParams - 4) arguments here, which will all be string or int variables
		// Maybe we should have an array of pointers (references in SourcePawn) to cells, which store the 
		// locations of the relevant parameters, so that we can wrap them all up in a single Format(...)
		// call after filling in all the relevant information.
		switch (GetNativeCell(i))
		{
		
		case AttackerName:
			decl String:attackerName[64];
			new userId = GetEventInt(event, "attacker");
			new clientId = GetClientOfUserId(userId);
			GetClientName(attackerName, cName, sizeof(cName));
			Format(command, "%s##Attacker##%s", command, attackerName);
			break;
		case VictimName:
			decl String:vicName[64];
			new userId = GetEventInt(event, "userid");
			new clientId = GetClientOfUserId(userId);
			GetClientName(attackerName, cName, sizeof(cName));
			Format(command, "%s##Victim##%s", command, attackerName);
			break;
		case AssisterName: //...etc
			
			break;
	}
		
}


// TODO: Fit these into the switch-case statement inside the native function above?
// Or just use separately?
GetClientName(String:buffer[], bufferSize)
{
	
}

GetWeaponName(String:buffer[], bufferSize)
{

}

GetDeadPlayerName(String:buffer[], bufferSize)
{

}
