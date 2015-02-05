#if defined _sf2_playergroups_menus
 #endinput
#endif

#define _sf2_playergroups_menus

DisplayGroupMainMenuToClient(client)
{
	new Handle:hMenu = CreateMenu(Menu_GroupMain);
	SetMenuTitle(hMenu, "%t%T\n \n%T\n \n", "SF2 Prefix", "SF2 Group Main Menu Title", client, "SF2 Group Main Menu Description", client);
	
	new iGroupIndex = ClientGetPlayerGroup(client);
	new bool:bGroupIsActive = IsPlayerGroupActive(iGroupIndex);
	
	decl String:sBuffer[256];
	if (bGroupIsActive && GetPlayerGroupLeader(iGroupIndex) == client)
	{
		Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Admin Group Menu Title", client);
	}
	else
	{
		Format(sBuffer, sizeof(sBuffer), "%T", "SF2 View Current Group Info Menu Title", client);
	}
	
	AddMenuItem(hMenu, "0", sBuffer, bGroupIsActive ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Create Group Menu Title", client);
	AddMenuItem(hMenu, "0", sBuffer, bGroupIsActive ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Leave Group Menu Title", client);
	AddMenuItem(hMenu, "0", sBuffer, bGroupIsActive ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_GroupMain(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End) CloseHandle(menu);
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack) DisplayMenu(g_hMenuMain, param1, 30);
	}
	else if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayAdminGroupMenuToClient(param1);
			case 1: DisplayCreateGroupMenuToClient(param1);
			case 2: DisplayLeaveGroupMenuToClient(param1);
		}
	}
}

DisplayCreateGroupMenuToClient(client)
{
	new iGroupIndex = ClientGetPlayerGroup(client);
	if (IsPlayerGroupActive(iGroupIndex))
	{
		// He's already in a group. Take him back to the main menu.
		DisplayGroupMainMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 In Group", client);
		return;
	}
	
	new Handle:hMenu = CreateMenu(Menu_CreateGroup);
	SetMenuTitle(hMenu, "%t%T\n \n%T\n \n", "SF2 Prefix", "SF2 Create Group Menu Title", client, "SF2 Create Group Menu Description", client, GetMaxPlayersForRound(), g_iPlayerQueuePoints[client]);
	
	decl String:sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "%T", "Yes", client);
	AddMenuItem(hMenu, "0", sBuffer);
	Format(sBuffer, sizeof(sBuffer), "%T", "No", client);
	AddMenuItem(hMenu, "0", sBuffer);
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_CreateGroup(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End) CloseHandle(menu);
	else if (action == MenuAction_Select)
	{
		if (param2 == 0)
		{
			new iGroupIndex = ClientGetPlayerGroup(param1);
			if (IsPlayerGroupActive(iGroupIndex))
			{
				CPrintToChat(param1, "%T", "SF2 In Group", param1);
			}
			else
			{
				iGroupIndex = CreatePlayerGroup();
				if (iGroupIndex != -1)
				{
					new iQueuePoints = g_iPlayerQueuePoints[param1];
				
					decl String:sGroupName[64];
					Format(sGroupName, sizeof(sGroupName), "Group %d", iGroupIndex);
					SetPlayerGroupName(iGroupIndex, sGroupName);
					ClientSetPlayerGroup(param1, iGroupIndex);
					SetPlayerGroupLeader(iGroupIndex, param1);
					SetPlayerGroupQueuePoints(iGroupIndex, iQueuePoints);
					
					CPrintToChat(param1, "%T", "SF2 Created Group", param1, sGroupName);
				}
				else
				{
					CPrintToChat(param1, "%T", "SF2 Max Groups Reached", param1);
				}
			}
		}
		
		DisplayGroupMainMenuToClient(param1);
	}
}

