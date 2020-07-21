--[[

 - Version: 0.1
 - Made by tom tuning 2019
 

******************
 - INFORMATION
******************

  - extents the corona button widget  
  
  4 images are loaded into a button display Group either from a sprite sheet or files. 
		- normal  
		- inactive	
		- rollover 
		- clicked 
  
  Called with buttonName in options to set self.buttonName
  
  The result is a generic scene wide runtime button listener is called as return 
   example:  
   
    local uiEvent = {name = "ui", phase = "released", buttonName = self.myname or "none" , target = t }
	Runtime:dispatchEvent(uiEvent)
	
call order: 

     new: 
	 loadimages: 
	 addlistener
	 ---
	 dellistener
     destroy  
     
     or finalize may be called from composer
	 
  
  
--]]
----------------------------------------------------------------------------------------------------
local M = {}
local M_mt = { __index = M }

local Glb = require ( "lib.glbldata" )
-- local sfx = GlblData.soundobject   --  sound effects
local Misc  = require ("lib.miscfunctions")  -- non OO helper functions
local misc = Misc:new() 

local rgb = require ( "lib._rgb" )  -- colors 

-----------------------------------------------  

local _DW = display.contentWidth 
local _DH = display.contentHeight

------------------------------------
-- Local functions
------------------------------------

local function rollovertimer ( event )
		local params = event.source.params
		local self = params.myParam1
		local currtime = os.time() * 1000 
		print ("M:rollovertimer", self.myclass , self.rolloverend , currtime , self.isSupportRollover )
		if self.rolloverend <  currtime  then 
			-- go back to the last state if finger rolled off of button 
			if self.buttonGroup.whichimage == "clicked" then 	self:begin_clicked()
			elseif self.buttonGroup.whichimage == "inactive" then 	self:begin_inactive()
			else self:begin_main();
			end
		end 
return 		
end 

-- return new object
function M:new( options )
    local self = {}
    -- misc:printtableD(options)
    
    setmetatable( self, M_mt ) 
	self.myclass = "UIbutton"
	if options then 
		self.buttonName = options.buttonName or "none"
        self.SupportRollover = options.SupportRollover or "yes"  -- default to support rollover
	end 
	self.isDisplayGroup = true 
	self.rolloverend = 0 
    return self
end

function M:addlistener( parms )

    local isToggle = false 
    if parms then 
        isToggle = parms.toggle or false 
    end 
    
    if isToggle then 
        self.buttonGroup.touch = self.touch_listener_toggle
    else
        self.buttonGroup.touch = self.touch_listener
    end 
    self.buttonGroup:addEventListener( "touch" , self.buttonGroup )    
return 
end 

--  swap pictures in button group. 
function M:begin_rollover(  )
	-- print ("begin rollover")
	--  if the button is touched and moved we need to know when this move stops so we can go back to main. 
	if  self.timer == nil  and  self.SupportRollover=='yes' then 
		self.timer = timer.performWithDelay(100, rollovertimer , -1)  
		self.timer.params = { myParam1 = self }
		local currtime = os.time() * 1000
		self.rolloverend = currtime + 200   -- this number is made smaller by timebump. 
	end 
	
	-- self.buttonGroup.whichimage = "rollover"   -- rollover, inactive, clicked or main, 
    self.image_rollover.isVisible = true
    self.image_inactive.isVisible = false 
    self.image_clicked.isVisible = false 
    self.image.isVisible = false
    self.buttonGroup:insert(self.image_rollover)  -- put image on top 
	if self.image_number then 
		self.buttonGroup:insert(self.image_number)  -- put image on top 
	end 	
    return
end

