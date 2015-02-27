/**
 * Broadcasts a message over ZeroMQ to all connected music clients.
 *
 * @param msg	Message to print.
 * @noreturn
 */
native SounddataSend(const String:message[]);

native ConstructMessage(String:messageBuf[], const size, const String:eventType[], rest:...);


enum ParamTypes {
	AttackerName = 1,
	VictimName = 2,
	WeaponName = 3,
	IsRocketJumping = 4,
	//... etc
}