DisplayLeaveGroupMenuToClient(client)
{
	new iGroupIndex = ClientGetPlayerGroup(client);
	if (!IsPlayerGroupActive(iGroupIndex))
	{
		// His group isn't valid anymore. Take him back to the main menu.
		DisplayGroupMainMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Group Does Not Exist", client);
		return;
	}
	
	decl String:sGroupName[SF2_MAX_PLAYER_GROUP_NAME_LENGTH];
	GetPlayerGroupName(iGroupIndex, sGroupName, sizeof(sGroupName));
	
	new Handle:hMenu = CreateMenu(Menu_LeaveGroup);
	SetMenuTitle(hMenu, "%t%T\n \n%T\n \n", "SF2 Prefix", "SF2 Leave Group Menu Title", client, "SF2 Leave Group Menu Description", client, sGroupName);
	
	decl String:sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "%T", "Yes", client);
	AddMenuItem(hMenu, "0", sBuffer);
	Format(sBuffer, sizeof(sBuffer), "%T", "No", client);
	AddMenuItem(hMenu, "0", sBuffer);
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_LeaveGroup(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End) CloseHandle(menu);
	else if (action == MenuAction_Select)
	{
		if (param2 == 0)
		{
			new iGroupIndex = ClientGetPlayerGroup(param1);
			if (!IsPlayerGroupActive(iGroupIndex))
			{
				CPrintToChat(param1, "%T", "SF2 Group Does Not Exist", param1);
			}
			else
			{
				ClientSetPlayerGroup(param1, -1);
			}
		}
		
		DisplayGroupMainMenuToClient(param1);
	}
}

DisplayAdminGroupMenuToClient(client)
{
	new iGroupIndex = ClientGetPlayerGroup(client);
	if (!IsPlayerGroupActive(iGroupIndex))
	{
		// His group isn't valid anymore. Take him back to the main menu.
		DisplayGroupMainMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Group Does Not Exist", client);
		return;
	}
	
	decl String:sGroupName[SF2_MAX_PLAYER_GROUP_NAME_LENGTH];
	GetPlayerGroupName(iGroupIndex, sGroupName, sizeof(sGroupName));
	
	decl String:sLeaderName[MAX_NAME_LENGTH];
	new iGroupLeader = GetPlayerGroupLeader(iGroupIndex);
	if (IsValidClient(iGroupLeader)) GetClientName(iGroupLeader, sLeaderName, sizeof(sLeaderName));
	else strcopy(sLeaderName, sizeof(sLeaderName), "---");
	
	new iMemberCount = GetPlayerGroupMemberCount(iGroupIndex);
	new iMaxPlayers = GetMaxPlayersForRound();
	new iQueuePoints = GetPlayerGroupQueuePoints(iGroupIndex);
	
	new Handle:hMenu = CreateMenu(Menu_AdminGroup);
	SetMenuTitle(hMenu, "%t%T\n \n%T\n \n", "SF2 Prefix", "SF2 Admin Group Menu Title", client, "SF2 Admin Group Menu Description", client, sGroupName, sLeaderName, iMemberCount, iMaxPlayers, iQueuePoints);
	
	decl String:sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 View Group Members Menu Title", client);
	AddMenuItem(hMenu, "0", sBuffer);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Set Group Name Menu Title", client);
	AddMenuItem(hMenu, "0", sBuffer, iGroupLeader == client ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Set Group Leader Menu Title", client);
	AddMenuItem(hMenu, "0", sBuffer, iGroupLeader == client ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Invite To Group Menu Title", client);
	AddMenuItem(hMenu, "0", sBuffer, iGroupLeader == client && iMemberCount < iMaxPlayers ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Kick From Group Menu Title", client);
	AddMenuItem(hMenu, "0", sBuffer, iGroupLeader == client && iMemberCount > 1 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(sBuffer, sizeof(sBuffer), "%T", "SF2 Reset Group Queue Points Menu Title", client);
	AddMenuItem(hMenu, "0", sBuffer, iGroupLeader == client ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_AdminGroup(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End) CloseHandle(menu);
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack) DisplayGroupMainMenuToClient(param1);
	}
	else if (action == MenuAction_Select)
	{
		new iGroupIndex = ClientGetPlayerGroup(param1);
		if (IsPlayerGroupActive(iGroupIndex))
		{
			switch (param2)
			{
				case 0: DisplayViewGroupMembersMenuToClient(param1);
				case 1: DisplaySetGroupNameMenuToClient(param1);
				case 2: DisplaySetGroupLeaderMenuToClient(param1);
				case 3: DisplayInviteToGroupMenuToClient(param1);
				case 4: DisplayKickFromGroupMenuToClient(param1);
				case 5: DisplayResetGroupQueuePointsMenuToClient(param1);
			}
		}
		else
		{
			DisplayGroupMainMenuToClient(param1);
			CPrintToChat(param1, "%T", "SF2 Group Does Not Exist", param1);
		}
	}
}

DisplayViewGroupMembersMenuToClient(client)
{
	new iGroupIndex = ClientGetPlayerGroup(client);
	if (!IsPlayerGroupActive(iGroupIndex))
	{
		// His group isn't valid anymore. Take him back to the main menu.
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Group Does Not Exist", client);
		return;
	}
	
	new Handle:hPlayers = CreateArray();
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		
		new iTempGroup = ClientGetPlayerGroup(i);
		if (!IsPlayerGroupActive(iTempGroup) || iTempGroup != iGroupIndex) continue;
		
		PushArrayCell(hPlayers, i);
	}
	
	new iPlayerCount = GetArraySize(hPlayers);
	if (iPlayerCount)
	{
		new Handle:hMenu = CreateMenu(Menu_ViewGroupMembers);
		SetMenuTitle(hMenu, "%t%T\n \n%T\n \n", "SF2 Prefix", "SF2 View Group Members Menu Title", client, "SF2 View Group Members Menu Description", client);
		
		decl String:sUserId[32];
		decl String:sName[MAX_NAME_LENGTH];
		
		for (new i = 0; i < iPlayerCount; i++)
		{
			new iClient = GetArrayCell(hPlayers, i);
			IntToString(GetClientUserId(iClient), sUserId, sizeof(sUserId));
			GetClientName(iClient, sName, sizeof(sName));
			AddMenuItem(hMenu, sUserId, sName);
		}
		
		SetMenuExitBackButton(hMenu, true);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
	else
	{
		// No players left for the taking!
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 No Players Available", client);
	}
	
	CloseHandle(hPlayers);
}

public Menu_ViewGroupMembers(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End) CloseHandle(menu);
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack) DisplayAdminGroupMenuToClient(param1);
	}
	else if (action == MenuAction_Select) DisplayAdminGroupMenuToClient(param1);
}

