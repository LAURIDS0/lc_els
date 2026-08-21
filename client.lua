local lightsOn = false
local sirenOn = false
local sirenMode = 1

local currentVehicle = 0

-- Lokale lyde
local sirenSoundId = nil
local hornSoundId = nil

-- Lyde fra andre spillere
local networkSirens = {}
local networkHorns = {}

-- ELS light state fra andre spillere
local networkELS = {}


--========================================================--
-- LOCAL SIREN
--========================================================--

local function stopSirenSound()

    if not sirenSoundId then
        return
    end

    StopSound(sirenSoundId)
    ReleaseSoundId(sirenSoundId)

    sirenSoundId = nil
end


local function startSirenSound(vehicle)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    stopSirenSound()

    local selectedSiren = Config.Sirens[sirenMode]

    if not selectedSiren then
        return
    end

    sirenSoundId = GetSoundId()

    PlaySoundFromEntity(
        sirenSoundId,
        selectedSiren.sound,
        vehicle,
        0,
        false,
        0
    )
end


--========================================================--
-- NETWORK SIREN
--========================================================--

local function stopNetworkSiren(vehicleNetId)

    local soundId = networkSirens[vehicleNetId]

    if not soundId then
        return
    end

    StopSound(soundId)
    ReleaseSoundId(soundId)

    networkSirens[vehicleNetId] = nil
end


local function startNetworkSiren(vehicleNetId, mode)

    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    local selectedSiren = Config.Sirens[mode]

    if not selectedSiren then
        return
    end

    stopNetworkSiren(vehicleNetId)

    local soundId = GetSoundId()

    PlaySoundFromEntity(
        soundId,
        selectedSiren.sound,
        vehicle,
        0,
        false,
        0
    )

    networkSirens[vehicleNetId] = soundId
end


--========================================================--
-- LOCAL HORN
--========================================================--

local function stopHornSound()

    if not hornSoundId then
        return
    end

    StopSound(hornSoundId)
    ReleaseSoundId(hornSoundId)

    hornSoundId = nil
end


local function startHornSound(vehicle)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    stopHornSound()

    hornSoundId = GetSoundId()

    PlaySoundFromEntity(
        hornSoundId,
        Config.Horn.sound,
        vehicle,
        0,
        false,
        0
    )
end


--========================================================--
-- NETWORK HORN
--========================================================--

local function stopNetworkHorn(vehicleNetId)

    local soundId = networkHorns[vehicleNetId]

    if not soundId then
        return
    end

    StopSound(soundId)
    ReleaseSoundId(soundId)

    networkHorns[vehicleNetId] = nil
end


local function startNetworkHorn(vehicleNetId)

    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    stopNetworkHorn(vehicleNetId)

    local soundId = GetSoundId()

    PlaySoundFromEntity(
        soundId,
        Config.Horn.sound,
        vehicle,
        0,
        false,
        0
    )

    networkHorns[vehicleNetId] = soundId
end


--========================================================--
-- NETWORK LIGHT STATE
--========================================================--

local function setNetworkELS(vehicleNetId, enabled)

    networkELS[vehicleNetId] = enabled
end


--========================================================--
-- NETWORK EVENTS
--========================================================--

RegisterNetEvent('lc_els:sirenState', function(
    vehicleNetId,
    active,
    mode,
    sourcePlayer
)

    -- Den spiller der selv startede sirenen
    -- har allerede sin lokale lyd.
    if sourcePlayer == GetPlayerServerId(PlayerId()) then
        return
    end

    if active then
        startNetworkSiren(
            vehicleNetId,
            mode
        )
    else
        stopNetworkSiren(
            vehicleNetId
        )
    end
end)


RegisterNetEvent('lc_els:hornState', function(
    vehicleNetId,
    active,
    sourcePlayer
)

    -- Den spiller der selv bruger hornet
    -- har allerede sin lokale lyd.
    if sourcePlayer == GetPlayerServerId(PlayerId()) then
        return
    end

    if active then
        startNetworkHorn(
            vehicleNetId
        )
    else
        stopNetworkHorn(
            vehicleNetId
        )
    end
end)


