#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <colors>

#define PLUGIN_NAME "VIPMenu With Extras - CS:GO"
#define PLUGIN_AUTHOR "MYND"
#define PLUGIN_VERSION "1.0.0"

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
	g_Cvar_VIPSpawn = CreateConVar("mynd_vipmenu_vipspawn", "1", "Turn On/Off User Can Use VIPSpawn", _, true, 0.0, true, 1.0);
	
	LoadTranslations("mynd_vipmenu.phrases");
	RegAdminCmd("sm_vipmenu", MenuVIP, ADMFLAG_RESERVATION, "Opens VIPMenu For a VIP Player");
	RegConsoleCmd("sm_vipspawn", VIPSpawn);
	AutoExecConfig(true, "mynd_vipmenu");
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
    new Handle:VIPMenu = CreateMenu(VIPMenu_Handler);
    SetMenuTitle(VIPMenu, "VIPMenu Items:");
    AddMenuItem(VIPMenu, "MedKit", "MedKit");
    AddMenuItem(VIPMenu, "WHNade", "WH Grenade");
    AddMenuItem(VIPMenu, "HENade", "HE Grenade");
    AddMenuItem(VIPMenu, "Flashbang", "Flashbang");
    DisplayMenu(VIPMenu, client, MENU_TIME_FOREVER);
}

public VIPMenu_Handler(Handle:VIPMenu, MenuAction:Option, client, VIPMenuIndex)
{
    if (Option == MenuAction_Select)
    {
      decl String:selectedBonus[200];
      GetMenuItem(VIPMenu, VIPMenuIndex, selectedBonus, sizeof(selectedBonus));

      if(StrEqual(selectedBonus, "MedKit"))
      {
        CPrintToChat(client, "\x01 \x04[VIPMenu By MYND] \x01%t", "MedicKit");
        GivePlayerItem(client, "weapon_healthshot");
      }
      if(StrEqual(selectedBonus, "WHNade"))
      {
        CPrintToChat(client, "\x01 \x04[VIPMenu By MYND] \x01%t", "WallHackGrenade");
        GivePlayerItem(client, "weapon_tagrenade");
      }
      if(StrEqual(selectedBonus, "HENade"))
      {
        CPrintToChat(client, "\x01 \x04[VIPMenu By MYND] \x01%t", "Grenade");
        GivePlayerItem(client, "weapon_hegrenade");
      }
      if(StrEqual(selectedBonus, "Flashbang"))
      {
        CPrintToChat(client, "\x01 \x04[VIPMenu By MYND] \x01%t", "FlashBang");
        GivePlayerItem(client, "weapon_flashbang");
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
			if (HasClientFlag(client, ADMFLAG_RESERVATION))
			{
				if (revived[client] == false)
				{
					CS_RespawnPlayer(client);
					CPrintToChatAll("\x01 \x04[VIPMenu By MYND] \x01%t", "VIPSpawn", client);
					revived[client] = true;
				}
				else
				{
					Format(message, sizeof(message), "\x01 \x04[VIPMenu By MYND] \x01%t", "VIPSpawn Used", client);
					CPrintToChat(client, message);
				}
			}
			else
			{
				Format(message, sizeof(message), "\x01 \x04[VIPMenu By MYND] \x01%t", "VIPSpawn VIP", client);
				CPrintToChat(client, message);
			}
		}
		else
		{
			Format(message, sizeof(message), "\x01 \x04[VIPMenu By MYND] \x01%t", "VIP Not Dead", client);
			CPrintToChat(client, message);
		}
	}
	return Plugin_Handled;
}

public bool HasClientFlag(int client, int flag)
{
	return CheckCommandAccess(client, "", flag, true);
}