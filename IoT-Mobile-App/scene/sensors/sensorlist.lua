
--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - build the list of sensor data in a tableView
  

--]]
local Glb = require ( "lib.glbldata" )  -- trick for global variables
local rgb = require ( "lib._rgb" )
local Json   = require ("json")
local Widget = require( "widget" )
local theme = Glb.theme 
local Misc  = require ("lib.miscfunctions")  -- non OO helper functions
local misc = Misc:new() 

local M = {}
local M_mt = { __index = M }

local spinner


local tableViewColors = {
		rowColor = { default =  theme.clr_title , over =  theme.clr_select  },
		rowtextColor =  theme.clr_text  ,
		lineColor = theme.clr_line,
		headerColor = { default =  theme.clr_header  , over = theme.clr_header  },
		headertextColor = theme.clr_subtitle ,
		catColor = { default = theme.clr_line , over = theme.clr_select  },
		cattextColor = theme.clr_subtitle,
		inactiveColor = { default = theme.clr_title , over = theme.clr_title  },
		inactivetextColor = theme.clr_select
		}

-- return new object
function M:new(options)

    local self = {}
    setmetatable( self, M_mt )  --  new object inherits from M
	self:loadnew(options)  -- load function 
    return self
end

function M:loadnew(options)

    self.stageDG = options.stage 
    local stage = self.stageDG
	local nav_width = options.width or 250 
	local nav_height = options.height or display.actualContentHeight 
	-- Misc:printtable(navitems)
	
	------------------
	-- variables
	------------------
	
	spinner = Widget.newSpinner({ 
        width = 32, 
        height = 32, 
    })
    
    spinner.x = display.contentCenterX
    spinner.y = Glb.bodycontenttop + (spinner.contentHeight / 2 )
    spinner.isVisible = false
    self.spinner = spinner 
	
	
	------------------
	-- Display Objects
	------------------
	
	local _W, _H = display.contentWidth, display.contentHeight
	-- local popup = display.newRect(localGroup, 100, 100 , 100, 100 )
	-- popup.anchorX , popup.anchorY = 0,0  --  anchor object at top left corner
	
	-- Forward references
	local tableView2
	
	------------------
	-- Listeners
	------------------
	
	-- Handle row rendering.  called when row is inserted into table.
	local function onRowRender( event )
		local row = event.row
		local parms = event.row.params
            
		local rowContentHeight = row.contentHeight
		local rowContentWidth = row.contentWidth
		
		
		if ( parms ) then 
            row.rowTitle = display.newText( row, "default", 0, 0,  native.systemFont, 18 )
            row.rowTitle.x = 4
            row.rowTitle.anchorX = 0
            row.rowTitle.anchorY = .5
            row.rowTitle.y = rowContentHeight * 0.5
            row.rowTitle.x = rowContentWidth * 0.02
            
            row.rowValue = display.newText( row, "?", 0, 0,  native.systemFont, 18 )
            row.rowValue.x = 4
            row.rowValue.anchorX = 0
            row.rowValue.anchorY = .5
            row.rowValue.y = rowContentHeight * 0.5
            row.rowValue.x = rowContentWidth * 0.60
            
            if ( parms.rowtype == "spacer" ) then
                -- print ("RowRender:  spacer")
                 row.rowTitle:setFillColor( unpack(tableViewColors.headertextColor) )
                 row.rowTitle.text = ""
                 row.rowValue:setFillColor( unpack(tableViewColors.headertextColor) )
                 row.rowValue.text = ""
            elseif (parms.rowtype == "category") then
                -- print ("RowRender:  category")
                 row.rowTitle:setFillColor( unpack(tableViewColors.cattextColor) )
                 row.rowTitle.text = parms.title
                 row.rowValue:setFillColor( unpack(tableViewColors.headertextColor) )
                 row.rowValue.text = ""
            elseif (parms.rowtype == "line") then   --  spacer line
                -- print ("RowRender:  line")
                 row.rowTitle:setFillColor( unpack(tableViewColors.cattextColor) )
                 row.rowTitle.text = "-------------------------------"	
                 row.rowValue:setFillColor( unpack(tableViewColors.headertextColor) )
                 row.rowValue.text = ""
            else 	
                -- print ("RowRender:  row")
                if parms.isActive then 
                    row.rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
                    row.rowValue:setFillColor( unpack(tableViewColors.rowtextColor) )
                else 
                    row.rowTitle:setFillColor( unpack(tableViewColors.inactivetextColor) )
                    row.rowValue:setFillColor( unpack(tableViewColors.inactivetextColor) )
                end 
                row.rowTitle.text = parms.title
                row.rowValue.text = tostring(parms.value)
                
                
            end
            row:insert(row.rowTitle)
            row:insert(row.rowValue)
        end     
    return true
	end
    
    local function isGetPositionAvailable( event )
        local answer = false 
         if (event.target.parent.parent.getContentPosition) then 
            answer = true 
         -- else print ("ignore")   
        end 
    return  answer 
    end 
    
    local springStart = 0
    local needToReload = false
	
	-- Listen for tableView touch and scroll events
	local function tableViewListener( event )
		local phase = event.phase
        -- print ("event.direction",event.direction)
        -- print ("event.limitReached",event.limitReached)
        
        if ( event.phase == "began" and isGetPositionAvailable(event)) then
            -- print ("tableViewListener: began ", event.target.parent.parent:getContentPosition())
            springStart = event.target.parent.parent:getContentPosition()
            needToReload = false
        elseif ( event.phase == "moved" and isGetPositionAvailable(event)) then
            -- print ("tableViewListener: moved ", event.target.parent.parent:getContentPosition())
            if ( event.target.parent.parent:getContentPosition() > springStart + 30 and event.target.parent.parent:getContentPosition() > 0 ) then
                needToReload = true
                if not spinner.isVisible  then
                    spinner.isVisible = true
                    spinner:start()
                end
                
            end
        elseif ( event.limitReached == true and event.phase == nil and event.direction == "down" and needToReload == true ) then
            -- print( "tableViewListener:  Reloading Table!" )
            spinner:stop()
            spinner.isVisible = false
            needToReload = false
            self:reloadrows()
        end
    return true
	end
	
	
	-- Handle touches on the row
	local function onRowTouch( event )
		local phase = event.phase
		local row = event.target
		local parms = row.params
		-- misc:printtableD(row, 2 )
		if ( "release" == phase ) then
			print ("User selected row " .. row.index )
			
			-- if parms.isActive then 
				-- composer.hideOverlay("fade", 500 )
				-- callback({row.index},parms)
			-- end  -- can't select header.
			
		end
	end
	
		-- Create a tableView
			tableView2 = Widget.newTableView
			{
				top =  Glb.bodycontenttop ,
				left = 0,
                -- isBounceEnabled = false,
				width = display.contentWidth , 
				height = display.contentHeight - Glb.bodycontenttop ,
				--hideBackground = true,
				listener = tableViewListener,
				onRowRender = onRowRender,
				--onRowUpdate = onRowUpdate,
				onRowTouch = onRowTouch
			}
            --print ("width stuff ",nav_width, stage.contentHeight + 50 )
            self.tableView2 = tableView2
    self:loadrows(options)  -- load function 
            
