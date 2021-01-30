/*
	PASS Time: Carry Music
	
	Different music for when RED and BLU carry the ball. Based on UT99 Bombing Run, a similar gamemode with this mechanic.
	Music shipped with this plugin (Benny Hill theme and Jackass theme) are ripped right from the UT99 mod.
*/

#include <sourcemod>
#include <clientprefs>
#include <tf2_stocks>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0"

TFTeam carrierTeam;
bool neutralListener;
int ball;

public Plugin myinfo = {
	name = "PASS Time Carry Music",
	author = "muddy",
	description = "Plays music while a team is carrying the ball",
	version = VERSION,
	url = ""
}

public void OnPluginStart() {
	HookEvent("pass_get", grabEvent);
	HookEvent("pass_free", dropEvent);
	HookEvent("pass_pass_caught", passEvent);
	HookEvent("pass_ball_stolen", stealEvent);
}

public void OnMapStart() {
	PrecacheSound("bombingrun/carry_red.mp3");
	PrecacheSound("bombingrun/carry_blu.mp3");
}

public Action grabEvent(Handle event, const char[] name, bool dontBroadcast) {
	neutralListener = false;
	int ply = GetEventInt(event, "owner");
	TFTeam plyTeam = TF2_GetClientTeam(ply);
	ball = FindEntityByClassname(-1, "passtime_ball");
	
	if(ball < 0) { //failsafe in case we somehow fire event with no ball.
		return;
	}
	
	if(plyTeam == TFTeam_Red) {
		EmitSoundToAll("bombingrun/carry_red.mp3", ball, SNDCHAN_ITEM, SNDLEVEL_MINIBIKE);
		carrierTeam = TFTeam_Red;
	} else {
		EmitSoundToAll("bombingrun/carry_blu.mp3", ball, SNDCHAN_ITEM, SNDLEVEL_MINIBIKE);
		carrierTeam = TFTeam_Blue;
	}
}

public Action dropEvent(Handle event, const char[] name, bool dontBroadcast) {
	ball = FindEntityByClassname(-1, "passtime_ball");
	neutralListener = true;
}

public Action passEvent(Handle event, const char[] name, bool dontBroadcast) {
	neutralListener = false;
	int ply = GetEventInt(event, "catcher");
	TFTeam plyTeam = TF2_GetClientTeam(ply);
	ball = FindEntityByClassname(-1, "passtime_ball");
	
	if(ball < 0 || plyTeam == carrierTeam) { //if a RED player passes to a teammate, don't restart the song since it's already playing
		return;
	}
	
	silenceBall();
	
	if(plyTeam == TFTeam_Red) {
		EmitSoundToAll("bombingrun/carry_red.mp3", ball, SNDCHAN_ITEM, SNDLEVEL_MINIBIKE);
		carrierTeam = TFTeam_Red;
	} else {
		EmitSoundToAll("bombingrun/carry_blu.mp3", ball, SNDCHAN_ITEM, SNDLEVEL_MINIBIKE);
		carrierTeam = TFTeam_Blue;
	}
}

public Action stealEvent(Handle event, const char[] name, bool dontBroadcast) {
	neutralListener = false;
	int ply = GetEventInt(event, "attacker");
	TFTeam plyTeam = TF2_GetClientTeam(ply);
	ball = FindEntityByClassname(-1, "passtime_ball");
	
	if(ball < 0 || plyTeam == carrierTeam) {
		return;
	}
	
	silenceBall();
	
	if(plyTeam == TFTeam_Red) {
		EmitSoundToAll("bombingrun/carry_red.mp3", ball, SNDCHAN_ITEM, SNDLEVEL_MINIBIKE);
		carrierTeam = TFTeam_Red;
	} else {
		EmitSoundToAll("bombingrun/carry_blu.mp3", ball, SNDCHAN_ITEM, SNDLEVEL_MINIBIKE);
		carrierTeam = TFTeam_Blue;
	}
}

/* When the ball is dropped, neutralListener is set to true, and our game frame code runs.
** This lets us check what team the ball belongs to, because m_iTeamNum is correctly updated.
** Once the ball goes neutral, we stop listening since the grab event will start the music again anyway.
** This should hopefully provide minimal impact with our OnGameFrame() code. */
public void OnGameFrame() {	
	if(!neutralListener) { return; }
	
	if(GetEntProp(ball, Prop_Send, "m_iTeamNum") < 2) {
		silenceBall();
		neutralListener = false;
		carrierTeam = TFTeam_Unassigned;
	}
}

public void silenceBall() {
	StopSound(ball, SNDCHAN_ITEM, "bombingrun/carry_red.mp3");
	StopSound(ball, SNDCHAN_ITEM, "bombingrun/carry_blu.mp3");
}