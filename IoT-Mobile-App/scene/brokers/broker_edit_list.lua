
--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2019
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - build the list of brokers parms in a tableView
  

--]]
local Glb = require ( "lib.glbldata" )  -- trick for global variables
local rgb = require ( "lib._rgb" )
local GGData = require( "lib.GGData" )
local Json   = require ("json")
local Widget = require( "widget" )
local theme = Glb.theme 
local Misc  = require ("lib.miscfunctions")  -- non OO helper functions
local misc = Misc:new() 

local M = {}
local M_mt = { __index = M }

local spinner
local appstate = GGData:load("AppState") 
M.textFields = {}  -- track all the text fields created. Needed because these exist outside of the DisplayGroup paradime 

-- loop thru table of display objects and set visibility based on bounds
function M:set_visible(t,boundy)
        for k, v in pairs( t ) do
            local bounds = v.contentBounds
            -- print ("M.NickNameField.y",bounds.yMin)
            if bounds then 
                if bounds.yMin < boundy then v.isVisible = false
                else v.isVisible = true
                end 
            end 
        end    
    

return 
end 


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

function M:finalize(event)
	
	print ("Nick finalize", event.name, event.target, self )
    misc:table_delete_by_value(event.target,M.textFields)
    -- misc:printtableD(M.textFields,1)
    -- print ("finialize parms:", Json.prettify(M.textFields)) 
return 	
end


