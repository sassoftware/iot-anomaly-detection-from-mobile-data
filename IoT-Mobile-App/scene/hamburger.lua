--====================================================================--
-- composer overlayScene for menu selections 
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - this is what happens when the hamburger is pressed. 
  

--]]
local Glb = require ( "lib.glbldata" )  -- trick for global variables
local rgb = require ( "lib._rgb" )
local Widget = require( "widget" )
local theme = Glb.theme 
local Misc  = require ("lib.miscfunctions")  -- non OO helper functions
local misc = Misc:new() 

local composer = require "composer"
-- Variables local to scene
local scene = composer.newScene()

local new = function ( self , event )
	
	
	local localGroup = self.view -- add display objects to this group
	local parms = event.params 
	local callback = parms.onClose or nil 
	local UIinst = parms.UIinst 
	local navitems = parms.items 
	local nav_width = 250 
	local nav_height = display.actualContentHeight 
	-- Misc:printtable(navitems)
	
	
	-- Create background image by theme value
	-- display.getCurrentStage()
	local background = display.newRect( localGroup, 0,0, nav_width , nav_height )
	background.anchorX = 0 ; 	background.anchorY = 0
	background.x, background.y = display.safeScreenOriginX , display.safeScreenOriginY 
	background:setFillColor(unpack(theme.clr_background))
	
	local header_DG  = display.newGroup()
	local header =  display.newRect( header_DG, 0,0, nav_width , 180 )
	header.anchorX = 0 ; 	header.anchorY = 0
	header.x, header.y = display.safeScreenOriginX , display.safeScreenOriginY 
	header:setFillColor(unpack(theme.clr_header))
	
	local headerfl = display.newImageRect( header_DG, "pictures/headerflower2.png", nav_width, 180 )
	headerfl.anchorX = 0 ; 	headerfl.anchorY = 0
	headerfl.x, headerfl.y = header.x , header.y 	
	
	local headergraph = display.newImageRect( header_DG, "pictures/graph.png", 60, 60 )
	headergraph.anchorX = 0 ; 	headergraph.anchorY = 0
	headergraph.x, headergraph.y = nav_width * .5 , header.y  + 8
    
    print (display.safeScreenOriginY, "display.safeScreenOriginX" )
	
	local headerText = display.newText( header_DG, "SAS IoT Analytics ", nav_width * .1 , (180+ display.safeScreenOriginY)  * .62, useFont, 18 )
	headerText.anchorX = 0 ; 	headerText.anchorY = 0
	headerText:setFillColor( unpack(theme.clr_title) )
	
	------------------
	-- variables
	------------------
	
		
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
		local phase = event.phase
		
		local row = event.row
		local parms = event.row.params
		-- print ("row.type", parms.rowtype)
		local groupContentHeight = row.contentHeight
		
		local rowTitle = display.newText( row, "default", 0, 0,  native.systemFontBold, 18 )
		rowTitle.x = 4
		rowTitle.anchorX = 0
		rowTitle.y = groupContentHeight * 0.5
		
		if ( row.params.rowtype == "spacer" ) then
		    -- print ("spacer")
			rowTitle:setFillColor( unpack(tableViewColors.headertextColor) )
			rowTitle.text = ""
		elseif (row.params.rowtype == "category") then
			rowTitle:setFillColor( unpack(tableViewColors.cattextColor) )
			rowTitle.text = row.params.text.. "Category"
		elseif (row.params.rowtype == "line") then   --  spacer line
			rowTitle:setFillColor( unpack(tableViewColors.cattextColor) )
			rowTitle.text = "-------------------------------"	
		else 	
			-- print ("RowRender:  row")
			if row.params.isActive then rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
			else rowTitle:setFillColor( unpack(tableViewColors.inactivetextColor) )
			end 
			rowTitle.text = row.params.title
			
		end
	end
	
	-- Listen for tableView touch and scroll events
	local function tableViewListener( event )
		local phase = event.phase
		-- print( "Event.phase is:", event.phase )
	end
	
	
	-- Handle touches on the row
	local function onRowTouch( event )
		local phase = event.phase
		local row = event.target
		local parms = row.params
		-- misc:printtableD(row, 2 )
		if ( "release" == phase ) then
			-- print ("User selected row " .. row.index )
			
			if parms.isActive then 
				composer.hideOverlay("fade", 500 )
				callback({row.index},parms)
			end  -- can't select header.
			
		end
	end
	------------------
	-- Functions 
	------------------
	
	---------------------------------------
	-- INITIALIZE
	---------------------------------------
	
	local function initVars ()
		
		-- Create a tableView
			tableView2 = Widget.newTableView
			{
				top = header_DG.contentHeight + display.safeScreenOriginY  ,
				left = 0,
				width = nav_width , 
				height = display.contentHeight - (header_DG.contentHeight + display.safeScreenOriginY ) ,
				--hideBackground = true,
				listener = tableViewListener,
				onRowRender = onRowRender,
				--onRowUpdate = onRowUpdate,
				onRowTouch = onRowTouch
			}
		
		-- Create rows
		local rowparms = {}
		for k, v in pairs( navitems ) do	
			
			local rowparms = navitems[k]
			local rowtype = rowparms["rowtype"]
			local rowHeight = 50
			local lineColor = tableViewColors.lineColor
			local rowColor = tableViewColors.rowColor
            
            if rowparms.isVisible then
                if rowparms.isActive then rowColor = tableViewColors.rowColor 
                else rowColor = tableViewColors.inactiveColor
                end 
                
                if (rowtype == "spacer")  then 
                    rowColor = tableViewColors.headerColor 
                    rowColor.default[4] = .6  -- alpha
                end
                if (rowtype == "category")  then rowColor = tableViewColors.catColor end
                    
                -- Insert the row into the tableView
                
                tableView2:insertRow(
                {
                    rowColor = rowColor,
                    lineColor = lineColor,
                    rowHeight = rowHeight,
                    params = {
                        title 		= rowparms["title"],	
                        modulename	= rowparms["modulename"],	
                        rowtype 	= rowparms["rowtype"],	
                        icon 		= rowparms["icon"],	
                        isCategory 	= rowparms["isCategory"],	
                        isActive 	= rowparms["isActive"],	
                        navtype 	= rowparms["navtype"]	
                            }
                })
            end 
		end

		------------------
		-- Inserts
		------------------
		localGroup:insert( background )
		localGroup:insert( tableView2 )
		localGroup:insert( header_DG )
		
		
		
		
	end
	
	------------------
	-- Initiate variables
	------------------
	
	initVars()
	
	------------------
	-- MUST return a display.newGroup()
	------------------
	
	return localGroup
	
end

function scene:create( event )
	print ("hamburger: create: ")
	new(self,event)
	local currScene = composer.getSceneName( "current" )
	local prevScene = composer.getSceneName( "previous" )
	local overlayScene = composer.getSceneName( "overlay" )
	
print ("curr,prev,overlay", currScene, prevScene, overlayScene)	
	
end 	
	

function scene:show( event  )
  local phase = event.phase
  if ( phase == "will" ) then
	print ("hamburger: show: will")
		
  elseif ( phase == "did" ) then
	print ("hamburger: show: did")
	local currScene = composer.getSceneName( "current" )
	local prevScene = composer.getSceneName( "previous" )
	local overlayScene = composer.getSceneName( "overlay" )
	print ("curr,prev,overlay", currScene, prevScene, overlayScene)	
    --audio.play(sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then
    print ("hamburger: hide: will")
  elseif ( phase == "did" ) then
    print ("hamburger: hide: did")
  end
end

function scene:destroy( event )
	print ("hamburger: destroy")
  
end	
	
	------------------
	-- MUST return a display.newGroup()
	------------------
	scene:addEventListener("create")
	scene:addEventListener("show")
	scene:addEventListener("hide")
	scene:addEventListener("destroy")

return scene