end 

function M:reloadrows()
        local saved_location = self.tableView2:getContentPosition()
        self.tableView2:deleteAllRows()
        self:loadrows()  -- load function 
        self.tableView2:scrollToY({y=saved_location, time=1})  -- move back to scrolled location after reload 
return 
end 
            
		
function M:loadrows()            
		
        local stage = self.stageDG
        
		-- Create rows
		local rowparmsG = {
            title = "Gyroscope",
            value = 0,
            rowtype = "category", --   spacer,  line ,  row,  category 
            isCategory = true   ,
            isActive = true 
        }
        local optionsG = {  -- create row options 
            --id = nil , 
            rowHeight = 50 , 
            rowColor = tableViewColors.catColor , 
            lineColor = tableViewColors.rowColor , 
            isCategory = true  , 
            params = rowparmsG
            
            }
        ------------------------------
        --  Load first category
        ------------------------------
                
        self.tableView2:insertRow(optionsG)
        
        
        ------------------------------
        --  Load rows 
        ------------------------------
        
        ------------------------------
        --  gyroscope data
        ------------------------------
        
        if self.stageDG.gyroscope.isActive  then 
        
            local gyroscope_values = self.stageDG.gyroscope.data
                for k, v in pairs( gyroscope_values ) do
                    
                    local options = {  -- create row options 
                            --id = nil , 
                            rowHeight = 50 , 
                            rowColor = tableViewColors.rowColor , 
                            lineColor = tableViewColors.rowColor , 
                            isCategory = false , 
                            params = {
                                title = "text here",
                                value = 0,
                                rowtype = "row", --   spacer,  line ,  row,  category 
                                isCategory = false ,
                                isActive = true 
                                }
                        } 
                    
                    if k == "xRotation" then 
                        options.params.value = stage.gyroscope.data.xRotationF
                        options.params.title = "xRotation" end 
                    if k == "yRotation" then 
                        options.params.value = stage.gyroscope.data.yRotationF
                        options.params.title = "yRotation" end 
                    if k == "zRotation" then 
                        options.params.value = stage.gyroscope.data.zRotationF
                        options.params.title = "zRotation" end 
                     
                    -- Insert the row into the tableView
                    if options.params.title ~= "text here" then 
                        self.tableView2:insertRow(options)
                    end 

                    -- if (rowtype == "spacer")  then 
                        -- rowColor = tableViewColors.headerColor 
                        -- rowColor.default[4] = .6  -- alpha
                    -- end
                end
            else 
                local options = {  -- create row options 
                            --id = nil , 
                            rowHeight = 50 , 
                            rowColor = tableViewColors.rowColor , 
                            lineColor = tableViewColors.rowColor , 
                            isCategory = false , 
                            params = {
                                title = "text here",
                                value = 0,
                                rowtype = "row", --   spacer,  line ,  row,  category 
                                isCategory = false ,
                                isActive = true 
                                }
                        } 
                options.params.value = "Not Available"
                options.params.title = "Gyroscope"
                self.tableView2:insertRow(options)
            end 
            
        ------------------------------
        --  accelerometer data 
        ------------------------------    
        
        local rowparms = {
            title = "Accelerometer",
            value = 0,
            rowtype = "category", --   spacer,  line ,  row,  category 
            isCategory = true   ,
            isActive = true 
        }
        local options = {  -- create row options 
            --id = nil , 
            rowHeight = 50 , 
            rowColor = tableViewColors.catColor , 
            lineColor = tableViewColors.rowColor , 
            isCategory = true  , 
            params = rowparms
            }
        ------------------------------
        --  Load first category
        ------------------------------
                
        self.tableView2:insertRow(options)
        
        if self.stageDG.accel.isActive  then 
        
            local accelerometer_values = self.stageDG.accel.data
                for k, v in pairs( accelerometer_values ) do
                    
                    local options = {  -- create row options 
                            --id = nil , 
                            rowHeight = 50 , 
                            rowColor = tableViewColors.rowColor , 
                            lineColor = tableViewColors.rowColor , 
                            isCategory = false , 
                            params = {
                                title = "text here",
                                value = 0,
                                rowtype = "row", --   spacer,  line ,  row,  category 
                                isCategory = false ,
                                isActive = true 
                                }
                        } 
                    
                    if k == "xGravity" then 
                        options.params.value = stage.accel.data.xGravityF
                        options.params.title = "xGravity" end 
                    if k == "yGravity" then 
                        options.params.value = stage.accel.data.yGravityF
                        options.params.title = "yGravity" end 
                    if k == "zGravity" then 
                        options.params.value = stage.accel.data.zGravityF
                        options.params.title = "zGravity" end 
                    if k == "xInstant" then
                        options.params.value = stage.accel.data.xInstantF
                        options.params.title = "xInstant" end 
                    if k == "yInstant" then 
                        options.params.value = stage.accel.data.yInstantF
                        options.params.title = "yInstant" end 
                    if k == "zInstant" then 
                        options.params.value = stage.accel.data.zInstantF
                        options.params.title = "zInstant" end 
                    if k == "isShake" then 
                        options.params.value = stage.accel.data.isShakeF
                        options.params.title = "Shake" end     
                    -- Insert the row into the tableView
                    if options.params.title ~= "text here" then 
                        self.tableView2:insertRow(options)
                    end 

                    -- if (rowtype == "spacer")  then 
                        -- rowColor = tableViewColors.headerColor 
                        -- rowColor.default[4] = .6  -- alpha
                    -- end
                end
            else 
                local options = {  -- create row options 
                            --id = nil , 
                            rowHeight = 50 , 
                            rowColor = tableViewColors.rowColor , 
                            lineColor = tableViewColors.rowColor , 
                            isCategory = false , 
                            params = {
                                title = "text here",
                                value = 0,
                                rowtype = "row", --   spacer,  line ,  row,  category 
                                isCategory = false ,
                                isActive = true 
                                }
                        } 
                options.params.value = "Not Available"
                options.params.title = "Accelerometer"
                self.tableView2:insertRow(options)
            end 
            
            
        --------------------------------    
        -- Create rows for location data
        ---------------------------------
        
        -- Category
		local rowparms4Location = {
            title = "Location",
            value = 0,
            rowtype = "category", --   spacer,  line ,  row,  category 
            isCategory = true ,
            isActive = true 
        }
        local options4Location = {  -- create row options 
            --id = nil , 
            rowHeight = 50 , 
            rowColor = tableViewColors.catColor , 
            lineColor = tableViewColors.rowColor , 
            isCategory = true , 
            params = rowparms4Location
            }
        self.tableView2:insertRow(options4Location)    
        
        -----------------------------
        -- location rows 
        -----------------------------
        
		local location_values = self.stageDG.location.data
        -- print ("options:", Json.prettify(accelerometer_values)) 
        if self.stageDG.location.isActive then 
                for k, v in pairs( location_values ) do
                
                    local options = {  -- create row options 
                        --id = nil , 
                        rowHeight = 50 , 
                        rowColor = tableViewColors.rowColor , 
                        lineColor = tableViewColors.rowColor , 
                        isCategory = false , 
                        params = {
                            title = "text here",                                                          
                            value = 0,                                                                    
                            rowtype = "row", --   spacer,  line ,  row,  category                         
                            isCategory = false ,                                                          
                            isActive = true                                                               
                            }                                                                             
                    }         
                                                                                                
                    if k == "latitude" then 
                        options.params.value = stage.location.data.latitudeF
                        options.params.title = "latitude" end 
                    if k == "longitude" then 
                        options.params.value = stage.location.data.longitudeF
                        options.params.title = "longitude" end 
                    if k == "altitude" then 
                        options.params.value = stage.location.data.altitudeF
                        options.params.title = "altitude" end 
                    if k == "accuracy" then
                        options.params.value = stage.location.data.accuracyF
                        options.params.title = "accuracy" end 
                    if k == "speed" then 
                        options.params.value = stage.location.data.speedF
                        options.params.title = "speed" end 
                    if k == "direction" then 
                        options.params.value = stage.location.data.directionF
                        options.params.title = "direction" end 
                    if k == "time" then 
                        options.params.value = stage.location.data.timeF
                        options.params.title = "time" end     
                    -- Insert the row into the tableView
                    if options.params.title ~= "text here" then 
                        self.tableView2:insertRow(options)
                    end 

                    -- if (rowtype == "spacer")  then 
                        -- rowColor = tableViewColors.headerColor 
                        -- rowColor.default[4] = .6  -- alpha
                    -- end
                end
        else 
            local options = {  -- create row options 
                        --id = nil , 
                        rowHeight = 50 , 
                        rowColor = tableViewColors.rowColor , 
                        lineColor = tableViewColors.rowColor , 
                        isCategory = false , 
                        params = {
                            title = "text here",                                                          
                            value = 0,                                                                    
                            rowtype = "row", --   spacer,  line ,  row,  category                         
                            isCategory = false ,                                                          
                            isActive = true                                                               
                            }                                                                             
                    }     
            options.params.value = "Not Available"
            options.params.title = "Location"
            self.tableView2:insertRow(options)
        end 
	end  -- 




return M