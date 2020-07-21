-- Project: GooGChart
--
--  - Version: 0.1
 -- - Made by Tom Tuning @ 2018
 
 -- - Mail: tom.tuning@sas.com

-- ******************
-- - INFORMATION
-- ******************
--
-- Comments: 
-- 
--		GooGChart allows for easy creation of Google Image Charts for your Corona apps. 
--		Uses the new google html5 api. 
--      Uses a webView to show the chart.  CON: WebViews are always on top of all screen elements. 
--
----------------------------------------------------------------------------------------------------

local GooGChart = {}
local GooGChart_mt = { __index = GooGChart }

-- local http = require( "socket.http" )
-- local ltn12 = require( "ltn12" )
local rgb = require ( "lib._rgb" )  -- colors 

local _DW = display.contentWidth 
local _DH = display.contentHeight  
local _DPW = display.pixelHeight  -- switch these for landscape mode.
local _DPH = display.pixelWidth

-- google charts returns a chart in pixel dimensions.  Corona auto sizes things for us.  
-- we need to change the chart size to match the actual pixel size of the device 
local function calc_chart_dimensions( W , H )
	print ("old w h", W, H )  
	print ("pixel w h", _DPW, _DPH , _DW , _DH )  
	local fudge = .9
	-- local new_width  = ( W / _DW ) * _DPW
	-- local new_height  = ( H / _DH ) * _DPH 
	local new_width  = (( W / _DW ) * _DPW ) * fudge 
	local new_height  =  (( H / _DH ) * _DPH ) * fudge 
    print ("new w h", new_width , new_height ) 
return new_width , new_height 
end 

local function printtable (t)
			
			if type(t) == "table" then 
			    print ("===== printing table =====", t )
				for k,v in pairs (t) do
					print ("key is ", k ," value ===", v , type(v))
					if type(v) == "table" then 
						-- print ("key is ", k ," value ===", v , type(v))
						printtable(v)  -- try a little fun with recursion 
						print ("===== completed table =====" , v )
					end
					
				end 
			end 
return
end	

local function writedata (self , fp)
		local t = self.datapoints 
		local comma1 = ""
		local comma2 = ""
			if type(t) == "table" then 
				for k,v in pairs (t) do
				    if k == #t then comma1 = ""
					else comma1 = ","
					end 
					if type(v) == "table" then 
						fp:write("[ ")
						for k2,v2 in pairs (v) do
							if k2 == #v then comma2 = "" 
							else comma2 = ","
							end
							if type(v2) == "string" then 
								fp:write("'" .. v2 .. "'".. comma2 )
							else 
								fp:write(v2 .. comma2)
							end 
						end 
						fp:write("]".. comma1 .. "\n")
					end
					
				end 
			end 
return
end

-- return new object
function GooGChart:new( )

    local self = {}
    self.DG = display.newGroup()  -- use DG as table to hold functions.  This allows for use of finalize function in destroy
	self.DG.antecedent = self 
    setmetatable( self, GooGChart_mt ) 
	
	self.DG.finalize = self.finalizeDG  
	self.DG:addEventListener("finalize")

    return self

end


-- Create a new class that inherits from a base class
--
function GooGChart:inheritsFrom( baseClass )

    -- The following is the key to implementing inheritance:

    -- The __index member of the new class's metatable references the
    -- base class.  This implies that all methods of the base class will
    -- be exposed to the sub-class, and that the sub-class can override
    -- any of these methods.
    --
    if baseClass then
        setmetatable( GooGChart, { __index = baseClass } )
    end

    return GooGChart
end


--  called from WebView to help understand what is going on 
local function webListener( event )
		if event.url then
			print( "You are visiting: " .. event.url )
		end
	  
		if event.type then
			print( "The event.type is " .. event.type ) -- print the type of request
		end
	  
		if event.errorCode then
			native.showAlert( "Error!", event.errorMessage, { "OK" } )
		end
end

function GooGChart:destroy_webview(  )
	display.remove(self.webView)
return 
end 

