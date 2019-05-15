#pragma semicolon 1
#pragma tabsize 0

#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <MultiColors>

#define PLUGIN_NAME "VIPMenu With Extras - CS:GO"
#define PLUGIN_AUTHOR "MYND"
#define PLUGIN_VERSION "1.1.0"

bool UsedMenu[MAXPLAYERS] = false;
bool revived[MAXPLAYERS+1] = false;
ConVar g_Cvar_VIPSpawn;

public Plugin myInfo = {
	name = PLUGIN_NAME,
	description = "A Difrent VIPMenu With Extras: MedKit, WallHack Grenade, HE Grenade, Flashbang & VIPSpawn",
	author = PLUGIN_AUTHOR,
	version = PLUGIN_VERSION
};

public OnPluginStart()
{
	HookEvent("round_start", RoundStart);
	g_Cvar_VIPSpawn = CreateConVar("mynd_vipmenu_vipspawn", "1", "Turn On/Off User Can Use VIPSpawn", _, true, 0.0, true, 1.0);
	
	LoadTranslations("mynd_vipmenu.phrases");
	RegAdminCmd("sm_vipmenu", MenuVIP, ADMFLAG_RESERVATION, "Opens VIPMenu For a VIP Player");
	RegAdminCmd("sm_vipspawn", VIPSpawn, ADMFLAG_RESERVATION);
	AutoExecConfig(true, "mynd_vipmenu");
	HookEvent("decoy_firing", OnDecoyFiring);
}

public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    for(new i = 1; i <= MaxClients; i++)
	{
		UsedMenu[i] = false;
		int flags = GetUserFlagBits(i);
	    if(flags & ADMFLAG_RESERVATION) 
	    {
	    	ShowVIPMenu(i);
        }
    }
}

public void OnDecoyFiring(Event event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);

	float f_Pos[3];
	int entityid = GetEventInt(event, "entityid");
	f_Pos[0] = GetEventFloat(event, "x");
	f_Pos[1] = GetEventFloat(event, "y");
	f_Pos[2] = GetEventFloat(event, "z");

	TeleportEntity(client, f_Pos, NULL_VECTOR, NULL_VECTOR);
	RemoveEdict(entityid);
}

public Action:MenuVIP(client, args)
{
	if(CheckCommandAccess(client, "sm_vipmenu", ADMFLAG_RESERVATION))
	{
		ShowVIPMenu(client);
	}
}

stock ShowVIPMenu(client)
{
    if(IsClientInGame(client) && IsPlayerAlive(client))
   {
   	    UsedMenu[client] = true;
		Menu menu = new Menu(VIPMenu_Handler);
		menu.SetTitle("MenuVIP - Items:");
		menu.AddItem("MedKit", "MedicKit");
		menu.AddItem("WHNade", "WH Grenade");
		menu.AddItem("HENade", "HE Grenade");
		menu.AddItem("Flashbang", "Flashbang");
		menu.AddItem("TPNade", "Teleport Nade");
		menu.ExitButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
   }
}

public VIPMenu_Handler(Handle:VIPMenu, MenuAction:Option, client, VIPMenuIndex)
{
    if (Option == MenuAction_Select)
    {
      decl String:selectedBonus[200];
      GetMenuItem(VIPMenu, VIPMenuIndex, selectedBonus, sizeof(selectedBonus));

      if(StrEqual(selectedBonus, "MedKit"))
      {
      	CPrintToChat(client, "{darkred}[VIPMenu By MYND] {default}%t", "MedicKit");
        GivePlayerItem(client, "weapon_healthshot");
      }
      if(StrEqual(selectedBonus, "WHNade"))
      {
        CPrintToChat(client, "{darkred}[VIPMenu By MYND] {default}%t", "WallHackGrenade");
        GivePlayerItem(client, "weapon_tagrenade");
      }
      if(StrEqual(selectedBonus, "HENade"))
      {
        CPrintToChat(client, "{darkred}[VIPMenu By MYND] {default}%t", "Grenade");
        GivePlayerItem(client, "weapon_hegrenade");
      }
      if(StrEqual(selectedBonus, "Flashbang"))
      {
        CPrintToChat(client, "{darkred}[VIPMenu By MYND] {default}%t", "FlashBang");
        GivePlayerItem(client, "weapon_flashbang");
      }
      if(StrEqual(selectedBonus, "TPNade"))
      {
      	CPrintToChat(client, "{darkred}[VIPMenu By MYND] {default}%t", "Teleport");
      	GivePlayerItem(client, "weapon_decoy");
      }
    }
    else if (Option == MenuAction_End)
    {
        CloseHandle(VIPMenu);
    }
}

public Action VIPSpawn(int client, int args)
{
	if(client == 0)
	{
		PrintToServer("You Only Can Use This Command If You Are In The Server.");
		return Plugin_Handled;
	}
	char message[128];
	if (view_as<bool> (GetConVarInt(g_Cvar_VIPSpawn)))
	{
		if (!IsPlayerAlive(client))
		{
			if(client)
			{
				if (revived[client] == false)
				{
					CS_RespawnPlayer(client);
					CPrintToChatAll("{darkred}[VIPMenu By MYND] {default}%t", "VIPSpawn", client);
					revived[client] = true;
				}
				else
				{
					Format(message, sizeof(message), "{darkred}[VIPMenu By MYND] {default}%t", "VIPSpawn Used", client);
					CPrintToChat(client, message);
				}
			}
			else
			{
				Format(message, sizeof(message), "{darkred}[VIPMenu By MYND] {default}%t", "VIPSpawn VIP", client);
				CPrintToChat(client, message);
			}
		}
		else
		{
			Format(message, sizeof(message), "{darkred}[VIPMenu By MYND] {default}%t", "VIP Not Dead", client);
			CPrintToChat(client, message);
		}
	}
	return Plugin_Handled;
}