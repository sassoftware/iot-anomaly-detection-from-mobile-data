--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 - Mail: tom.tuning@sas.com
******************
 - INFORMATION
******************

  - Sound Utilities
  
--]]



local sfx = {}

sfx.soundcompletelistener = function ( event )
   --print ("sound completed channel ", event.channel )
end
------------------
-- Modules
------------------

local GlblData = require ( "lib.glbldata" )  --  global variables
-----------------------
--  Sounds
-----------------------
sfx.backgroundoptions = { channel = 1, loops = 0 , fadein = 5 , onComplete = sfx.soundcompletelistener }
sfx.herooptions =       { channel = 2, loops = 0 , fadein = 5 , onComplete = sfx.soundcompletelistener }
sfx.effectoptions =     { channel = 3, loops = 0 , fadein = 5 , onComplete = sfx.soundcompletelistener }



sfx.buzz = audio.loadSound("sounds/buzz.mp3") 
sfx.bump = audio.loadSound("sounds/bump.mp3") 
sfx.bite = audio.loadSound("sounds/Bite.wav") 
sfx.biteoptions = { channel = 2, loops = 0 , fadein = 5 , onComplete = sfx.soundcompletelistener }
sfx.splash = audio.loadSound("sounds/Fish Splashing.wav")
sfx.splashoptions = { channel = 3, loops = 0 , fadein = 30 , onComplete = sfx.soundcompletelistener }

-----------------
-- Functions 
-----------------
 


sfx.play = function ( handle , options ) 
   local isChannelActive = audio.isChannelActive( options.channel )
   --print ("ischnallel Active "  , isChannelActive )
   if GlblData.sound and not isChannelActive  then 
		audio.play ( handle , options ) 
   end 

end 

sfx.fadeout = function ( options ) 

   if GlblData.sound then audio.fadeOut ( options ) end 

end 

sfx.init = function()
   audio.reserveChannels(5)
   sfx.masterVolume = audio.getVolume()  --print( "volume "..masterVolume )
   audio.setVolume( 0.80, { channel = 1 } )  -- background sounds
   audio.setVolume( 0.22, { channel = 2 } )  -- hero sounds
   audio.setVolume( 0.33,  { channel = 3 } )  -- effects
   audio.setVolume( 1.0,  { channel = 4 } )  --tbd
   audio.setVolume( 0.25, { channel = 5 } )  --tbd
end











		
return sfx