--  swap pictures in button group. 
function M:begin_clicked(  )
    self.isEnabled=true  -- supporting toggle 
	self.movetime = os.time() * 1000 
	self.rolloverend = self.movetime
	if self.timer then 
		timer.cancel( self.timer ) 
		self.timer = nil 
	end 
    

	self.buttonGroup.whichimage = "clicked"   -- rollover, inactive, clicked or main, 
	self.image_rollover.isVisible = false
	self.image_inactive.isVisible = false
	self.image_clicked.isVisible = true 
	self.image.isVisible = false
	self.buttonGroup:insert(self.image_clicked)  -- put image on top 
	if self.image_number then 
		self.buttonGroup:insert(self.image_number)  -- put image on top 
	end 
    return
end

--  swap pictures in button group. 
function M:begin_inactive(  )
    
    self.isEnabled=false
	self.movetime = os.time() * 1000
	self.rolloverend = self.movetime
	if self.timer then 
		timer.cancel( self.timer ) 
		self.timer = nil 
	end 

	self.buttonGroup.whichimage = "inactive"   -- rollover, inactive, clicked or main, 
	self.image_rollover.isVisible = false
	self.image_inactive.isVisible = true 
	self.image_clicked.isVisible = false 
	self.image.isVisible = false
	self.buttonGroup:insert(self.image_inactive)  -- put image on top 
	if self.image_number then 
		self.image_number.isVisible = false 
	end 
    return
end

--  swap pictures in button group. 
function M:begin_main(  )
	-- print ("begin main")
	self.movetime = os.time() * 1000
	self.rolloverend = self.movetime
	if self.timer then 
		-- print ("M: begin_main cancel timer."  , self.myclass)
		timer.cancel( self.timer ) 
		self.timer = nil 
	end 
	 
	self.buttonGroup.whichimage = "main"   -- rollover and inactive or main
	self.image_rollover.isVisible = false
	self.image_inactive.isVisible = false 
	self.image_clicked.isVisible = false 
	self.image.isVisible = true
	self.buttonGroup:insert(self.image)  -- put image on top 
	if self.image_number then 
		self.buttonGroup:insert(self.image_number)  -- put image on top 
	end 
    return
end

function M:dellistener(  )  -- don't need this if the touch listener is a table listener. 

	self.buttonGroup:removeEventListener( "touch" , self.touch_listener ) 
	
return 
end 

--  delete this object 
function M:destroy()

	if self.timer  then timer.cancel( self.timer ) end 
	
	
	if self.buttonGroup then   -- remove button group
		transition.cancel(self.buttonGroup)
		self.buttonGroup.antecedent = nil 
		self.buttonGroup:removeSelf()
		self.buttonGroup = nil 
	end
	
	self = nil 
	
 return

end

--  shake button 
function M:FXshake(  object , amt  )
	local amt2 = amt or 250 
	local target = object or self.buttonGroup

	-- local sfx = GlblData.soundobject
	-- sfx:play("buttonshake")
	transition.to( target , {time=amt2, rotation = -15 , iterations = 1 , delay = 0 ,    transition = easing.outSine  } )
	transition.to( target , {time=amt2, rotation = 15  , iterations = 1 , delay = amt2 , transition = easing.outSine   } )
	transition.to( target , {time=amt2*4, rotation = 0  , iterations = 1 , delay = amt2*2 , transition = easing.outElastic  } )
	-- -- transition.to( self.buttonGroup, {time=2000,  delay = 5 , x = 100 , y = 100  , transition = easing.inOutElastic  } )
	-- print ("button shake ", self.buttonGroup.x , self.buttonGroup.rotation )
return 
end

--  unhide button 
function M:FXvisible(  )
	transition.to( self.buttonGroup, {time=250, alpha = 1  , delay = 0   } )
return 
end

--  hide button 
function M:FXinvisible(  )
	transition.to( self.buttonGroup, {time=250, alpha = 0  , delay = 0   } )
return 
end

-- If this DG was deleted by composer destroy can't be called.  
-- clean up timers and things. nil antecedent
function M:finalize(event)
	
	-- print ("UIbutton finalize", self.image, self )
    -- add code to delete timer
	if self.timer  then timer.cancel( self.timer ) end 
	transition.cancel(self) -- add code to cancel any transitions. 
    self.antecedent = nil 
	self = nil
