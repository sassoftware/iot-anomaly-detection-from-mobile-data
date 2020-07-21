--====================================================================--
-- POP UP: Pop Up for picker
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - Popup routine 
  
    take data passed in and use it to create a popup to pick an item and pass that item back. 

--]]
local GlblData = require ( "lib.glbldata" )  -- trick for global variables
local rgb = require ( "lib._rgb" )
local Widget = require( "widget" )
local theme = GlblData.theme 

local composer = require "composer"
-- Variables local to scene
local scene = composer.newScene()

new = function ( self , event )
	
	------------------
	-- Groups
	------------------
	
	local localGroup = self.view -- add display objects to this group
	
	local parms = event.params 
	------------------
	-- variables
	------------------
	local rowtable = parms.items 
		
	local tableViewColors = {
		rowColor = { default =  theme.title_clr , over =  theme.clr_select  },
		rowtextColor =  theme.clr_text  ,
		lineColor = theme.clr_line,
		headerColor = { default =  theme.clr_header  , over = theme.clr_header  },
		headertextColor = theme.subtitle_clr ,
		catColor = { default = theme.clr_line , over = theme.clr_select  },
		cattextColor = theme.subtitle_clr
		}
	
	------------------
	-- Display Objects
	------------------
	
	local _W, _H = display.contentWidth, display.contentHeight
	-- local popup = display.newRect(localGroup, 100, 100 , 100, 100 )
	-- popup.anchorX , popup.anchorY = 0,0  --  anchor object at top left corner
	
	-- Forward references
	local tableView2
	local title
	
	------------------
	-- Listeners
	------------------
	
	-- Handle row rendering.  called when row is inserted into table.
	local function onRowRender( event )
		local phase = event.phase
		
		local row = event.row
		print ("row.kind", row.params.kind)
		local groupContentHeight = row.contentHeight
		
		local rowTitle = display.newText( row, "default", 0, 0, nil, 14 )
		rowTitle.x = 4
		rowTitle.anchorX = 0
		rowTitle.y = groupContentHeight * 0.5
		
		if ( row.params.kind == "header" ) then
		    print ("header")
			rowTitle:setFillColor( unpack(tableViewColors.headertextColor) )
			rowTitle.text = row.params.text
		elseif (row.params.kind == "category") then
			rowTitle:setFillColor( unpack(tableViewColors.cattextColor) )
			rowTitle.text = row.params.text.. "Category"
		else 	
			print ("onRR:  row")
			rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
			rowTitle.text = row.params.rowprefix .. row.params.text
		end
	end
	
	-- Listen for tableView touch and scroll events
	local function tableViewListener( event )
		local phase = event.phase
		print( "Event.phase is:", event.phase )
	end
	
	
	-- Handle touches on the row
	local function onRowTouch( event )
		local phase = event.phase
		local row = event.target
		if ( "release" == phase ) then
			print ("User selected row " .. row.index )
			
			if row.index ~= 1 then 
				composer.hideOverlay("fade", 500 )
				parms.onClose({row.index})
			end  -- can't select header.
			
		end
	end
	------------------
	-- Functions 
	------------------
	
		
	local function setPosition(Xpercent, Ypercent )
		return ((Xpercent / 100 ) * _W) , ((Ypercent / 100 ) * _H)
	end
	--====================================================================--
	-- INITIALIZE
	--====================================================================--
	
	local function initVars ()
		
		-- Create a tableView
			tableView2 = Widget.newTableView
			{
				top = parms.boxlocation[2],
				left = parms.boxlocation[1],
				width = parms.boxsize[1], 
				height = parms.boxsize[2],
				--hideBackground = true,
				listener = tableViewListener,
				onRowRender = onRowRender,
				--onRowUpdate = onRowUpdate,
				onRowTouch = onRowTouch,
			}
		
		-- Create rows
	
		for k, v in pairs( rowtable ) do	
			
			local kind = rowtable[k].kind
			local text = rowtable[k].text
			local rowprefix = rowtable[k].rowprefix 
			print (kind,text)
			local rowHeight = 22
			local rowColor = tableViewColors.rowColor
			local lineColor = tableViewColors.lineColor
			if (kind == "header")  then 
				rowColor = tableViewColors.headerColor 
				rowColor.default[4] = .6  -- alpha
			end
			if (kind == "category")  then rowColor = tableViewColors.catColor end
				
			-- Insert the row into the tableView
			
			tableView2:insertRow(
			{
				rowColor = rowColor,
				lineColor = lineColor,
				rowHeight = rowHeight,
				params = { kind = kind, text = text , rowprefix = rowprefix }
			})
		end


		------------------
		-- Inserts
		------------------
		
		localGroup:insert( tableView2 )
		
		
		
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
	print ("popuppicker: create: ")
	new(self,event)
	local currScene = composer.getSceneName( "current" )
	local prevScene = composer.getSceneName( "previous" )
	local overlayScene = composer.getSceneName( "overlay" )
	
print ("curr,prev,overlay", currScene, prevScene, overlayScene)	
	
end 	
	

function scene:show( event  )
  local phase = event.phase
  if ( phase == "will" ) then
	print ("popuppicker: show: will")
		
  elseif ( phase == "did" ) then
	print ("popuppicker: show: did")
    --audio.play(sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then
    print ("popuppicker: hide: will")
  elseif ( phase == "did" ) then
    print ("popuppicker: hide: did")
  end
end

function scene:destroy( event )
	print ("popuppicker: destroy")
  
end	
	
	------------------
	-- MUST return a display.newGroup()
	------------------
	scene:addEventListener("create")
	scene:addEventListener("show")
	scene:addEventListener("hide")
	scene:addEventListener("destroy")

return scene