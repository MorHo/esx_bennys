local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil
local menuOpened = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function checkUpgrades(model)
	local found = false
	for i=1, #Config.Cars, 1 do

		if GetHashKey(Config.Cars[i].veh) == model then
			found = {}
			table.insert(found, {label = _U(Config.Cars[i].veh) .. ' <span style="color: green">Current</span>', value = true, price = true})
			for j=1, #Config.Cars[i].parent do
				table.insert(found, {label = _U(Config.Cars[i].parent[j]) .. ' <span style="color: blue">$'.. Config.Cars[i].price ..'</span>', value = Config.Cars[i].parent[j], price = Config.Cars[i].price})
			end
		end

		if i == #Config.Cars then
			return found
		end

	end
end

function openUpgradeMenu()

	local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	local coords = GetEntityCoords(veh)
	local heading = GetEntityHeading(veh)
	local vehicleProps = ESX.Game.GetVehicleProperties(veh)
	local valid = checkUpgrades(vehicleProps.model)

	if valid then

		FreezeEntityPosition(veh, true)

		local elements = valid
		menuOpened = true

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'benny',
      {
        title    = "Benny's Motorworks",
        align    = 'top-left',
        elements = elements
      },
      function(data, menu)
				if data.current.value then
						if valid then
						ESX.TriggerServerCallback('esx_bennys:checkVehicle', function(paid)
							if paid then
								menu.close()
								menuOpened = false
								ESX.Game.SpawnVehicle(data.current.value,{
									x= -214.5190,
									y= -1297.1348,
									z= 31.2959
								}, heading, function(callback_vehicle)
									TriggerServerEvent('esx_bennys:removeVehicle', vehicleProps.plate)
									ESX.Game.DeleteVehicle(veh)
									SetVehRadioStation(callback_vehicle, "OFF")
									TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
									SetVehicleEngineOn(callback_vehicle, true, true, 0)
									local register = ESX.Game.GetVehicleProperties(callback_vehicle)
									TriggerServerEvent('esx_vehicleshop:setVehicleOwned', register)
									end)
							else
								ESX.ShowNotification(_U("not_owned"))
	    				end
						end, vehicleProps.plate, data.current.price)
					end
				end
      end,
      function(data, menu)
					menu.close()
					menuOpened = false
					FreezeEntityPosition(veh, false)
      end)
	else
		ESX.ShowNotification(_U('not_upgradable'))
	end
end

-- Blips
Citizen.CreateThread(function()

	for k,v in pairs(Config.Zones)do
		local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)
		SetBlipSprite(blip, 72)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(v.Name)
		EndTextCommandSetBlipName(blip)
	end
end)

-- In Bennys
Citizen.CreateThread(function()
	while true do
		Wait(10)
		local ped = GetPlayerPed(-1)
		local veh = GetVehiclePedIsIn(ped, false)
		if IsPedInAnyVehicle(ped, false) then
			local coords = GetEntityCoords(GetPlayerPed(-1))
			for k,v in pairs(Config.Zones) do
				if GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x and IsControlJustReleased(0, Keys['E']) then
					openUpgradeMenu()
					menuOpened = true
					Wait(500)
				elseif GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x and not menuOpened then
					SetTextComponentFormat("STRING")
					AddTextComponentString(v.Hint)
					DisplayHelpTextFromStringLabel(0, 0, 1, -1)
				end
			end
		end
	end
end)
