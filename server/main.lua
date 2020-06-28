ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('marijuana', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('marijuana', 1)

	TriggerClientEvent('esx_status:add', source, 'drug', 166000)
	TriggerClientEvent('esx_lwrpdrugeffects:onWeed', source)
end)

ESX.RegisterUsableItem('poppyresin', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('poppyresin', 1)

	TriggerClientEvent('esx_status:add', source, 'drug', 166000)
	TriggerClientEvent('esx_lwrpdrugeffects:onMorphine', source)
end)

ESX.RegisterUsableItem('heroin', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('heroin', 1)

	TriggerClientEvent('esx_status:add', source, 'drug', 249000)
	TriggerClientEvent('esx_lwrpdrugeffects:onHeroin', source)
end)

ESX.RegisterUsableItem('meth', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('meth', 1)

	TriggerClientEvent('esx_status:add', source, 'drug', 333000)
	TriggerClientEvent('esx_lwrpdrugeffects:onMeth', source)
end)

ESX.RegisterUsableItem('coca_leaf', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('coca_leaf', 1)

	TriggerClientEvent('esx_status:add', source, 'drug', 499000)
	TriggerClientEvent('esx_lwrpdrugeffects:onCocaleaf', source)
end)

ESX.RegisterUsableItem('coke', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('coke', 1)

	TriggerClientEvent('esx_status:add', source, 'drug', 499000)
	TriggerClientEvent('esx_lwrpdrugeffects:onCoke', source)
end)

ESX.RegisterUsableItem('xanax', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('xanax', 1)

	TriggerClientEvent('esx_status:remove', source, 'drug', 249000)
end

ESX.RegisterUsableItem('lsd'), function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeInventoryItem('lsd', 1)

    TriggerClientEvent('esx_status:add'), source, 'drug', 249000
    TriggerClientEvent('esx_lwrpdrugeffects:onLSD')
end

ESX.RegisterUsableItem('lsa'), function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeInventoryItem('lsa', 1)

    TriggerClientEvent('esx_status:add'), source, 'drug', 249000
    TriggerClientEvent('esx_lwrpdrugeffects:onLSA')
end
