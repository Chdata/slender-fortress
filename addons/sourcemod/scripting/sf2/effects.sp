



enum EffectEvent
{
	EffectEvent_Invalid = -1,
	EffectEvent_Constant = 0,
	EffectEvent_HitPlayer,
	EffectEvent_PlayerSeesBoss
};

enum EffectType
{
	EffectType_Invalid = -1,
	EffectType_Steam = 0
};

SlenderSpawnEffects(iBossIndex, EffectEvent:iEvent)
{
	if (iBossIndex < 0 || iBossIndex >= MAX_BOSSES) return;
	
	new iBossID = g_iSlenderID[iBossIndex];
	if (iBossID == -1) return;
	
	decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
	strcopy(sProfile, sizeof(sProfile), g_strSlenderProfile[iBossIndex]);
	
	if (!sProfile[0]) return;
	
	KvRewind(g_hConfig);
	if (!KvJumpToKey(g_hConfig, sProfile) || !KvJumpToKey(g_hConfig, "effects") || !KvGotoFirstSubKey(g_hConfig)) return;
	
	new Handle:hArray = CreateArray(64);
	decl String:sSectionName[64];
	
	do
	{
		KvGetSectionName(g_hConfig, sSectionName, sizeof(sSectionName));
		PushArrayString(hArray, sSectionName);
	}
	while (KvGotoNextKey(g_hConfig));
	
	if (GetArraySize(hArray) == 0)
	{
		CloseHandle(hArray);
		return;
	}
	
	decl String:sEvent[64];
	GetEffectEventString(iEvent, sEvent, sizeof(sEvent));
	if (!sEvent[0]) 
	{
		LogError("Could not spawn effects for boss %d: invalid event string!", iBossIndex);
		return;
	}
	
	new iSlender = EntRefToEntIndex(g_iSlender[iBossIndex]);
	decl Float:flBasePos[3], Float:flBaseAng[3];
	
	for (new i = 0, iSize = GetArraySize(hArray); i < iSize; i++)
	{
		GetArrayString(hArray, i, sSectionName, sizeof(sSectionName));
		KvRewind(g_hConfig);
		KvJumpToKey(g_hConfig, sProfile);
		KvJumpToKey(g_hConfig, "effects");
		KvJumpToKey(g_hConfig, sSectionName);
		
		// Validate effect event. Check to see if it matches with ours.
		decl String:sEffectEvent[64];
		KvGetString(g_hConfig, "event", sEffectEvent, sizeof(sEffectEvent));
		if (!StrEqual(sEffectEvent, sEvent, false)) continue;
		
		// Validate effect type.
		decl String:sEffectType[64];
		KvGetString(g_hConfig, "type", sEffectType, sizeof(sEffectType));
		new EffectType:iEffectType = GetEffectTypeFromString(sEffectType);
		
		if (iEffectType == EffectType_Invalid)
		{
			LogError("Could not spawn effect %s for boss %d: invalid type!", sSectionName, iBossIndex);
			continue;
		}
		
		// Check base position behavior.
		decl String:sBasePosCustom[64];
		KvGetString(g_hConfig, "origin_custom", sBasePosCustom, sizeof(sBasePosCustom));
		if (StrEqual(sBasePosCustom, "&CURRENTTARGET&", false))
		{
			new iTarget = EntRefToEntIndex(g_iSlenderTarget[iBossIndex]);
			if (!iTarget || iTarget == INVALID_ENT_REFERENCE)
			{
				LogError("Could not spawn effect %s for boss %d: unable to read position of target due to no target!");
				continue;
			}
			
			GetEntPropVector(iTarget, Prop_Data, "m_vecAbsOrigin", flBasePos);
		}
		else
		{
			if (!iSlender || iSlender == INVALID_ENT_REFERENCE)
			{
				LogError("Could not spawn effect %s for boss %d: unable to read position due to boss entity not in game!");
				continue;
			}
			
			GetEntPropVector(iSlender, Prop_Data, "m_vecAbsOrigin", flBasePos);
		}
		
		decl String:sBaseAngCustom[64];
		KvGetString(g_hConfig, "angles_custom", sBaseAngCustom, sizeof(sBaseAngCustom));
		if (StrEqual(sBaseAngCustom, "&CURRENTTARGET&", false))
		{
			new iTarget = EntRefToEntIndex(g_iSlenderTarget[iBossIndex]);
			if (!iTarget || iTarget == INVALID_ENT_REFERENCE)
			{
				LogError("Could not spawn effect %s for boss %d: unable to read angles of target due to no target!");
				continue;
			}
			
			GetEntPropVector(iTarget, Prop_Data, "m_angAbsRotation", flBaseAng);
		}
		else
		{
			if (!iSlender || iSlender == INVALID_ENT_REFERENCE)
			{
				LogError("Could not spawn effect %s for boss %d: unable to read angles due to boss entity not in game!");
				continue;
			}
			
			GetEntPropVector(iSlender, Prop_Data, "m_angAbsRotation", flBaseAng);
		}
		
		new iEnt = -1;
		
		switch (iEffectType)
		{
			case EffectType_Steam: iEnt = CreateEntityByName("env_steam");
		}
		
		if (iEnt != -1)
		{
			decl String:sValue[PLATFORM_MAX_PATH];
			KvGetString(g_hConfig, "renderamt", sValue, sizeof(sValue), "255");
			DispatchKeyValue(iEnt, "renderamt", sValue);
			KvGetString(g_hConfig, "rendermode", sValue, sizeof(sValue));
			DispatchKeyValue(iEnt, "rendermode", sValue);
			KvGetString(g_hConfig, "renderfx", sValue, sizeof(sValue), "0");
			DispatchKeyValue(iEnt, "renderfx", sValue);
			KvGetString(g_hConfig, "spawnflags", sValue, sizeof(sValue));
			DispatchKeyValue(iEnt, "spawnflags", sValue);
			
			switch  (iEffectType)
			{
				case EffectType_Steam:
				{
					KvGetString(g_hConfig, "spreadspeed", sValue, sizeof(sValue));
					DispatchKeyValue(iEnt, "SpreadSpeed", sValue);
					KvGetString(g_hConfig, "speed", sValue, sizeof(sValue));
					DispatchKeyValue(iEnt, "Speed", sValue);
					KvGetString(g_hConfig, "startsize", sValue, sizeof(sValue));
					DispatchKeyValue(iEnt, "StartSize", sValue);
					KvGetString(g_hConfig, "endsize", sValue, sizeof(sValue));
					DispatchKeyValue(iEnt, "EndSize", sValue);
					KvGetString(g_hConfig, "rate", sValue, sizeof(sValue));
					DispatchKeyValue(iEnt, "Rate", sValue);
					KvGetString(g_hConfig, "jetlength", sValue, sizeof(sValue));
					DispatchKeyValue(iEnt, "Jetlength", sValue);
					KvGetString(g_hConfig, "rollspeed", sValue, sizeof(sValue));
					DispatchKeyValue(iEnt, "RollSpeed", sValue);
					KvGetString(g_hConfig, "particletype", sValue, sizeof(sValue));
					DispatchKeyValue(iEnt, "type", sValue);
					DispatchSpawn(iEnt);
					ActivateEntity(iEnt);
				}
			}
			
			decl Float:flEffectPos[3], Float:flEffectAng[3];
			
			KvGetVector(g_hConfig, "origin", flEffectPos);
			KvGetVector(g_hConfig, "angles", flEffectAng);
			VectorTransform(flEffectPos, flBasePos, flBaseAng, flEffectPos);
			AddVectors(flEffectAng, flBaseAng, flEffectAng);
			TeleportEntity(iEnt, flEffectPos, flEffectAng, NULL_VECTOR);
			
			new Float:flLifeTime = KvGetFloat(g_hConfig, "lifetime");
			if (flLifeTime > 0.0) CreateTimer(flLifeTime, Timer_KillEntity, EntIndexToEntRef(iEnt), TIMER_FLAG_NO_MAPCHANGE);
			
			decl String:sParentCustom[64];
			KvGetString(g_hConfig, "parent_custom", sParentCustom, sizeof(sParentCustom));
			if (StrEqual(sParentCustom, "&CURRENTTARGET&", false))
			{
				new iTarget = EntRefToEntIndex(g_iSlenderTarget[iBossIndex]);
				if (!iTarget || iTarget == INVALID_ENT_REFERENCE)
				{
					LogError("Could not parent effect %s of boss %d to current target: target does not exist!", sSectionName, iBossIndex);
					continue;
				}
			
				SetVariantString("!activator");
				AcceptEntityInput(iEnt, "SetParent", iTarget);
			}
			else
			{
				if (!iSlender || iSlender == INVALID_ENT_REFERENCE)
				{
					LogError("Could not parent effect %s of boss %d to itself: boss entity does not exist!", sSectionName, iBossIndex);
					continue;
				}
				
				SetVariantString("!activator");
				AcceptEntityInput(iEnt, "SetParent", iSlender);
			}
			
			switch (iEffectType)
			{
				case EffectType_Steam: AcceptEntityInput(iEnt, "TurnOn");
			}
		}
	}
}

stock GetEffectEventString(EffectEvent:iEvent, String:sBuffer[], iBufferLen)
{
	switch (iEvent)
	{
		case EffectEvent_Constant: strcopy(sBuffer, iBufferLen, "constant");
		case EffectEvent_HitPlayer: strcopy(sBuffer, iBufferLen, "boss_hitplayer");
		case EffectEvent_PlayerSeesBoss: strcopy(sBuffer, iBufferLen, "boss_seenbyplayer");
		default: strcopy(sBuffer, iBufferLen, "");
	}
}

stock EffectType:GetEffectTypeFromString(const String:sType[])
{
	if (StrEqual(sType, "steam", false)) return EffectType_Steam;
	return EffectType_Invalid;
}
