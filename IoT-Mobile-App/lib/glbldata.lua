--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2019
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  - Trick to avoid using global values
  - Allows sharing of data between modules. 
--]]

-- display.setDefault( "anchorX", 0.0 )	-- default to TopLeft anchor point for new objects
-- display.setDefault( "anchorY", 0.0 )


local M = {}
    M.broker_edit_entry = {} -- table to hold entry that is being edited in the broker edit scene 
    M.MQTTSession = nil -- place holder for MQTT session information
    M.mqtt_pub = {}   -- output table for mqtt data to be published to broker.
	M.environment = system.getInfo( "environment" )
	M.platform = system.getInfo( "platform" )
	--[[ 
		android — all Android devices and the Android emulator.
		ios     — all iOS devices and the Xcode iOS Simulator.
		macos   — macOS desktop apps.
		tvos    — Apple's tvOS (Apple TV).
		win32   — Win32 desktop apps.
	--]]
	M.manufacturer = system.getInfo( "manufacturer" )
	if M.platform == "android"  then 
		M.iskeyCapable = true 
	else M.iskeyCapable = false 
	end 
    M.deviceID = system.getInfo( "deviceID" )
    --  stage dimensions 
    M.DW = display.contentWidth 
    M.DH = display.contentHeight
    M.bodyW  = 100   -- set by appUI, this is just a place holder
    M.bodyH  = 100 
    M.bodycontenttop = 50
    
    
return M