function GooGChart:simplechart( params )
	-- local title, curveType, lineWidth, vaxistitle, haxistitle, legend, data, width, height 
	if not params then
		print ("ERROR:  GooGChart parm error.")
		params = {}
	else 
	
	self.title = params.title or ""
	self.curveType = params.curveType or "function"
	self.lineWidth = params.lineWidth or 3
	self.vaxistitle = params.vaxistitle or ""
	self.haxistitle = params.haxistitle or ""
	self.legend     = params.legend or "bottom"
	self.width      = params.width or 480
	self.height     = params.height or 340 
	self.pixelwidth , self.pixelheight = calc_chart_dimensions (self.width ,self.height )
	self.options    = params.options or nil  -- raw options in JS. 
	self.datapoints = params.data or {"No Data Found."}
	
	-- printtable(self.datapoints) 
	end
	
	self.image = display.newImageRect( self.DG , "pictures/blurrychart.png" , self.width, self.height )
	self.image.alpha = .7 
	self.image.anchorX , self.image.anchorY = 0,0  --  anchor object at top left corner

	self.header = [[
  <html>
  <head>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(drawChart);

      function drawChart() {
        var data = google.visualization.arrayToDataTable([
	
          
	]]	
	if self.charttype == "Pie" then 
		self.body1 = [[    var chart = new google.visualization.PieChart(document.getElementById('curve_chart')); ]]
	elseif 	self.charttype == "Column" then
		self.body1 = [[    var chart = new google.visualization.ColumnChart(document.getElementById('curve_chart')); ]]	
	else	
		self.body1 = [[    var chart = new google.visualization.LineChart(document.getElementById('curve_chart')); ]]
	end 	
		
		
	self.body2 = [[	
        chart.draw(data, options);
      }
    </script>
  </head>
  <body>
	<div id="curve_chart" > </div>
  </body>
</html>
	]]
	-- <div id="curve_chart" > </div>
	--<div id="curve_chart" style="width: 1125px; height: 750px;"> </div>
	
		local path = system.pathForFile( "radar.html" , system.TemporaryDirectory )
		local fp , errorString = io.open( path, "w" )
		-- print ("GGChart2: newline2 webView , fp ", webView , fp , errorString )	
		if fp then
				fp:write(self.header)
				-- write data array 
				writedata(self, fp)
				fp:write("]);\n")  
				-- write options 
				fp:write("var options = {\n")
				fp:write("title: '" .. self.title .. "',\n")
				fp:write("curveType: '" .. self.curveType .. "',\n")
				fp:write("legend: { position: '" .. self.legend .. "'},\n")
				fp:write("width: '" .. self.pixelwidth  .. "',\n")
				fp:write("height: '" .. self.pixelheight  .. "',\n")
				fp:write("vAxis: {title: '" .. self.vaxistitle .. "'},\n")
				fp:write("hAxis: {title: '" .. self.haxistitle .. "'},\n")
				fp:write("height: '" .. self.height .. "',\n")
				
				if self.options then 
					local opt = self.options  
					for ii = 1 , #opt , 1 do   -- loop thru and add raw JS to options table.  
						fp:write( opt[ii] .. ",\n")
					end 
				end 
				fp:write("lineWidth: '" .. self.lineWidth .. "'\n")
				fp:write("};\n")
				fp:write(self.body1)
				fp:write(self.body2)
				fp:close()
		end 
		self.webView = native.newWebView( 0, 0, self.width, self.height )
		print ("webview size",  self.webView.width )
		self.webView.anchorX , self.webView.anchorY = 0,0  --  anchor object at top left corner
		
		self.DG:insert(self.webView)	
		local path = system.pathForFile( "radar.html" , system.TemporaryDirectory )
			local fp = io.open( path, "r" )
			if fp then
				fp:close();
				self.webView:request( "radar.html", system.TemporaryDirectory )
			else
				self.webView:request( "radar.html", system.ResourceDirectory )
			end   
		-- Request image for `charts/donut.html` in system.ResourceDirectory
		
		
		self.webView:addEventListener( "urlRequest", webListener )

return 
end 

--- Creates a new line chart. Called internally.
-- @param params The chart params.
function GooGChart:line( params )
	print ("GooGChart:line")
	self.charttype = "Line"
	self:simplechart(params)
	
return
end 

function GooGChart:pie( params )
	print ("GooGChart:Pie")
	self.charttype = "Pie"
	self:simplechart(params)
	
return
end 
function GooGChart:column( params )
	self.charttype = "Column"
	self:simplechart(params)
	
return
end 

-- If this DG was deleted by composer destroy can't be called.  
function GooGChart:finalize()
    
	-- add code to delete timers 
	transition.cancel(self) -- add code to cancel any transitions.  
	self = nil
return 	
end

--- Destroys this GGChart object.
function GooGChart:destroy()

	display.remove(self.DG)  -- delete Display Object and removes from DG
	self = nil
	
return nil 	
end 

return GooGChart