return 	
end

--  add finalize function.  This runs as the last thing when a image or DG is deleted. 
function M:initfinalize( obj )
	obj.finalize = self.finalize
	obj:addEventListener("finalize")
	
	
return self
end



-- Create a new class that inherits from a base class
--
function M:inheritsFrom( baseClass )

    -- The following is the key to implementing inheritance:

    -- The __index member of the new class's metatable references the
    -- base class.  This implies that all methods of the base class will
    -- be exposed to the sub-class, and that the sub-class can override
    -- any of these methods.
    --
    if baseClass then
        setmetatable( M, { __index = baseClass } )
    end

    return M
end


--  create display image of self using file passed in. 
function M:loadimage( parentgroup,imagefile, width , height )
	
	self.image = display.newImageRect( parentgroup , imagefile , width , height )
	--  We need this because I can't add meta table info to a display object. 
	self.image.antecedent = self   -- in events we need the table the image is in so we can reference fields.
    self:initfinalize(self.image)
	-- self.image.gravityScale = self.gravityScale;
	
    return self.image

end

--  create 4 images for use with buttons,   active,  roll over, clicked and inactive. 
function M:loadimages( parentgroup, image_main , image_rollover, image_clicked , image_inactive ,  width , height )
	
	self.buttonGroup =  display.newGroup() 
	self.buttonGroup.whichimage = "main"   -- rollover and inactive 
	self.buttonGroup.antecedent = self  
    -- print (self.buttonGroup)
    self:initfinalize(self.buttonGroup)
    self.image = display.newImageRect( self.buttonGroup , image_main , width , height )
	self.image.finalize = self.finalize -- set up finalize listener.  	
	self.image:addEventListener("finalize")
	self.image.antecedent = self   -- in events we need the table the image is in so we can reference fields.
	
    self.image_rollover = display.newImageRect( self.buttonGroup , image_rollover , width , height )
	self.image_rollover.finalize = self.finalize -- set up finalize listener.  	
	self.image_rollover:addEventListener("finalize")
	self.image_rollover.antecedent = self   -- in events we need the table the image is in so we can reference fields.
	self.image_rollover.isVisible = false 
	
    self.image_inactive = display.newImageRect( self.buttonGroup , image_inactive , width , height )
	self.image_inactive.finalize = self.finalize -- set up finalize listener.  	
	self.image_inactive:addEventListener("finalize")
	self.image_inactive.antecedent = self   -- in events we need the table the image is in so we can reference fields.
	self.image_inactive.isVisible = false 
	
	self.image_clicked = display.newImageRect( self.buttonGroup , image_clicked , width , height )
	self.image_clicked.finalize = self.finalize -- set up finalize listener.  	
	self.image_clicked:addEventListener("finalize")
	self.image_clicked.antecedent = self   -- in events we need the table the image is in so we can reference fields.
	self.image_clicked.isVisible = false 
	
	parentgroup:insert(self.buttonGroup)
	
    return self.buttonGroup

end