DisplaySetGroupLeaderMenuToClient(client)
{
	new iGroupIndex = ClientGetPlayerGroup(client);
	if (!IsPlayerGroupActive(iGroupIndex))
	{
		// His group isn't valid anymore. Take him back to the main menu.
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Group Does Not Exist", client);
		return;
	}
	
	if (GetPlayerGroupLeader(iGroupIndex) != client)
	{
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Not Group Leader", client);
		return;
	}
	
	new Handle:hPlayers = CreateArray();
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		
		new iTempGroup = ClientGetPlayerGroup(i);
		if (!IsPlayerGroupActive(iTempGroup) || iTempGroup != iGroupIndex) continue;
		if (i == client) continue;
		
		PushArrayCell(hPlayers, i);
	}
	
	new iPlayerCount = GetArraySize(hPlayers);
	if (iPlayerCount)
	{
		new Handle:hMenu = CreateMenu(Menu_SetGroupLeader);
		SetMenuTitle(hMenu, "%t%T\n \n%T\n \n", "SF2 Prefix", "SF2 Set Group Leader Menu Title", client, "SF2 Set Group Leader Menu Description", client);
		
		decl String:sUserId[32];
		decl String:sName[MAX_NAME_LENGTH];
		
		for (new i = 0; i < iPlayerCount; i++)
		{
			new iClient = GetArrayCell(hPlayers, i);
			IntToString(GetClientUserId(iClient), sUserId, sizeof(sUserId));
			GetClientName(iClient, sName, sizeof(sName));
			AddMenuItem(hMenu, sUserId, sName);
		}
		
		SetMenuExitBackButton(hMenu, true);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
	else
	{
		// No players left for the taking!
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 No Players Available", client);
	}
	
	CloseHandle(hPlayers);
}

