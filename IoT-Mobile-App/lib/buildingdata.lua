--====================================================================--
-- Intelligent room App beta
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2016
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  Load data for level and return
  
--]]
local rgb = require ( "lib._rgb" )
----------------------------------------------------------------------------------------------------
local buildingdata = {}

buildingdata.themes = {
	
    { 
		title = "Intelligent Monitoring",
		title_clr = rgb.white , 
		subtitle = "Building Overview", 
		subtitle_clr = rgb.black, 
		clr_header = rgb.darkturquoise2, 
		clr_header_over = rgb.darkturquoise2, 
		clr_body = rgb.lightgrey, 
		clr_box = rgb.white, 
		clr_text = rgb.darkslategray, 
		clr_line = rgb.lightgrey,
		clr_select = rgb.grey ,
		clr_inactive = rgb.grey 
		
	}, -- theme 1 
	{
		title = "Early Warning System",
		title_clr = rgb.white , 
		subtitle = "Tank Overview", 
		subtitle_clr = rgb.black, 
		clr_header = rgb.bluemedium, 
		clr_header_over = rgb.blue, 
		clr_body = rgb.lightgrey, 
		clr_box = rgb.white, 
		clr_text = rgb.darkslategray, 
		clr_line = rgb.lightgrey,
		clr_select = rgb.grey ,
		clr_inactive = rgb.grey 
	},  -- theme 2
	activetheme = 2
} --themes 
	
