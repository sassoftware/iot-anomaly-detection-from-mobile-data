
--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2019
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - build the list of sensor data in a tableView
  

--]]
local Glb = require ( "lib.glbldata" )  -- trick for global variables
local rgb = require ( "lib._rgb" )
local GGData = require( "lib.GGData" )
local Json   = require ("json")
local Widget = require( "widget" )
local Buttons = require ("lib.UIbutton")
local theme = Glb.theme 
local Misc  = require ("lib.miscfunctions")  -- non OO helper functions
local misc = Misc:new() 

local M = {}
local M_mt = { __index = M }

local spinner
local appstate = GGData:load("AppState") 


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
            
            
        -- Edit new button 
        ------------------------------
        
            
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
            else 	
                -- print ("RowRender:  row")
                if parms.isActive then 
                    row.rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
                    row.rowValue:setFillColor( unpack(tableViewColors.rowtextColor) )
                else 
                    row.rowTitle:setFillColor( unpack(tableViewColors.inactivetextColor) )
                    row.rowValue:setFillColor( unpack(tableViewColors.inactivetextColor) )
                end 
                row.rowValue.x = rowContentWidth * 0.45
                row.buttonactive= Buttons:new({buttonName = "brokercheckbox"})
                row.buttonactive:loadimages( row, "pictures/boxlightgrey.png" , "pictures/boxblack.png", "pictures/boxblackchecked.png" , "pictures/boxlightgrey.png" ,  rowContentHeight * .6 , rowContentHeight * .6  )  --  create 4 images for use with buttons,   active,  roll over, clicked and inactive. 
                row.buttonactive:positions_within_frame(85,42,row)
                row.buttonactive.buttonGroup.anchorX=.5
                row.buttonactive.buttonGroup.anchorY=.5
                row.buttonactive.buttonGroup.brokerNick = parms.Nick
                row.buttonactive.brokerNick = parms.Nick
                row.buttonactive:addlistener({toggle=true})   -- add touch listener.
                if parms.isEnabled then 
                    row.buttonactive:begin_clicked()
                else row.buttonactive:begin_inactive()
                end 
                --  rect for connection indicator 
                row.ConnectIndicator= Buttons:new({buttonName = "ConnectionIndicator"})
                 --  create 4 images for use with buttons,       active,       roll over,     clicked and inactive. 
                row.ConnectIndicator:loadRectFromColors( row, rgb.sasgreen ,rgb.sasgreen , rgb.sasred , rgb.sasgrey ,  rowContentHeight * .8 , rowContentHeight * .15 , 1 ) 
                -- row.ConnectIndicator:loadimages( row, "pictures/boxlightgrey.png" , "pictures/boxblack.png", "pictures/boxblackchecked.png" , "pictures/boxlightgrey.png" ,  rowContentHeight * .6 , rowContentHeight * .6  )  --  create 4 images for use with buttons,   active,  roll over, clicked and inactive. 
                row.ConnectIndicator.buttonGroup.anchorX=.5
                row.ConnectIndicator.buttonGroup.anchorY=.5
                row.ConnectIndicator:positions_within_frame(65,43, row )
                row:insert(row.ConnectIndicator.buttonGroup)
                if parms.isEnabled then 
                    if (parms.Connected) then 
                        row.ConnectIndicator:begin_main()
                    else row.ConnectIndicator:begin_clicked()
                    end 
                else row.ConnectIndicator:begin_inactive()
                end 
                
                row.rowTitle.text = parms.Nick 
                row.rowValue.text = tostring(parms.Port)
                
                
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
                Runtime:dispatchEvent(uiEvent)
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
        -- print ("Load rows:  ", Json.prettify(appstate))
		-- Create rows
		local rowparms = {
            title = "Brokers",
            title2 = "(select row to edit)",
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
		
		local broker_values = appstate.AppBrokers
        -- print ("brokerlist  loadrows:", Json.prettify(broker_values)) 
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
			options.params.title = broker_values[k].Nick
			options.params.value = broker_values[k].Port
			options.params.Nick = broker_values[k].Nick
			options.params.Host = broker_values[k].Host
			options.params.TopicSub = broker_values[k].TopicSub
			options.params.TopicPub = broker_values[k].TopicPub
            options.params.Port = broker_values[k].Port
            options.params.Freq = broker_values[k].Freq
            options.params.isEnabled = broker_values[k].isEnabled
            options.params.Conntype = broker_values[k].Conntype
            options.params.isDeletable = broker_values[k].isDeletable
            options.params.Connected = broker_values[k].Connected
            options.params.KeepAlive = broker_values[k].KeepAlive
            options.params.Userid = broker_values[k].Userid
            options.params.Password = broker_values[k].Password
            -- if options.params.Nick == "default" then options.params.isActive=false end  
            self.tableView2:insertRow(options)
			
		end 
		
        
       
        
	end  -- 




return M