function M:loadnew(options)

    self.stageDG = options.stage 
    local stage = self.stageDG
	local nav_width = options.width or 250 
	local nav_height = options.height or display.actualContentHeight 
	-- Misc:printtable(navitems)
	
    ----------------------------------------------
    --- Process input Options
    ----------------------------------------------
    
    M.input = {}  -- table to hold input options 
	M.input.calltype = options.calltype or "add"
	M.input.inputdata = options.inputdata or nil 
	M.input.parentstage = options.stage
    
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
        local fieldHandler = M.input.parentstage.fieldHandler
		local rowContentHeight = row.contentHeight
		local rowContentWidth = row.contentWidth
		
		
		if ( parms ) then 
            row.rowTitle = display.newText( row, "", 0, 0,  native.systemFont, 18 )
            row.rowTitle.x = 4
            row.rowTitle.anchorX = 0
            row.rowTitle.anchorY = .5
            row.rowTitle.y = rowContentHeight * 0.5
            row.rowTitle.x = rowContentWidth * 0.02
            
            row.rowTitle2 = display.newText( row, "", 0, 0,  native.systemFont, 14 )
            row.rowTitle2.x = 4
            row.rowTitle2.anchorX = 0
            row.rowTitle2.anchorY = .5
            row.rowTitle2.y = rowContentHeight * 0.5
            row.rowTitle2.x = rowContentWidth * 0.60
            
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
                 if parms.title2 then 
                    row.rowTitle2:setFillColor( unpack(tableViewColors.cattextColor) )
                    row.rowTitle2.text = parms.title2
                 end    
                 row.rowValue:setFillColor( unpack(tableViewColors.headertextColor) )
                 row.rowValue.text = ""
                 row.rowValue.isVisible = false
            elseif (parms.rowtype == "line") then   --  spacer line
                -- print ("RowRender:  line")
                 row.rowTitle:setFillColor( unpack(tableViewColors.cattextColor) )
                 row.rowTitle.text = "-------------------------------"	
                 row.rowValue:setFillColor( unpack(tableViewColors.headertextColor) )
                 row.rowValue.text = ""
         --local displayed_values = {"Nick","Host","Port","TopicPub","TopicSub", "Freq","KeepAlive"}
            elseif (parms.rowtype == "Nick") then 
            
                row.NickNameField = native.newTextField( 40, 0, rowContentWidth * .58, 30 )
                row.NickNameField:addEventListener( "userInput", fieldHandler( function() return "Nick" ,row.NickNameField end ) )
                row.NickNameField.anchorX = 0   -- from left edge
                row.NickNameField.anchorY = .5  -- center in row 
                row.NickNameField.placeholder = tostring(parms.value)
                row.NickNameField.inputType="no-emoji"
                row.NickNameField.isVisible = true 
                row.NickNameField.y = rowContentHeight * 0.5
                row.NickNameField.x = rowContentWidth * 0.38
                row.NickNameField.finalize = M.finalize  -- tableview code delete this thing if scrolled out of view.  So we need this to remove entry from M.textFields
                table.insert(M.textFields, row.NickNameField) 
                row.NickNameField:addEventListener("finalize")
                row.rowValue.isVisible = false
                row.NickNameField.text = parms.value
                row.rowTitle.text = parms.title
                row.rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
                row:insert(row.NickNameField)
            elseif (parms.rowtype == "Host") then 
            
                row.HostNameField = native.newTextField( 40, 0, rowContentWidth * .58, 30 )
                row.HostNameField:addEventListener( "userInput", fieldHandler( function() return "Host" ,row.HostNameField end ) )
                row.HostNameField.anchorX = 0   -- from left edge
                row.HostNameField.anchorY = .5  -- center in row 
                row.HostNameField.placeholder = tostring(parms.value)
                row.HostNameField.inputType="no-emoji"
                row.HostNameField.isVisible = true 
                row.HostNameField.y = rowContentHeight * 0.5
                row.HostNameField.x = rowContentWidth * 0.38
                row.HostNameField.finalize = M.finalize  -- tableview code delete this thing if scrolled out of view.  So we need this to remove entry from M.textFields
                table.insert(M.textFields, row.HostNameField) 
                row.HostNameField:addEventListener("finalize")
                row.rowValue.isVisible = false
                row.HostNameField.text = parms.value
                row.rowTitle.text = parms.title
                row.rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
                row:insert(row.HostNameField)
                
            elseif (parms.rowtype == "Port") then 
            
                row.PortNameField = native.newTextField( 40, 0, rowContentWidth * .58, 30 )
                row.PortNameField:addEventListener( "userInput", fieldHandler( function() return "Port" ,row.PortNameField end ) )
                row.PortNameField.anchorX = 0   -- from left edge
                row.PortNameField.anchorY = .5  -- center in row 
                print ("broker edit list port: "  ,  parms.value)
                row.PortNameField.placeholder = tostring(parms.value)
                row.PortNameField.inputType="number"
                row.PortNameField.isVisible = true 
                row.PortNameField.y = rowContentHeight * 0.5
                row.PortNameField.x = rowContentWidth * 0.38
                row.PortNameField.finalize = M.finalize  -- tableview code delete this thing if scrolled out of view.  So we need this to remove entry from M.textFields
                table.insert(M.textFields, row.PortNameField) 
                row.PortNameField:addEventListener("finalize")
                row.rowValue.isVisible = false
                row.PortNameField.text = tostring(parms.value)
                row.rowTitle.text = parms.title
                row.rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
                row:insert(row.PortNameField)
                
            elseif (parms.rowtype == "TopicPub") then 
            
                row.TopicNameField = native.newTextField( 40, 0, rowContentWidth * .58, 30 )
                row.TopicNameField:addEventListener( "userInput", fieldHandler( function() return "TopicPub" ,row.TopicNameField end ) )
                row.TopicNameField.anchorX = 0   -- from left edge
                row.TopicNameField.anchorY = .5  -- center in row 
                row.TopicNameField.placeholder = "Outbound Topic"
                row.TopicNameField.inputType="no-emoji"
                row.TopicNameField.isVisible = true 
                row.TopicNameField.y = rowContentHeight * 0.5
                row.TopicNameField.x = rowContentWidth * 0.38
                row.TopicNameField.finalize = M.finalize  -- tableview code delete this thing if scrolled out of view.  So we need this to remove entry from M.textFields
                table.insert(M.textFields, row.TopicNameField) 
                row.TopicNameField:addEventListener("finalize")
                row.rowValue.isVisible = false
                row.TopicNameField.text = parms.value
                -- row.rowTitle.text = parms.title
                row.rowTitle.text = "Topic Pub"
                row.rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
                row:insert(row.TopicNameField) 
            
            elseif (parms.rowtype == "TopicSub") then 
            
                row.TopicSubNameField = native.newTextField( 40, 0, rowContentWidth * .58, 30 )
                row.TopicSubNameField:addEventListener( "userInput", fieldHandler( function() return "TopicSub" ,row.TopicSubNameField end ) )
                row.TopicSubNameField.anchorX = 0   -- from left edge
                row.TopicSubNameField.anchorY = .5  -- center in row 
                row.TopicSubNameField.placeholder = "Inbound Topic"
                row.TopicSubNameField.inputType="no-emoji"
                row.TopicSubNameField.isVisible = true 
                row.TopicSubNameField.y = rowContentHeight * 0.5
                row.TopicSubNameField.x = rowContentWidth * 0.38
                row.TopicSubNameField.finalize = M.finalize  -- tableview code delete this thing if scrolled out of view.  So we need this to remove entry from M.textFields
                table.insert(M.textFields, row.TopicSubNameField) 
                row.TopicSubNameField:addEventListener("finalize")
                row.rowValue.isVisible = false
                row.TopicSubNameField.text = parms.value
                -- row.rowTitle.text = parms.title
                row.rowTitle.text = "Topic Sub"
                row.rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
                row:insert(row.TopicSubNameField) 
                
            elseif (parms.rowtype == "Freq") then 
            
                row.TopicSubNameField = native.newTextField( 40, 0, rowContentWidth * .58, 30 )
                row.TopicSubNameField:addEventListener( "userInput", fieldHandler( function() return "Freq" ,row.TopicSubNameField end ) )
                row.TopicSubNameField.anchorX = 0   -- from left edge
                row.TopicSubNameField.anchorY = .5  -- center in row 
                row.TopicSubNameField.placeholder = "Events Per Second"
                row.TopicSubNameField.inputType="number"
                row.TopicSubNameField.isVisible = true 
                row.TopicSubNameField.y = rowContentHeight * 0.5
                row.TopicSubNameField.x = rowContentWidth * 0.38
                row.TopicSubNameField.finalize = M.finalize  -- tableview code delete this thing if scrolled out of view.  So we need this to remove entry from M.textFields
                table.insert(M.textFields, row.TopicSubNameField) 
                row.TopicSubNameField:addEventListener("finalize")
                row.rowValue.isVisible = false
                row.TopicSubNameField.text = tostring (parms.value)
                -- row.rowTitle.text = parms.title
                row.rowTitle.text = "Frequency"
                row.rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
                row:insert(row.TopicSubNameField) 
                
            elseif (parms.rowtype == "KeepAlive") then 
            
                row.KeepAliveNameField = native.newTextField( 40, 0, rowContentWidth * .58, 30 )
                row.KeepAliveNameField:addEventListener( "userInput", fieldHandler( function() return "KeepAlive" ,row.KeepAliveNameField end ) )
                row.KeepAliveNameField.anchorX = 0   -- from left edge
                row.KeepAliveNameField.anchorY = .5  -- center in row 
                row.KeepAliveNameField.placeholder = tostring(parms.value)
                row.KeepAliveNameField.inputType="number"
                row.KeepAliveNameField.isVisible = true 
                row.KeepAliveNameField.y = rowContentHeight * 0.5
                row.KeepAliveNameField.x = rowContentWidth * 0.38
                row.KeepAliveNameField.finalize = M.finalize  -- tableview code delete this thing if scrolled out of view.  So we need this to remove entry from M.textFields
                table.insert(M.textFields, row.KeepAliveNameField) 
                row.KeepAliveNameField:addEventListener("finalize")
                row.rowValue.isVisible = false
                row.KeepAliveNameField.text = tostring (parms.value)
                row.rowTitle.text = parms.title
                row.rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
                row:insert(row.KeepAliveNameField)   
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
        -- print ("isGetPositionAvailable", answer , event.target.parent.parent:getContentPosition())
    return  answer 
    end 
    
    local springStart = 0
    local needToReload = false
	
	-- Listen for tableView touch and scroll events
	local function tableViewListener( event )
		local phase = event.phase
        -- print ("tableViewListener:  event.direction",event.direction, event.phase)
        -- print ("event.limitReached",event.limitReached)
        local boundy = Glb.bodycontenttop
        self:set_visible(M.textFields,boundy)  -- loop through a list of display objects and set them invisible if out of bounds. 
                
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
            print( "tableViewListener:  Reloading Table!" )
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
            -- print ("parms:", Json.prettify(parms)) 
            if not isCategory  then  -- can't select category rows
                local uiEvent = {name = "onUIevent", phase = "released", buttonName =  "tableView" , target = parms }
                print ("brokerlist:  row selected  ", id)
                -- Runtime:dispatchEvent(uiEvent)
            end
        end
      return true   
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
        self.tableView2:deleteAllRows()
        self:loadrows()  -- load function 
return 
end 
            
		
function M:loadrows()            
		
        local stage = self.stageDG
		appstate = GGData:load("AppState") 
        
                
        local displayed_values = {"Nick","Host","Port","TopicPub","TopicSub", "Freq","KeepAlive"}
		
		local broker_values = Glb.broker_edit_entry
        -- print ("BEL broker_values:", Json.prettify(broker_values)) 
        for i = 1,#displayed_values,1 do 
            for k, v in pairs( broker_values ) do
            
                local options = {  -- create row options 
                        --id = nil , 
                        rowHeight = 50 , 
                        rowColor = tableViewColors.rowColor , 
                        lineColor = tableViewColors.rowColor , 
                        isCategory = false , 
                        params = {
                            title = "",
                            value = 0,
                            rowtype = "row", --   spacer,  line ,  row,  category 
                            isCategory = false ,
                            isActive = true 
                            }
                        }
                -- print ("key value", k,v)        
                
                if k == displayed_values[i] then 
                    options.params.rowtype = k
                    options.params.title = k
                    options.params.value = v
                    self.tableView2:insertRow(options)
                end 
                
            end -- broker values loop 
		end -- displayed_values
        
       
        
	end  -- 




return M