buildingdata.buildings = { 
	{	
		buildingname = "C",
		buildingpic = "pictures/ewr-term-C.png",
		buildingpicaspect = .7177,
		floors = {  
			{
				floorname = "1",
				rooms = {
					{
						roomname = "room4af",
						customerSAT = 4 ,
						status = "1",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargreen.png",
						positionX = 8, 
						positionY = 27, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  2,      .400,       10        },
						{'Feb',  11,      1.460,      3        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  10,      .540,       2        }
						},
						
						WorkTasks = {
							{
								WTtitle = "Room too hot",
								WTasset = "Temp",
								WTtime =  "2.2 hours"
							}
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4b1",
						customerSAT = 1 ,
						status = "3",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/starred.png",
						positionX = 50, 
						positionY = 11, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  4,      .800,       6        },
						{'Feb',  1,      1.460,      9        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        2        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  12,      .540,       2        }
						},
						WorkTasks = {
							{
								WTtitle = "Cleaning Needed",
								WTasset = "Maint",
								WTtime =  "2.2 hours"
							},
							{
								WTtitle = "Bulb Replacement",
								WTasset = "Lighting",
								WTtime =  "1.3 hours"
							},
							{
								WTtitle = "Over Crowded",
								WTasset = "n/a",
								WTtime =  "1 hours"
							},
							
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4b3",
						customerSAT = 3 ,
						status = "2",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargold.png",
						positionX = 17, 
						positionY = 35, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  4,      .400,       10        },
						{'Feb',  11,      1.460,      6        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  3,      1.800,      8        },
						{'May',  1,      .7,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  4,      .9,       6        }
						},
						WorkTasks = {
							{
								WTtitle = "Bulb Replacement",
								WTasset = "Lighting",
								WTtime =  "1.3 hours"
							},
							
							
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4b5",
						customerSAT = 3 ,
						status = "2",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargold.png",
						positionX = 25, 
						positionY = 42, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  2,      .400,       10        },
						{'Feb',  2,      .460,      3        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  2,      1.800,      9        },
						{'May',  1,      .460,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  10,      .540,       2        }
						},
						WorkTasks = {
							{
								WTtitle = "Cleaning Needed",
								WTasset = "Maint",
								WTtime =  "2.2 hours"
							},
							
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4b7",
						customerSAT = 4 ,
						status = "1",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargreen.png",
						positionX = 50, 
						positionY = 22, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  2,      .400,       10        },
						{'Feb',  11,      1.460,      3        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  10,      .540,       2        }
						},
						WorkTasks = {
						
							{
								WTtitle = "Cleaning Needed",
								WTasset = "Maint",
								WTtime =  "2.2 hours"
							},
							{
								WTtitle = "Room too cold",
								WTasset = "Temp",
								WTtime =  "2.2 hours"
							}
							
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4b9",
						customerSAT = 3 ,
						status = "1",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargold.png",
						positionX = 42, 
						positionY = 83, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  2,      .400,       10        },
						{'Feb',  11,      1.460,      3        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  10,      .540,       2        }
						},
						WorkTasks = {
							{
								WTtitle = "Window Broken",
								WTasset = "Maint",
								WTtime =  "2.2 hours"
							}
							
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4bb",
						customerSAT = 4 ,
						status = "1",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargreen.png",
						positionX = 60, 
						positionY = 51, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  2,      .400,       10        },
						{'Feb',  11,      1.460,      3        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  10,      .540,       2        }
						},
						WorkTasks = {
							{
								WTtitle = "Window open",
								WTasset = "Security",
								WTtime =  "8.2 hours"
							},
							{
								WTtitle = "Room too cold",
								WTasset = "Temp",
								WTtime =  "2.2 hours"
							}
							
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4bd",
						customerSAT = 4 ,
						status = "1",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargreen.png",
						positionX = 57, 
						positionY = 68, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  2,      .400,       10        },
						{'Feb',  11,      1.460,      3        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  10,      .540,       2        }
						},
						WorkTasks = {
							{
								WTtitle = "Window open",
								WTasset = "Security",
								WTtime =  "8.2 hours"
							}
						
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4bf",
						customerSAT = 4 ,
						status = "1",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargreen.png",
						positionX = 71, 
						positionY = 45, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  2,      .400,       10        },
						{'Feb',  11,      1.460,      3        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  10,      .540,       2        }
						},
						WorkTasks = {
							{
								WTtitle = "Room too cold",
								WTasset = "Temp",
								WTtime =  "2.2 hours"
							}
							
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4c1",
						customerSAT = 4 ,
						status = "1",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargreen.png",
						positionX = 79, 
						positionY = 12, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  2,      .400,       10        },
						{'Feb',  11,      1.460,      3        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  10,      .540,       2        }
						},
						WorkTasks = {
							{
								WTtitle = "Room too cold",
								WTasset = "Temp",
								WTtime =  "2.2 hours"
							}
							
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4c5",
						customerSAT = 2 ,
						status = "2",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargold.png",
						positionX = 97, 
						positionY = 33, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  2,      .400,       10        },
						{'Feb',  11,      1.460,      3        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  10,      .540,       2        }
						},
						WorkTasks = {
							{
								WTtitle = "Over Crowded",
								WTasset = "n/a",
								WTtime =  "1 hours"
							},
							
						},
						lastthing = nil
					},  -- room entry
				},  -- array of rooms
			},	-- array of floors
		},  --  floors
	}, -- building
	{	
		buildingname = "A",
		buildingpic = "pictures/ewr-term-A.png",
		buildingpicaspect = .5980,
		floors = {  
			{
				floorname = "1",
				rooms = {
					{
						roomname = "room4af",
						customerSAT = 4 ,  -- poor, fair, good, excellent
						status = "1",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargreen.png",
						positionX = 8, 
						positionY = 26, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  8,      .400,       8        },
						{'Feb',  33,      1.460,      1        }, 
						{'Mar',  4,      .460,       9        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        10        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  1,      .540,       9        }
						},
						WorkTasks = {
							{
								WTtitle = "Over Crowded",
								WTasset = "Towel2",
								WTtime =  "1 hours"
							},
							{
								WTtitle = "Room too hot",
								WTasset = "Temp",
								WTtime =  "2.2 hours"
							}
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4b1",
						customerSAT = 2 ,
						status = "2",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/stargold.png",
						positionX = 50, 
						positionY = 15, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata = {
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  2,      .400,       10        },
						{'Feb',  11,      1.460,      3        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  10,      .540,       2        }
						},
						WorkTasks = {
							{
								WTtitle = "Room too cold",
								WTasset = "Temp",
								WTtime =  "2.2 hours"
							}
						},
						lastthing = nil
					},  -- room entry
					{
						roomname = "room4b3",
						customerSAT = 1 ,
						status = "3",   -- 1 = green  2 = yellow  3 = red
						imagename = "pictures/starred.png",
						positionX = 90, 
						positionY = 30, 
						isBuilt = false,
						sizeX = 12,
						sizeY = 12,
						alpha = 1,  --  0 is invisible, 1 is fully solid
						usagedata =  {
						{'Year', 'WO', 'Costs  K ' , 'Cus Sat' },
						{'Jan',  2,      .400,       10        },
						{'Feb',  11,      1.460,      3        }, 
						{'Mar',  11,      .460,       4        },
						{'Apr',  20,      1.800,      1        },
						{'May',  1,      .460,        9        },
						{'Jun',  6,       1.120,      7        },
						{'Jul',  10,      .540,       2        }
						},
						WorkTasks = {
							{
								WTtitle = "Room too hot",
								WTasset = "Temp",
								WTtime =  "2.2 hours"
							}
						},
						lastthing = nil
					},  -- room entry
				},  -- array of rooms
			},	-- array of floors
		},  --  floors
	}, -- buildin
}  -- top


function buildingdata:loadtheme( number )
	
    return self.themes[number]

end

function buildingdata:loadbuilding( buildingnum , floornum )
	
    return self.buildings[buildingnum]

end

function buildingdata:loadfloors( buildingnum  )
	
    return self.buildings[buildingnum].floors

end

function buildingdata:loadbuildings(  )  --  building records.  
	
    return self.buildings
end
 
function buildingdata:loadrooms( buildingnum , floornum )
	
    return self.buildings[buildingnum].floors[floornum].rooms

end
return buildingdata
