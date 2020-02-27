local composer = require( "composer" )
local scene = composer.newScene()
local physics = require("physics")
physics.start()
physics.setGravity(0, 0)
local widget = require( "widget")
physics.setDrawMode("hybrid")

local myText = display.newText( "StarBuster", 385, 200, native.systemFont, 60 )
    transition.fadeOut(myText, { time=2500 })
    myText:setFillColor( 1, 1, 1 )

local sheetOptions = 
{
	frames =
	{
		{
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        { 
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },

	},
}
local objectSheet = graphics.newImageSheet( "gameObjects.png", sheetOptions )

local lives = 2
local score = 0
local died = false
local asteroidsTable = {}
local ship 
local gameLoopTimer
local livesText
local scoreText
local backGroup 
local mainGroup 
local uiGroup 
local coins = {}
local cCounter = 1
local coinTimer

local function updateText()
	livesText.text = "Lives:" .. lives
	scoreText.text = "Score:" .. score
end 

local function createAsteroid()

	local newAsteroid = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
	table.insert( asteroidsTable, newAsteroid )
	physics.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } )
	newAsteroid.myName = "asteroid"

	local whereFrom = math.random( 3 )

	if ( whereFrom == 1 ) then
		newAsteroid.x = -60
		newAsteroid.y = math.random( 500 )
		newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
	elseif ( whereFrom == 2 ) then
		newAsteroid.x = math.random( display.contentWidth )
		newAsteroid.y = -60
		newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
	elseif ( whereFrom == 3 ) then
		newAsteroid.x = display.contentWidth + 60
		newAsteroid.y = math.random( 500 )
		newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
	end

	newAsteroid:applyTorque( math.random( -6,6 ) )
end

local function createCoins()
    local fallCoins = math.random(display.contentWidth * -0.2, display.contentWidth * 0.7)
    coins[cCounter] = display.newCircle(fallCoins, display.contentCenterY - 500, 10)
    physics.addBody(coins[cCounter], "dynamic")
    coins[cCounter]:setLinearVelocity( 0, 300)
    coins[cCounter].myName = "coins"
    coins[cCounter].value = cCounter
    cCounter = cCounter + 1
   -- coins:setFillColor (0.5)
end

coinTimer = timer.performWithDelay(5000, createCoins, -1)

local function moveShip( event )
    local ship = event.target
    local phase = event.phase

    if( "began" == phase ) then
        display.currentStage:setFocus( ship )
        if event.x >150 and event.x<display.contentWidth - 150 then
        ship.touchOffsetX = event.x - ship.x
        end
        if event.y >50 and event.y<display.contentHeight + 50 then
        ship.touchOffsetY = event.y - ship.y
        end
    elseif ( "moved" == phase ) then
       if event.x >150 and event.x<display.contentWidth - 150 then
        ship.x = event.x - ship.touchOffsetX
        end
        if event.y >50 and event.y<display.contentHeight + 50 then
        ship.y = event.y - ship.touchOffsetY 
        end
    elseif ("ended" == phase or "cancelled" == phase ) then
    display.currentStage:setFocus( nil )
    end

    return true
end


local function gameLoop()
	
	createAsteroid()
	for i =#asteroidsTable, 1, -1 do
		local thisAsteroid = asteroidsTable[i]
        if ( thisAsteroid.x < -100 or
             thisAsteroid.x > display.contentWidth + 100 or
             thisAsteroid.y < -100 or
             thisAsteroid.y > display.contentHeight + 100 )
        then
            display.remove( thisAsteroid )
            table.remove( asteroidsTable, i )
        end
	end
end

local function restartShip()
	ship.isBodyActive = false
    ship:setLinearVelocity( 0, 0 )
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
    transition.to( ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end

local function endGame()
    composer.removeScene( "title")
    composer.gotoScene( "title", { time=800, effect="crossFade"})
end

local function updateScore()
	score = score + 30
	scoreText.text = string.format("Score: %d", score)
    if ( score < 0) then
        score = 0
        scoreText.text = string.format("Score: %d", score)
    end
end

local scoreTimer = timer.performWithDelay(5000, updateScore, 0)

local function incrementScore(obj) 
      obj.myName = "grabbedCoin"
      transition.to(obj, {alpha = 0, onComplete=function(self) display.remove(self); end})
      score = score + 250
    end

local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

    for i = #asteroidsTable, 1, -1 do
        if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
            table.remove( asteroidsTable, i )
            break
        end
    end

    if(obj1.myName == "ship" and obj2.myName == "coins") or
    ( obj1.myName == "coins" and obj2.myName == "ship" )then
      timer.performWithDelay(1, function() incrementScore(obj1); end, 1) end

    if ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
       ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )then
        	
    if( died == false ) then
    	died = true
        lives = lives - 1
		livesText.text = "Lives: " ..lives
    	score = score -30
    	scoreText.text = "Score: " .. score

   	if (lives == 0 ) then
   		display.remove( ship )
   		native.showAlert( "StarBusters", "You have blown up")
        timer.performWithDelay( 2000, endGame)
   	else
   		ship.alpha = 0
   		timer.performWithDelay( 1000, restartShip)
   			  end 
		   end
		end
    end
end

function scene:create( event )
    local sceneGroup = self.view
    physics.pause()
    backGroup = display.newGroup()
    sceneGroup:insert( backGroup )
    mainGroup = display.newGroup()
    sceneGroup:insert( mainGroup )
    uiGroup = display.newGroup()
    sceneGroup:insert( uiGroup )

    local background = display.newImageRect( backGroup, "Background-star.png", 800, 1400)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79)
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
    physics.addBody( ship, {radius=30, isSensor=true})
    ship.myName = "ship"

    livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36)
    scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36)

    ship:addEventListener ("touch", moveShip)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        physics:start()
        Runtime:addEventListener( "collision", onCollision)
        gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0)
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if( phase == "will" ) then
        timer.cancel( gameLoopTimer )
    elseif( phase == "did" ) then
        Runtime:removeEventListener( "collision", onCollision)
        physics.pause()
    end
end

function scene:destroy( event )
    local sceneGroup = self.view
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene