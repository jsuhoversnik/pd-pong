-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"


-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local gfx <const> = playdate.graphics

-- Here's our player sprite declaration. We'll scope it to this file because
-- several functions need to access it.

local playerSprite = nil
local opponentSprite = nil
local ballSprite = nil
local direction = nil -- false right true left
local player1_score = 0
local player2_score = 0
local paddle_offset = 8
local speed_multiplier = 1.1
local speed_base = 2
local ball_y = speed_base
local ball_x = speed_base
local max_y = 5

local colliding = nil
-- A function to set up our game environment.

function myGameSetUp()

    -- Set up the player sprite.

    local playerImage = gfx.image.new("images/player")
    assert( playerImage ) -- make sure the image was where we thought

    local ball = gfx.image.new("images/ball2")
    assert( ball ) -- make sure the image was where we thought

    ballSprite = gfx.sprite.new( ball )
    ballSprite:moveTo( 200, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    ballSprite:add() -- This is critical!
    ballSprite:setCollideRect( 0,0,ballSprite:getSize() )
    
    playerSprite = gfx.sprite.new( playerImage )
    playerSprite:moveTo( 400-paddle_offset, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    playerSprite:add() -- This is critical!
    playerSprite:setCollideRect( 0,0,playerSprite:getSize() )

    opponentSprite = gfx.sprite.new( playerImage )
    opponentSprite:moveTo( paddle_offset, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    opponentSprite:add() -- This is critical! 
    opponentSprite:setCollideRect( 0,0,playerSprite:getSize() )


    -- We want an environment displayed behind our sprite.
    -- There are generally two ways to do this:
    -- 1) Use setBackgroundDrawingCallback() to draw a background image. (This is what we're doing below.)
    -- 2) Use a tilemap, assign it to a sprite with sprite:setTilemap(tilemap),
    --       and call :setZIndex() with some low number so the background stays behind
    --       your other sprites.

    local backgroundImage = gfx.image.new( "images/bg2" )
    assert( backgroundImage )

    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            -- x,y,width,height is the updated area in sprite-local coordinates
            -- The clip rect is already set to this area, so we don't need to set it ourselves
            backgroundImage:draw( 0, 0 )
        end
    )



end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function playdate.update()



    -- for k,v in pairs(ballSprite:overlappingSprites()) do
    --     if playerSprite:alphaCollision(v) then
    --         print(playerSprite:alphaCollision(v))
    --         direction = false
    --         ball_x = ball_x * speed_multiplier
    --         ball_y = ball_y * speed_multiplier
    --     end
    --     if opponentSprite:alphaCollision(v) then
    --         print(opponentSprite:alphaCollision(v))
    --         direction = true
    --         ball_x = ball_x * speed_multiplier
    --         ball_y = ball_y * speed_multiplier
    --     end
    -- end

    -- -- Poll the d-pad and move our player accordingly.
    -- -- (There are multiple ways to read the d-pad; this is the simplest.)
    -- -- Note that it is possible for more than one of these directions
    -- -- to be pressed at once, if the user is pressing diagonally.
    -- if playdate.buttonIsPressed( playdate.kButtonUp ) then
    --     playerSprite:moveBy( 0, -2 )
    -- end
    -- if playdate.buttonIsPressed( playdate.kButtonRight ) then
    --     playerSprite:moveBy( 2, 0 )
    -- end
    -- if playdate.buttonIsPressed( playdate.kButtonDown ) then
    --     playerSprite:moveBy( 0, 2 )
    -- end
    -- if playdate.buttonIsPressed( playdate.kButtonLeft ) then
    --     playerSprite:moveBy( -2, 0 )
    -- end

    local change, acceleratedChange = playdate.getCrankChange() -- negative values are anti clockwise
    if acceleratedChange<0 and playerSprite.y<220 then
        playerSprite:moveBy( 0, (-1*acceleratedChange) )
    end
    if acceleratedChange>0 and playerSprite.y>20 then
        playerSprite:moveBy( 0, (-1*acceleratedChange) )
    end

    if playerSprite.y<20 then
        playerSprite:moveTo(400-paddle_offset,20)
    end
    if playerSprite.y>220 then
        playerSprite:moveTo(400-paddle_offset,220)
    end


    -- Ball movement

    local actualX, actualY, collisions, length = ballSprite:moveWithCollisions(ballSprite.x + ball_x, ballSprite.y + ball_y)
    -- printTable(length)
    if length ~= 0 then -- ~= is lua !=
        --TODO the ball sticks to the top/bottom of the paddle and will overflow and crash
        ball_x = ball_x * -speed_multiplier
    end

    
    -- if direction then
    --     ballSprite:moveBy( ball_x,ball_y )
    -- end
    -- if not direction then
    --     ballSprite:moveBy( -ball_x,ball_y )
    -- end

    if ballSprite.x > 400 then
        -- direction = false
        player1_score = player1_score + 1
        ballSprite:moveTo(200, 120)
        opponentSprite:moveTo(paddle_offset,120)
        ball_x = speed_base
        ball_y = math.random(-max_y, max_y)
    end
    if ballSprite.x < 0 then
        -- direction = true
        player2_score = player2_score + 1
        ballSprite:moveTo(200, 120)
        opponentSprite:moveTo(paddle_offset,120)
        ball_x = speed_base
        ball_y = math.random(-max_y, max_y)
        -- print(ball_y)
    end

    -- TODO swap me with movetowithcollision!
    -- setup collision on the top/bottom of the screen
    if ballSprite.y < 0 then
        ball_y = -ball_y
    end
    if ballSprite.y > 240 then
        ball_y = -ball_y
    end

    local opponent_y_offset = (opponentSprite.y - actualY)/math.abs((opponentSprite.y - actualY))
    if tostring(opponent_y_offset) ~= tostring(0/0) then --skip frames where we end up with nan
        if actualX < 200 then -- only move the opponent when the ball is in their court. way easier then actual logic
            opponentSprite:moveWithCollisions( opponentSprite.x, opponentSprite.y + speed_base*(-opponent_y_offset))
        end
    end



    -- Call the functions below in playdate.update() to draw sprites and keep
    -- timers updated. (We aren't using timers in this example, but in most
    -- average-complexity games, you will.)

    gfx.sprite.update()
    gfx.drawTextAligned("Score: " .. player1_score .. " - " .. player2_score , 150,5, centered) -- draw the scoreboard after the sprite update
    playdate.timer.updateTimers()

end