ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_bennys:checkVehicle', function(source, cb, plate, price)
	local xPlayer = ESX.GetPlayerFromId(source)

	local data = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner=@identifier",{['@identifier'] = xPlayer.getIdentifier()})	
	for _,v in pairs(data) do
		if v.plate == plate then
			if xPlayer.getMoney() > price then
				xPlayer.removeMoney(price)
				MySQL.Sync.execute("DELETE owned_vehicles WHERE plate = @plate",{['@plate'] = plate})
				cb(true)
				TriggerClientEvent('esx:showNotification', source, _U('paid') .. price)
			else
				cb(false)
				TriggerClientEvent('esx:showNotification', source, _U('no_money'))
			end
		else
			cb(false)
			TriggerClientEvent('esx:showNotification', source, _U("not_owned"))
		end
	end
end)

ESX.RegisterServerCallback('esx_bennys:payUpgrade', function(source, cb, price)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() > price then
		xPlayer.removeMoney(price)
		cb(true)
		TriggerClientEvent('esx:showNotification', source, _U('paid') .. price)
	else
		cb(false)
		TriggerClientEvent('esx:showNotification', source, _U('no_money'))
	end
end)

RegisterNetEvent('esx_bennys:removeVehicle')
AddEventHandler('esx_bennys:removeVehicle', function (plate)
	local data = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner=@identifier",{['@identifier'] = identifier})	
	for _,v in pairs(data) do
		local vehicle = json.decode(v.vehicle)
		table.insert(vehicles, {id = v.id, plate = v.plate})
	end
	return vehicles
end)