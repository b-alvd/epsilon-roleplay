Config = {}

Config.Language = "en"

Config.MenuPosition = "left"
Config.MenuPositions = {
	right = {x = 1450, y = 80},
	left = {x = 0, y = 80}--{x = 0, y = 200}
}

Config.Translation = {
    en = {
        back = "Back",
        select = "Select",
        none = "Nothing",
        menu_header = "Elevator",
        menu_title = "CHOOSE FLOOR",
        notification = "Press ~INPUT_CONTEXT~ to use elevator",
        same_floor = "You're already on this floor"
    }
}

Config.Elevators = {
	{
		label = 'Mission Row Police Department',
		floors = {
			{coords = vector4(472.93124389648,-983.66314697266,30.710315704346, 92.7), label = 'Floor 1'},
			{coords = vector4(472.93124389648,-983.66314697266,26.381330490112, 92.7), label = 'Floor -1'},	
			{coords = vector4(472.93124389648,-983.66314697266,35.686016082764, 92.7), label = 'Floor 2'},
			{coords = vector4(472.93124389648,-983.66314697266,43.687118530273, 92.7), label = 'Roof'},									
		}
	},
}

Config.ActivateRadius = 2.5