public Menu_SetGroupLeader(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End) CloseHandle(menu);
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack) DisplayAdminGroupMenuToClient(param1);
	}
	else if (action == MenuAction_Select)
	{
		new iGroupIndex = ClientGetPlayerGroup(param1);
		if (IsPlayerGroupActive(iGroupIndex) && GetPlayerGroupLeader(iGroupIndex) == param1)
		{
			decl String:sInfo[64];
			GetMenuItem(menu, param2, sInfo, sizeof(sInfo));
			new userid = StringToInt(sInfo);
			new iPlayer = GetClientOfUserId(userid);
			
			if (ClientGetPlayerGroup(iPlayer) == iGroupIndex && IsValidClient(iPlayer))
			{
				decl String:sGroupName[SF2_MAX_PLAYER_GROUP_NAME_LENGTH];
				decl String:sName[MAX_NAME_LENGTH];
				GetPlayerGroupName(iGroupIndex, sGroupName, sizeof(sGroupName));
				GetClientName(iPlayer, sName, sizeof(sName));
				
				SetPlayerGroupLeader(iGroupIndex, iPlayer);
			}
			else
			{
				CPrintToChat(param1, "%T", "SF2 Player Not In Group", param1);
			}
		}
		
		DisplayAdminGroupMenuToClient(param1);
	}
}

DisplayKickFromGroupMenuToClient(client)
{
	new iGroupIndex = ClientGetPlayerGroup(client);
	if (!IsPlayerGroupActive(iGroupIndex))
	{
		// His group isn't valid anymore. Take him back to the main menu.
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Group Does Not Exist", client);
		return;
	}
	
	if (GetPlayerGroupLeader(iGroupIndex) != client)
	{
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Not Group Leader", client);
		return;
	}
	
	new Handle:hPlayers = CreateArray();
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		
		new iTempGroup = ClientGetPlayerGroup(i);
		if (!IsPlayerGroupActive(iTempGroup) || iTempGroup != iGroupIndex) continue;
		if (i == client) continue;
		
		PushArrayCell(hPlayers, i);
	}
	
	new iPlayerCount = GetArraySize(hPlayers);
	if (iPlayerCount)
	{
		new Handle:hMenu = CreateMenu(Menu_KickFromGroup);
		SetMenuTitle(hMenu, "%t%T\n \n%T\n \n", "SF2 Prefix", "SF2 Kick From Group Menu Title", client, "SF2 Kick From Group Menu Description", client);
		
		decl String:sUserId[32];
		decl String:sName[MAX_NAME_LENGTH];
		
		for (new i = 0; i < iPlayerCount; i++)
		{
			new iClient = GetArrayCell(hPlayers, i);
			IntToString(GetClientUserId(iClient), sUserId, sizeof(sUserId));
			GetClientName(iClient, sName, sizeof(sName));
			AddMenuItem(hMenu, sUserId, sName);
		}
		
		SetMenuExitBackButton(hMenu, true);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
	else
	{
		// No players left for the taking!
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 No Players Available", client);
	}
	
	CloseHandle(hPlayers);
}

public Menu_KickFromGroup(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End) CloseHandle(menu);
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack) DisplayAdminGroupMenuToClient(param1);
	}
	else if (action == MenuAction_Select)
	{
		new iGroupIndex = ClientGetPlayerGroup(param1);
		if (IsPlayerGroupActive(iGroupIndex) && GetPlayerGroupLeader(iGroupIndex) == param1)
		{
			decl String:sInfo[64];
			GetMenuItem(menu, param2, sInfo, sizeof(sInfo));
			new userid = StringToInt(sInfo);
			new iPlayer = GetClientOfUserId(userid);
			
			if (ClientGetPlayerGroup(iPlayer) == iGroupIndex)
			{
				decl String:sGroupName[SF2_MAX_PLAYER_GROUP_NAME_LENGTH];
				decl String:sName[MAX_NAME_LENGTH];
				GetPlayerGroupName(iGroupIndex, sGroupName, sizeof(sGroupName));
				GetClientName(iPlayer, sName, sizeof(sName));
				
				CPrintToChat(iPlayer, "%T", "SF2 Kicked From Group", iPlayer, sGroupName);
				ClientSetPlayerGroup(iPlayer, -1);
				CPrintToChat(param1, "%T", "SF2 Player Kicked From Group", param1, sName);
			}
			else
			{
				CPrintToChat(param1, "%T", "SF2 Player Not In Group", param1);
			}
		}
		
		DisplayKickFromGroupMenuToClient(param1);
	}
}

