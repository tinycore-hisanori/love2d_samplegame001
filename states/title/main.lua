

local title = {}
local mouse = {}

local WINDOWS_START = "ここにマウスを移動してください"
local LINUX_START = "ここにマウスを移動してください"

local mouse_start_str = nil
local font = nil
local rankfont = nil

local scoreTbl = {}

-- 開始処理
function title:enter()
    mouse.x = 0
    mouse.y = 0
    love.mouse.setGrabbed(false)
    love.mouse.setRelativeMode(false) 
    love.mouse.setPosition(0, 0)
    -- ここに開始時に行う処理を記述
    background = love.graphics.newImage("assets/img/title/title.jpg")

    playerImage = love.graphics.newImage( "assets/img/common/cursor_150x150.png" )
    local osString = love.system.getOS()
    if(osString == "Windows") then
        font = love.graphics.setNewFont("fonts/PixelMplus12-Regular.ttf", 40)
--        font = love.graphics.setNewFont(40)
        mouse_start_str = WINDOWS_START
    else
        font = love.graphics.setNewFont("fonts/PixelMplus12-Regular.ttf", 40)
        mouse_start_str = WINDOWS_START
    end

    rankfont = love.graphics.setNewFont("fonts/PixelMplus12-Regular.ttf", 30)

    start_pos_y = wdw_h/5*3
    start_width = font:getWidth(mouse_start_str)
    start_height = font:getHeight()
    start_pos_x = wdw_w/2 - start_width / 2

     -- テーブルがない場合はテーブルを作成
    createScoreFile()

    --ランク取得
    scoreTbl = getRanks()


end

-- 更新処理
function title:update(dt)
    -- 一定間隔で行う処理を記述
--    mouse.x, mouse.y = love.mouse.getPosition()
--    mouse.x = love.mouse.getX()
--    mouse.y = love.mouse.getY()
    
    
end

function love.mousemoved(x , y, dx , dy)
    mouse.x = x
    mouse.y = y
end

--描画処理
function title:draw()
    -- 描画処理を記述
    love.graphics.setColor(1,1,1,1)
    local sx = love.graphics.getWidth() / background:getWidth()
    local sy = love.graphics.getHeight() / background:getHeight()
    love.graphics.draw(background, 0, 0, 0, sx, sy)

    love.graphics.setColor(255,255,0, 1)
    love.graphics.rectangle( "fill", start_pos_x, start_pos_y, start_width, start_height )

    love.graphics.setColor(0,0,0, 1)
    love.graphics.setFont(font)
    love.graphics.printf(mouse_start_str, 0, start_pos_y, wdw_w,'center')

    -- すみっこにスコアを表示する
    love.graphics.setColor(0,0,0, 1)
    love.graphics.setFont(rankfont)
    local rankTitle = "歴代ランキング"
    love.graphics.printf(rankTitle, 0, 10, wdw_w,'right')
    for key, value in pairs(scoreTbl) do                
        if(value > 999) then
            value = 999
        end
        local rankText = "No." .. key .. " " .. string.format("%03s", value)
        love.graphics.printf(rankText, 0, 10 + key * 35, wdw_w,'right')
    end

    

    -- マウス位置にアイコン表示
    mouse_x_offset  = ( playerImage:getWidth() / 2 )
    mouse_y_offset =  ( playerImage:getHeight() / 2 )
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw( playerImage, mouse.x - mouse_x_offset ,mouse.y - mouse_y_offset, 0)

    if(mouse.x > start_pos_x and mouse.x < (start_pos_x + start_width) and mouse.y > start_pos_y and mouse.y < (start_pos_y + start_height) ) then
        set_state("game")        
    end


end

return title