RegisterNetEvent('lc_els:lightState', function(
    vehicleNetId,
    active,
    sourcePlayer
)

    setNetworkELS(
        vehicleNetId,
        active
    )
end)


--========================================================--
-- STATE
--========================================================--

local function resetSiren(vehicle)

    if vehicle == 0 then
        return
    end

    stopSirenSound()

    sirenOn = false
    sirenMode = 1

    SetVehicleHasMutedSirens(
        vehicle,
        true
    )
end


local function resetELS(vehicle)

    if vehicle == 0 then
        return
    end

    resetSiren(vehicle)

    lightsOn = false

    SetVehicleHasMutedSirens(
        vehicle,
        true
    )

    SetVehicleSiren(
        vehicle,
        false
    )
end


--========================================================--
-- VEHICLE
--========================================================--

local function isEmergencyVehicle(vehicle)

    if vehicle == 0 then
        return false
    end

    if not Config.EmergencyOnly then
        return true
    end

    return GetVehicleClass(vehicle) == 18
end


local function getPlayerVehicle()

    local ped = PlayerPedId()

    local vehicle = GetVehiclePedIsIn(
        ped,
        false
    )

    if vehicle == 0 then
        return 0
    end

    -- Kun føreren kan bruge ELS.
    if GetPedInVehicleSeat(
        vehicle,
        -1
    ) ~= ped then

        return 0
    end

    if not isEmergencyVehicle(vehicle) then
        return 0
    end

    return vehicle
end


local function getVehicleNetId(vehicle)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 0
    end

    return NetworkGetNetworkIdFromEntity(
        vehicle
    )
end


--========================================================--
-- NETWORK SYNC
--========================================================--

local function syncSiren(
    vehicle,
    active,
    mode
)

    local netId = getVehicleNetId(
        vehicle
    )

    if netId == 0 then
        return
    end

    TriggerServerEvent(
        'lc_els:sirenState',
        netId,
        active,
        mode
    )
end


local function syncHorn(
    vehicle,
    active
)

    local netId = getVehicleNetId(
        vehicle
    )

    if netId == 0 then
        return
    end

    TriggerServerEvent(
        'lc_els:hornState',
        netId,
        active
    )
end


local function syncLights(
    vehicle,
    active
)

    local netId = getVehicleNetId(
        vehicle
    )

    if netId == 0 then
        return
    end

    TriggerServerEvent(
        'lc_els:lightState',
        netId,
        active
    )
end


--========================================================--
-- KEEP NATIVE SIRENS MUTED
--========================================================--

CreateThread(function()

    while true do

        Wait(0)

        for vehicleNetId, enabled in pairs(networkELS) do

            local vehicle =
                NetworkGetEntityFromNetworkId(
                    vehicleNetId
                )

            if vehicle ~= 0
            and DoesEntityExist(vehicle) then

                if enabled then

                    SetVehicleHasMutedSirens(
                        vehicle,
                        true
                    )

                else

                    networkELS[vehicleNetId] = nil
                end

            else

                networkELS[vehicleNetId] = nil
            end
        end
    end
end)


--========================================================--
-- MAIN
--========================================================--

