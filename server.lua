RegisterNetEvent('lc_els:sirenState', function(
    vehicleNetId,
    active,
    mode
)

    local sourcePlayer = source

    TriggerClientEvent(
        'lc_els:sirenState',
        -1,
        vehicleNetId,
        active,
        mode,
        sourcePlayer
    )
end)


RegisterNetEvent('lc_els:hornState', function(
    vehicleNetId,
    active
)

    local sourcePlayer = source

    TriggerClientEvent(
        'lc_els:hornState',
        -1,
        vehicleNetId,
        active,
        sourcePlayer
    )
end)


RegisterNetEvent('lc_els:lightState', function(
    vehicleNetId,
    active
)

    local sourcePlayer = source

    TriggerClientEvent(
        'lc_els:lightState',
        -1,
        vehicleNetId,
        active,
        sourcePlayer
    )
end)