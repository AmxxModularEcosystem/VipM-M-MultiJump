#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <VipModular>

#pragma semicolon 1
#pragma compress 1

public stock const PluginName[] = "[VipM-M] Multi Jump";
public stock const PluginVersion[] = "1.1.1";
public stock const PluginAuthor[] = "ArKaNeMaN";
public stock const PluginURL[] = "https://github.com/ArKaNeMaN/VipM-M-MultiJump";
public stock const PluginDescription[] = "Multi jump module for Vip Modular.";

new const MODULE_NAME[] = "MultiJump";
new const PARAM_COUNT_NAME[] = "Count";
new const PARAM_VEL_MULT_NAME[] = "VelMult";
new const PARAM_COOLDOWN_NAME[] = "Cooldown";

new g_iUserMaxJumps[MAX_PLAYERS + 1] = {0, ...};
new Float:g_iUserVelocityMultiplier[MAX_PLAYERS + 1] = {1.0, ...};
new Float:g_fUserCooldownDuration[MAX_PLAYERS + 1] = {0.0, ...};

new g_iUserJumpsCounter[MAX_PLAYERS + 1] = {0, ...};
new Float:g_fUserCooldownExpiresAt[MAX_PLAYERS + 1] = {0.0, ...};

public VipM_OnInitModules() {
    register_plugin(PluginName, PluginVersion, PluginAuthor);

    VipM_Modules_Register(MODULE_NAME, false);
    VipM_Modules_AddParams(MODULE_NAME,
        PARAM_COUNT_NAME, ptInteger, false,
        PARAM_VEL_MULT_NAME, ptFloat, false,
        PARAM_COOLDOWN_NAME, ptFloat, false
    );
    VipM_Modules_RegisterEvent(MODULE_NAME, Module_OnActivated, "@OnActivated");
    VipM_Modules_RegisterEvent(MODULE_NAME, Module_OnCompareParams, "@OnCompareParams");
}

public VipM_OnUserUpdated(const UserId) {
    new Trie:Params = VipM_Modules_GetParams(MODULE_NAME, UserId);

    g_iUserMaxJumps[UserId] = VipM_Params_GetInt(Params, PARAM_COUNT_NAME, 0);
    g_iUserVelocityMultiplier[UserId] = VipM_Params_GetFloat(Params, PARAM_VEL_MULT_NAME, 1.0);
    g_fUserCooldownDuration[UserId] = VipM_Params_GetFloat(Params, PARAM_COOLDOWN_NAME, 0.0);
}

public client_putinserver(UserId) {
    g_iUserMaxJumps[UserId] = 0;
    g_iUserJumpsCounter[UserId] = 0;
    g_iUserVelocityMultiplier[UserId] = 1.0;
}

@OnActivated() {
    RegisterHam(Ham_Player_Jump, "player", "@Hook_PlayerJump", false);
}

Trie:@OnCompareParams(const Trie:MainParams, const Trie:NewParams) {
    new iOld = VipM_Params_GetInt(MainParams, PARAM_COUNT_NAME, 0);
    new iNew = VipM_Params_GetInt(NewParams, PARAM_COUNT_NAME, 0);
    
    if (iOld < 0 || iOld >= iNew) {
        // Если надо оставить старые параметры, надо вернуть Invalid_Trie, иначе всё поломается)
        // TODO: Сделать в ядре проверку, что вернулся старый Trie
        // https://github.com/ArKaNeMaN/amxx-VipModular-pub/blob/master/amxmodx/scripting/VipM/Core/Modules/Units.inc#L91-L127
        
        return Invalid_Trie;
        // return MainParams;
    }

    return NewParams;
}

@Hook_PlayerJump(UserId){
    if (
        !g_iUserMaxJumps[UserId]
        || !is_user_alive(UserId)
    ) {
        return HAM_IGNORED;
    }

    new szButton = pev(UserId, pev_button);
    new szOldButton = pev(UserId, pev_oldbuttons);

    if (!(szButton & IN_JUMP)) {
        return HAM_IGNORED;
    }

    new Float:fGameTime = get_gametime();

    if (pev(UserId, pev_flags) & FL_ONGROUND) {
        if (g_iUserJumpsCounter[UserId] > 0 && g_fUserCooldownDuration[UserId] > 0.0) {
            g_fUserCooldownExpiresAt[UserId] = fGameTime + g_fUserCooldownDuration[UserId];
        }
        g_iUserJumpsCounter[UserId] = 0;
        return HAM_IGNORED;
    }

    if (
        !(szOldButton & IN_JUMP)
        && (
            g_iUserMaxJumps[UserId] < 0
            || g_iUserJumpsCounter[UserId] < g_iUserMaxJumps[UserId]
        )
        && (
            g_fUserCooldownExpiresAt[UserId] <= 0.0
            || g_fUserCooldownExpiresAt[UserId] <= fGameTime
        )
    ) {
        g_iUserJumpsCounter[UserId]++;
        
        new Float:szVelocity[3];
        pev(UserId, pev_velocity, szVelocity);
        szVelocity[2] = random_float(295.0, 305.0);
        szVelocity[2] *= g_iUserVelocityMultiplier[UserId];
        set_pev(UserId, pev_velocity, szVelocity);
    }

    return HAM_IGNORED;
}