DisplaySetGroupNameMenuToClient(client)
{
	new iGroupIndex = ClientGetPlayerGroup(client);
	if (!IsPlayerGroupActive(iGroupIndex))
	{
		// His group isn't valid anymore. Take him back to the main menu.
		DisplayGroupMainMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Group Does Not Exist", client);
		return;
	}
	
	if (GetPlayerGroupLeader(iGroupIndex) != client)
	{
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Not Group Leader", client);
		return;
	}
	
	new Handle:hMenu = CreateMenu(Menu_SetGroupName);
	SetMenuTitle(hMenu, "%t%T\n \n%T\n \n", "SF2 Prefix", "SF2 Set Group Name Menu Title", client, "SF2 Set Group Name Menu Description", client);
	
	decl String:sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "%T", "Back", client);
	AddMenuItem(hMenu, "0", sBuffer);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_SetGroupName(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End) CloseHandle(menu);
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack) DisplayAdminGroupMenuToClient(param1);
	}
	else if (action == MenuAction_Select) DisplayAdminGroupMenuToClient(param1);
}

DisplayInviteToGroupMenuToClient(client)
{
	new iGroupIndex = ClientGetPlayerGroup(client);
	if (!IsPlayerGroupActive(iGroupIndex))
	{
		// His group isn't valid anymore. Take him back to the main menu.
		DisplayGroupMainMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Group Does Not Exist", client);
		return;
	}
	
	if (GetPlayerGroupLeader(iGroupIndex) != client)
	{
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Not Group Leader", client);
		return;
	}
	
	if (GetPlayerGroupMemberCount(iGroupIndex) >= GetMaxPlayersForRound())
	{
		// His group is full!
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 Group Is Full", client);
		return;
	}
	
	new Handle:hPlayers = CreateArray();
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsClientParticipating(i)) continue;
		
		new iTempGroup = ClientGetPlayerGroup(i);
		if (IsPlayerGroupActive(iTempGroup)) continue;
		if (!g_bPlayerEliminated[i]) continue;
		
		PushArrayCell(hPlayers, i);
	}
	
	new iPlayerCount = GetArraySize(hPlayers);
	if (iPlayerCount)
	{
		new Handle:hMenu = CreateMenu(Menu_InviteToGroup);
		SetMenuTitle(hMenu, "%t%T\n \n%T\n \n", "SF2 Prefix", "SF2 Invite To Group Menu Title", client, "SF2 Invite To Group Menu Description", client);
		
		decl String:sUserId[32];
		decl String:sName[MAX_NAME_LENGTH];
		
		for (new i = 0; i < iPlayerCount; i++)
		{
			new iClient = GetArrayCell(hPlayers, i);
			IntToString(GetClientUserId(iClient), sUserId, sizeof(sUserId));
			GetClientName(iClient, sName, sizeof(sName));
			AddMenuItem(hMenu, sUserId, sName);
		}
		
		SetMenuExitBackButton(hMenu, true);
		DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	}
	else
	{
		// No players left for the taking!
		DisplayAdminGroupMenuToClient(client);
		CPrintToChat(client, "%T", "SF2 No Players Available", client);
	}
	
	CloseHandle(hPlayers);
}

public Menu_InviteToGroup(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End) CloseHandle(menu);
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack) DisplayAdminGroupMenuToClient(param1);
	}
	else if (action == MenuAction_Select)
	{
		new iGroupIndex = ClientGetPlayerGroup(param1);
		if (IsPlayerGroupActive(iGroupIndex) && GetPlayerGroupLeader(iGroupIndex) == param1)
		{
			decl String:sInfo[64];
			GetMenuItem(menu, param2, sInfo, sizeof(sInfo));
			new userid = StringToInt(sInfo);
			new iInvitedPlayer = GetClientOfUserId(userid);
			SendPlayerGroupInvitation(iInvitedPlayer, GetPlayerGroupID(iGroupIndex), param1);
		}
		
		DisplayInviteToGroupMenuToClient(param1);
	}
}