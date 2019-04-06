Config                 = {}
Config.DrawDistance    = 100.0
Config.Locale          = 'en'

Config.Zones = {
	 ls1 = {
		Pos   = { x = -211.427, y = -1323.703, z = 30.790},
		Size  = {x = 3.0, y = 3.0, z = 0.2},
		Color = {r = 204, g = 204, b = 0},
		Marker= 1,
		Name  = "Bennys Customs",
		Hint  = _U('press_custom')
    },
}

Config.Cars = {
	{veh = 'comet2', price = 10000, parent = {"comet3", "comet4", "comet5"}},
	{veh = 'comet3', price = 10000, parent = {"comet2", "comet4", "comet5"}},
	{veh = 'comet4', price = 10000, parent = {"comet2", "comet3", "comet5"}},
	{veh = 'comet5', price = 10000, parent = {"comet2", "comet3", "comet4"}},
	{veh = 'dubsta', price = 100000, parent = {"dubsta3"}},
}
