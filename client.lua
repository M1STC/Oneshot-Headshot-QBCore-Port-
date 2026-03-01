local QBCore = exports["qb-core"]:GetCoreObject()

local HEAD_BONE_HASH = 0x796E
local BULLET_DAMAGE = 1000

local RANGED_GROUPS = {
    [416676503]   = true,  -- GROUP_PISTOL
    [3337201093]  = true,  -- GROUP_SMG
    [860033945]   = true,  -- GROUP_RIFLE
    [970310034]   = true,  -- GROUP_SNIPER
    [1159398588]  = true,  -- GROUP_SHOTGUN
    [3082541095]  = true,  -- GROUP_HEAVY
    [2725924767]  = true,  -- GROUP_THROWABLE
    [-957766203]  = true   -- GROUP_MG
}

AddEventHandler('gameEventTriggered', function(evName, args)
    if evName == 'CEventNetworkEntityDamage' then
        local victim     = args[1]
        local attacker   = args[2]
        local weaponHash = args[7]

        if attacker ~= PlayerPedId() then
            return
        end

        local found, lastBone = GetPedLastDamageBone(victim)
        if not found or lastBone ~= HEAD_BONE_HASH then
            return
        end

        local sc = GetEntityCoords(attacker)
        local vc = GetEntityCoords(victim)
        local dist = #(sc - vc)
        local victimNetId = NetworkGetNetworkIdFromEntity(victim)

        TriggerServerEvent("oneshotHead:requestKill", victimNetId, weaponHash, vc, dist)
    end
end)

RegisterNetEvent("oneshotHead:doKill")
AddEventHandler("oneshotHead:doKill", function(victimCoords, weaponHash, method)
    local me = PlayerPedId()

    if method == "bullet" then
        local fromCoords = GetPedBoneCoords(me, 0x796E, 0.0, 0.0, 0.0)
        local toCoords = vector3(victimCoords.x, victimCoords.y, victimCoords.z + 0.1)

        ShootSingleBulletBetweenCoords(
            fromCoords.x, fromCoords.y, fromCoords.z,
            toCoords.x, toCoords.y, toCoords.z,
            BULLET_DAMAGE,
            true,
            weaponHash,
            me,
            true,
            false,
            5000.0
        )

    elseif method == "instant" then
        local victim = nil
        local players = GetActivePlayers()
        for _, id in ipairs(players) do
            local ped = GetPlayerPed(id)
            local pedCoords = GetEntityCoords(ped)
            if #(pedCoords - victimCoords) < 1.5 then 
                victim = ped
                break
            end
        end

        if victim and DoesEntityExist(victim) then
            SetEntityInvincible(victim, false)
            ClearPedTasksImmediately(victim)
            SetEntityHealth(victim, 0)
        end
    end
end)

AddEventHandler('playerSpawned', function()
    local me = PlayerPedId()
    Citizen.CreateThread(function()
        Wait(500)
        SetEntityInvincible(me, false)
        local maxHealth = GetEntityMaxHealth(me)
        SetEntityHealth(me, maxHealth - 1)  
    end)
end)
