/**
 * Broadcasts a message over ZeroMQ to all connected music clients.
 *
 * @param msg	Message to print.
 * @noreturn
 */
native TellClientAbout(const String:message[]);

//native ConstructMessage(Handle:event, String:messageBuf[], const size, const String:eventType[], rest:...);


enum ParamTypes {
	AttackerName = 1,
	VictimName = 2,
	WeaponName = 3,
	IsRocketJumping = 4,
	AssisterName = 5,
	KillStreamTotal = 6,
	//... etc
}