--  create 4 rect for use with buttons,   active,  roll over, clicked and inactive. 
function M:loadRectFromColors( parentgroup, color_main , color_rollover, color_clicked , color_inactive ,  width , height , strokeW , strokecolor  )
	
    local Stroke_Color
    if strokecolor then 
        Stroke_Color = unpack(strokecolor) 
    else     
        Stroke_Color = unpack(Glb.theme.clr_line) 
    end 
    local Stroke_Width = strokeW or 3
    
	self.buttonGroup =  display.newGroup() 
	self.buttonGroup.whichimage = "main"   -- rollover and inactive 
	self.buttonGroup.antecedent = self  
    -- print (self.buttonGroup)
    self:initfinalize(self.buttonGroup)
    self.image = display.newRect( self.buttonGroup , 0, 0 , width , height )
	self.image.finalize = self.finalize -- set up finalize listener.  	
	self.image:addEventListener("finalize")
	self.image.antecedent = self   -- in events we need the table the image is in so we can reference fields.
    self.image:setFillColor( unpack(color_main) )
    self.image:setStrokeColor( Stroke_Color )
    self.image.strokeWidth = Stroke_Width
	
    self.image_rollover = display.newRect( self.buttonGroup , 0, 0 , width , height )
	self.image_rollover.finalize = self.finalize -- set up finalize listener.  	
	self.image_rollover:addEventListener("finalize")
	self.image_rollover.antecedent = self   -- in events we need the table the image is in so we can reference fields.
	self.image_rollover.isVisible = false 
    self.image_rollover:setFillColor( unpack(color_rollover) )
    self.image_rollover:setStrokeColor(Stroke_Color )
    self.image_rollover.strokeWidth = Stroke_Width
	
    self.image_inactive = display.newRect( self.buttonGroup ,  0, 0 , width , height )
	self.image_inactive.finalize = self.finalize -- set up finalize listener.  	
	self.image_inactive:addEventListener("finalize")
	self.image_inactive.antecedent = self   -- in events we need the table the image is in so we can reference fields.
	self.image_inactive.isVisible = false 
    self.image_inactive:setFillColor( unpack(color_inactive) )
    self.image_inactive:setStrokeColor( Stroke_Color )
    self.image_inactive.strokeWidth = Stroke_Width
	
	self.image_clicked = display.newRect( self.buttonGroup ,  0, 0 , width , height )
	self.image_clicked.finalize = self.finalize -- set up finalize listener.  	
	self.image_clicked:addEventListener("finalize")
	self.image_clicked.antecedent = self   -- in events we need the table the image is in so we can reference fields.
	self.image_clicked.isVisible = false 
    self.image_clicked:setFillColor( unpack(color_clicked) )
    self.image_clicked:setStrokeColor( Stroke_Color )
    self.image_clicked.strokeWidth = Stroke_Width
	
	parentgroup:insert(self.buttonGroup)
	
    return self.buttonGroup

end

--  create 4 images for use with buttons,   active,  roll over, clicked and inactive. 
function M:loadimages_from_sheet ( parentgroup, image_sheet ,  image_main , image_rollover, image_clicked , image_inactive ,  width , height )
	
	self.buttonGroup =  display.newGroup() 
	self.buttonGroup.whichimage = "main"   -- rollover and inactive 
	self.buttonGroup.antecedent = self  
    self:initfinalize(self.buttonGroup)
    self.image = display.newImageRect( self.buttonGroup , image_sheet , image_main , width , height )
	self.image.finalize = self.finalize -- set up finalize listener.  	
	self.image:addEventListener("finalize")
	self.image.antecedent = self   -- in events we need the table the image is in so we can reference fields.
	
    self.image_rollover = display.newImageRect( self.buttonGroup , image_sheet, image_rollover , width , height )
	self.image_rollover.finalize = self.finalize -- set up finalize listener.  	
	self.image_rollover:addEventListener("finalize")
	self.image_rollover.antecedent = self   -- in events we need the table the image is in so we can reference fields.
	self.image_rollover.isVisible = false 
	
    self.image_inactive = display.newImageRect( self.buttonGroup , image_sheet, image_inactive , width , height )
	self.image_inactive.finalize = self.finalize -- set up finalize listener.  	
	self.image_inactive:addEventListener("finalize")
	self.image_inactive.antecedent = self   -- in events we need the table the image is in so we can reference fields.
	self.image_inactive.isVisible = false 
	
	self.image_clicked = display.newImageRect( self.buttonGroup , image_sheet, image_clicked , width , height )
	self.image_clicked.finalize = self.finalize -- set up finalize listener.  	
	self.image_clicked:addEventListener("finalize")
	self.image_clicked.antecedent = self   -- in events we need the table the image is in so we can reference fields.
	self.image_clicked.isVisible = false 
	
	parentgroup:insert(self.buttonGroup)
	
    return self.buttonGroup

