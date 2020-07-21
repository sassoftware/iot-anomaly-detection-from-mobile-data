--====================================================================--
-- Intelligent room App beta
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2020
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  Load data for hamburger or navigation items
  
--]]
local rgb = require ( "lib._rgb" )
----------------------------------------------------------------------------------------------------
local M = {}



M.themes = {
	
    { 
		clr_title = rgb.white , 
		clr_subtitle = rgb.black, 
		clr_header = rgb.darkturquoise2, 
		clr_header_over = rgb.darkturquoise2, 
        clr_subheader = rgb.grey, 
		clr_subheader_over = rgb.grey, 
		clr_body = rgb.lightgrey, 
		clr_box = rgb.white, 
		clr_text = rgb.darkslategray, 
		clr_line = rgb.lightgrey,
		clr_select = rgb.grey ,
		clr_inactive = rgb.grey 
		
	}, -- theme 1 
	{
		clr_title = rgb.white ,   -- text colors?
		clr_subtitle = rgb.black, 
		clr_header = rgb.bluesasdark,  -- background
		clr_header_over = rgb.blue, 
		clr_subheader = rgb.grey,  -- background 
		clr_subheader_over = rgb.grey, 
		clr_body = rgb.lightgrey, 
		clr_box = rgb.white, 
		clr_text = rgb.darkslategray,  -- body text
		clr_line = rgb.lightgrey,
		clr_background = rgb.white ,
		clr_select = rgb.grey ,
		clr_inactive = rgb.grey 
	},  -- theme 2
	defaulttheme = 2  -- which theme to use. 
} --themes 

M.defaultnavitem = 1 
M.hamburger = {  -- Nav items listed when hamburger is pressed. 
	
    { 
		title = "Home" , 
		modulename = "scene.intro",  -- module to load when picked
		infotext = "scene/intro/info.txt",  -- text in info box 
		navtype = "demo", 
		rowtype = "row",   --   spacer,  line ,  row,  category 
		icon = "pictures/home.png",
		isCategory = false,
		isVisible = true,
		isActive = true
		
	}, -- Nav 1 
	{ 
		title = "Sensors" , 
		modulename = "scene.sensors",  -- module to load when picked
		infotext = "scene/sensors/info.txt",  -- text in info box
		navtype = "demo", 
		rowtype = "row", 
		icon = "pictures/sensor.png",
		isCategory = false,
        isVisible = true ,
		isActive = true
		
	}, -- Nav 2 
	{
		title = "Broker Connections" , 
		modulename = "scene.brokers",  -- module to load when picked
		infotext = "scene/brokers/info.txt",  -- text in info box
		navtype = "connection", 
		rowtype = "row", 
		icon = "pictures/esp.png",
		isCategory = false,
        isVisible = true,
		isActive = true

	},  -- Nav 3
    {
		title = "Template Example" , 
		modulename = "scene.template",  -- module to load when picked
		infotext = "scene/template/info.txt",  -- text in info box
		navtype = "connection", 
		rowtype = "row", 
		icon = "pictures/esp.png",
		isCategory = false,
        isVisible = false,
		isActive = true  

	},  -- Nav 4
    {
		title = "Anomaly Detection" , 
		modulename = "scene.anomalydetection",  -- module to load when picked
		infotext = "scene/anomalydetection/info.txt",  -- text in info box
		navtype = "connection", 
		rowtype = "row", 
		icon = "pictures/esp.png",
		isCategory = false,
        isVisible = true,
		isActive = true  

	},  -- Nav 5
    
} --hamburger 
	



function M:loadtheme( number )
	
    return self.themes[number]

end
function M:loadnav( number )
	
    return self.hamburger[number]

end


return M
