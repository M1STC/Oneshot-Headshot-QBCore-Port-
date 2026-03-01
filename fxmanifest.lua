local QBCore = exports["qb-core"]:GetCoreObject()

RegisterServerEvent("oneshotHead:requestKill")
AddEventHandler("oneshotHead:requestKill", function(victimNetId, weaponHash, victimCoords, dist)
    local attackerSrc = source
    local victimPed = NetworkGetEntityFromNetworkId(victimNetId)


    if not DoesEntityExist(victimPed) then
        return
    end

    local attackerPed = GetPlayerPed(attackerSrc)
    if not attackerPed then
        return
    end

    if NetworkGetEntityOwner(victimPed) == attackerSrc then
        return
    end

    local method = "bullet"

    TriggerClientEvent("oneshotHead:doKill", attackerSrc, victimCoords, weaponHash, method)
end)