end


		

function M:rollovertimebump(  )
		local currtime = os.time() * 1000 
		self.rolloverend = currtime + 100
return 
end 

----------------------------
-- Object position Function
-- object to position 
-- percentages 
-- frame or display width and Height.
----------------------------

function M:setPosition( object , Xpercent, Ypercent , frameobj )

    if frameobj then 
        -- adjust for image anchor point in frame object 
		local  framestartX = frameobj.x - ( frameobj.width * frameobj.anchorX ) 
		local  framestartY = frameobj.y - ( frameobj.height *  frameobj.anchorY )  
		
		object.x = ((Xpercent / 100 ) * frameobj.width ) + framestartX
		object.y = ((Ypercent / 100 ) * frameobj.height) + framestartY
	else 

		object.x = ((Xpercent / 100 ) * _DW  )
		object.y = ((Ypercent / 100 ) * _DH  )
	end 	
	-- print ("setPosition", self.buttonGroup.x, self.buttonGroup.y , self.buttonGroup.anchorX, self.buttonGroup.anchorY )
 return 
end

function M:setPosition2(Xpercent, Ypercent , frameobj )
     
    if frameobj then 
		local framestartX = frameobj.x 
		local framestartY = frameobj.y 
		self.buttonGroup.x = ((Xpercent / 100 ) * frameobj.width ) + framestartX
		self.buttonGroup.y = ((Ypercent / 100 ) * frameobj.height) + framestartY
	else 

		self.buttonGroup.x = ((Xpercent / 100 ) * _DW)
		self.buttonGroup.y = ((Ypercent / 100 ) * _DH)
        
	end 
    
	
 return 	
end


--  position based on viewable screen size.  Good for control displaygro
function M:positions  ( Xpercent, Ypercent )
	    
		self.image.x = ((Xpercent / 100 ) * _DW)
		self.image.y = ((Ypercent / 100 ) * _DH)
		if self.image_rollover then 
			self.image_rollover.x = ((Xpercent / 100 ) * _DW)
			self.image_rollover.y = ((Ypercent / 100 ) * _DH)
		end 
		if self.image_inactive then 
			self.image_inactive.x = ((Xpercent / 100 ) * _DW)
			self.image_inactive.y = ((Ypercent / 100 ) * _DH)
		end 
		if self.image_clicked then 
			self.image_clicked.x = ((Xpercent / 100 ) * _DW)
			self.image_clicked.y = ((Ypercent / 100 ) * _DH)
		end 
		if self.image_number then 
			self.image_number.x = ((Xpercent / 100 ) * _DW)
			self.image_number.y = ((Ypercent / 100 ) * _DH)
		end 	
	 return 
end 
	

function M:positions_within_frame  ( Xpercent, Ypercent , frameobj )

        -- print ("frameobj anchor",  frameobj.anchorX, frameobj.contentHeight, frameobj.height,frameobj.contentWidth, frameobj.width, frameobj.x , frameobj.y)

	    local object = self.buttonGroup
		-- local framestartX = frameobj.x - ( frameobj.width / 2 ) 
		local framestartX = frameobj.x
		-- local framestartY = frameobj.y - ( frameobj.height / 2 )  
		local framestartY = frameobj.y
		object.x = ((Xpercent / 100 ) * frameobj.width ) 
		object.y = ((Ypercent / 100 ) * frameobj.height)
		-- object.y = ((Ypercent / 100 ) * frameobj.height) + framestartY
        
        -- print (object.x, object.y , "computed place on screen")
		-- if self.image_rollover then 
			-- self.image_rollover.x = object.x
			-- self.image_rollover.y = object.y
		-- end 
		-- if self.image_inactive then 
			-- self.image_inactive.x = object.x
			-- self.image_inactive.y = object.y
		-- end 
		-- if self.image_clicked then 
			-- self.image_clicked.x = object.x
			-- self.image_clicked.y = object.y
		-- end 	
		-- if self.image_number then 
			-- self.image_number.x = object.x
			-- self.image_number.y = object.y
		-- end	
		
	return ( object )	
