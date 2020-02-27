local composer = require( "composer" )
local scene = composer.newScene()

local function gotoLevelOne()
	composer.removeScene( "levelOne")
	composer.gotoScene( "levelOne", {time=800, effect="crossFade" })
end

local function gotoLevelTwo()
	composer.removeScene( "levelTwo")
	composer.gotoScene( "levelTwo", {time=800, effect="crossFade" })
end

local function gotoLevelThree()
	composer.removeScene( "levelThree")
	composer.gotoScene( "levelThree", {time=800, effect="crossFade" })
end

function scene:create( event )
	local sceneGroup = self.view
	local background = display.newImageRect( sceneGroup, "titleBground.png", 800, 1400)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local backgroundMusic = audio.loadStream("FTL Faster Than Light - Theme Song.mp3")
	local backgroundMusicChannel = audio.play(backgroundMusic, {channel=1, loops=-1, fadein=5000})

	local myText = display.newText( "StarBuster", 385, 200, native.systemFont, 60 )
	transition.fadeOut(myText, { time=3500 })
	myText:setFillColor( 1, 1, 1 )

	local levelOneButton = display.newText( sceneGroup, "Level One", display.contentCenterX, 610, native.systemFont, 44)
	levelOneButton:setFillColor(0.82, 0.86, 1)

	local levelTwoButton = display.newText( sceneGroup, "Level Two", display.contentCenterX, 710, native.systemFont, 44)
	levelOneButton:setFillColor(0.82, 0.86, 1)

	local levelThreeButton = display.newText( sceneGroup, "Level Three", display.contentCenterX, 810, native.systemFont, 44)
	levelOneButton:setFillColor(0.82, 0.86, 1)

	levelOneButton:addEventListener( "tap", gotoLevelOne )
	levelTwoButton:addEventListener( "tap", gotoLevelTwo )
	levelThreeButton:addEventListener( "tap", gotoLevelThree )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

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