CreateThread(function()

    while true do

        Wait(0)

        local vehicle =
            getPlayerVehicle()


        --================================================--
        -- PLAYER LEFT VEHICLE
        --================================================--

        if vehicle == 0 then

            if currentVehicle ~= 0 then

                local netId =
                    getVehicleNetId(
                        currentVehicle
                    )

                -- Lys bliver.
                -- Sirene og horn stopper.

                resetSiren(
                    currentVehicle
                )

                stopHornSound()

                if netId ~= 0 then

                    TriggerServerEvent(
                        'lc_els:sirenState',
                        netId,
                        false,
                        1
                    )

                    TriggerServerEvent(
                        'lc_els:hornState',
                        netId,
                        false
                    )
                end

                currentVehicle = 0
            end

            goto continue
        end


        --================================================--
        -- VEHICLE CHANGED
        --================================================--

        if currentVehicle ~= 0
        and currentVehicle ~= vehicle then

            local oldNetId =
                getVehicleNetId(
                    currentVehicle
                )

            resetELS(
                currentVehicle
            )

            stopHornSound()

            if oldNetId ~= 0 then

                TriggerServerEvent(
                    'lc_els:sirenState',
                    oldNetId,
                    false,
                    1
                )

                TriggerServerEvent(
                    'lc_els:hornState',
                    oldNetId,
                    false
                )

                TriggerServerEvent(
                    'lc_els:lightState',
                    oldNetId,
                    false
                )
            end

            lightsOn = false
            sirenOn = false
            sirenMode = 1
        end

        currentVehicle = vehicle


        --================================================--
        -- E - HORN
        --================================================--

        DisableControlAction(
            0,
            Config.Keys.horn,
            true
        )


        if IsDisabledControlJustPressed(
            0,
            Config.Keys.horn
        ) then

            startHornSound(
                vehicle
            )

            syncHorn(
                vehicle,
                true
            )
        end


        if IsDisabledControlJustReleased(
            0,
            Config.Keys.horn
        ) then

            stopHornSound()

            syncHorn(
                vehicle,
                false
            )
        end


        --================================================--
        -- Q - LIGHTS
        --================================================--

        if IsControlJustPressed(
            0,
            Config.Keys.lights
        ) then

            lightsOn = not lightsOn

            if lightsOn then

                -- Lys ON.
                -- Sirene OFF.

                sirenOn = false
                sirenMode = 1

                stopSirenSound()

                SetVehicleSiren(
                    vehicle,
                    true
                )

                SetVehicleHasMutedSirens(
                    vehicle,
                    true
                )

                syncLights(
                    vehicle,
                    true
                )

            else

                -- Lys OFF.
                -- Sirene OFF.

                local netId =
                    getVehicleNetId(
                        vehicle
                    )

                resetELS(
                    vehicle
                )

                if netId ~= 0 then

                    TriggerServerEvent(
                        'lc_els:sirenState',
                        netId,
                        false,
                        1
                    )

                    TriggerServerEvent(
                        'lc_els:lightState',
                        netId,
                        false
                    )
                end
            end
        end


        --================================================--
        -- ALT - PERMANENT SIREN
        --================================================--

        if IsControlJustPressed(
            0,
            Config.Keys.siren
        ) then

            if not sirenOn then

                -- Starter altid på WAIL.

                sirenMode = 1
                sirenOn = true

                SetVehicleSiren(
                    vehicle,
                    true
                )

                SetVehicleHasMutedSirens(
                    vehicle,
                    true
                )

                startSirenSound(
                    vehicle
                )

                syncSiren(
                    vehicle,
                    true,
                    sirenMode
                )

            else

                sirenOn = false

                stopSirenSound()

                SetVehicleHasMutedSirens(
                    vehicle,
                    true
                )

                syncSiren(
                    vehicle,
                    false,
                    sirenMode
                )
            end
        end


        --================================================--
        -- R - MOMENTARY / CYCLE
        --================================================--

        if sirenOn then

            -- ALT er aktiv.
            -- R skifter sirenetype.

            if IsControlJustPressed(
                0,
                Config.Keys.cycle
            ) then

                sirenMode =
                    sirenMode + 1

                if sirenMode >
                    #Config.Sirens then

                    sirenMode = 1
                end

                startSirenSound(
                    vehicle
                )

                syncSiren(
                    vehicle,
                    true,
                    sirenMode
                )
            end

        else

            -- ALT er ikke aktiv.
            -- R er momentary WAIL.

            if IsControlJustPressed(
                0,
                Config.Keys.cycle
            ) then

                sirenMode = 1

                startSirenSound(
                    vehicle
                )

                syncSiren(
                    vehicle,
                    true,
                    sirenMode
                )
            end


            if IsControlJustReleased(
                0,
                Config.Keys.cycle
            ) then

                stopSirenSound()

                syncSiren(
                    vehicle,
                    false,
                    sirenMode
                )
            end
        end


        ::continue::

    end
end)