end

function M:touch_inBounds( event )
    local answer = false 
    local Xpt = event.x
    local Ypt = event.y
    local t = event.target 
    local bounds = t.contentBounds 
    
    
    if (Xpt < bounds.xMax) and (Xpt > bounds.xMin ) and (Ypt < bounds.yMax) and (Ypt > bounds.yMin) then 
        print ("touch_inBounds: touch is true ")
        answer = true 
    end     

return answer 
end 


function M:touch_listener( event )
        local event = event 
        local t = event.target 
        local self = t.antecedent 
        -- local sfx = GlblData.soundobject   --  sound effects
        print ("button touch listener", event.phase , self , event.id , t.contentBounds.xMin,t.contentBounds.xMax , event.x )
    if self then    -- this listener was being called after the listener was removed and self:destroy was called.  So things were failing.  
        if self.buttonGroup.whichimage ~= "inactive"  then 
            if event.phase == "began" then
                self:begin_rollover()
                if event.id then display.getCurrentStage():setFocus(t, event.id) end
                t.isFocus = true
                local uiEvent = {name = "onUIevent", phase = "pressed", buttonName = self.buttonName or "none" , target = t }
                Runtime:dispatchEvent(uiEvent)
            elseif ( event.phase == "moved" ) then 
                self:begin_rollover() 
                self:rollovertimebump()  -- bump out time to stay in rollover mode. 
            elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
                self:begin_main()
                if event.id then display.getCurrentStage():setFocus(nil, event.id) end
                t.isFocus = false
                if self:touch_inBounds(event) then 
                    local uiEvent = {name = "onUIevent", phase = "released", buttonName = self.buttonName or "none" , target = t }
                    print ("release event dispatched ", event.phase )
                    Runtime:dispatchEvent(uiEvent)
                end 
            end  -- "ended"
        end
    end 
return  true
end 

function M:touch_listener_toggle(event)
		
		local event = event 
		local t = event.target 
		local self = t.antecedent
        print ("button touch listener toggle ", event.phase , self , event.id , t.contentBounds.xMin,t.contentBounds.xMax , event.x )
	if self then 	-- this listener was being called after the listener was removed and self:destroy was called.  So things were failing.  		
			if event.phase == "began" then
				self:begin_rollover()
                if event.id then display.getCurrentStage():setFocus(t, event.id) end
                t.isFocus = true
                local uiEvent = {name = "onUIevent", phase = "pressed", buttonName = self.buttonName or "none" , target = t }
                Runtime:dispatchEvent(uiEvent)
			elseif ( event.phase == "moved" ) then 
				self:begin_rollover() 
				self:rollovertimebump()  -- bump out time to stay in rollover mode. 
			elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
				-- local sfx = GlblData.soundobject   --  sound effects
				-- sfx:play("buttonclick")
                if event.id then display.getCurrentStage():setFocus(nil, event.id) end
                t.isFocus = false
				if self.isEnabled then  -- on turn it off. 
                     print ("button touch listener toggle inactive  " , self.buttonName )
					self:begin_inactive()
				else      -- off turn it on .
                    print ("button touch listener toggle active  " , self.buttonName )
					self:begin_clicked()
				end 
                t.isEnabled = self.isEnabled
                local uiEvent = {name = "onUIevent", phase = "released", buttonName = self.buttonName or "none" , target = t }
                Runtime:dispatchEvent(uiEvent)
			end  -- "ended"
	end 
return true
end 








return M
