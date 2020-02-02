local game = {}

local mouse = {}
local bgmData = {}
local endSound = {}
local defeatSound = {}

local scorefont = nil
local messagefont = nil

local pigImgs = {}
local playerImages = {}

local ghostImg = nil
local trashImg = nil


local pos1EnemyPopCntTimer = 999
local pos2EnemyPopCntTimer = 999
local pos3EnemyPopCntTimer = 999

local pos1X = 0
local pos1Y = 0

local pos2X = 750
local pos2Y = 0

local pos3X = 1500
local pos3Y = 0

local pigPosX = 0
local pigPosY = 0

local trashPosX = 0
local trashPosY = 0

local enemyR = 70
local playerR = 70
local pigR = 70
local trashR = 70

local enemies = {}


local deltaYBase = 10
local currentdeltaY = deltaYBase


local GAME_STAT_INIT = 0
local GAME_STAT_PLAYING = 1
local GAME_STAT_OVER = 2
local gameState = GAME_STAT_PLAYING

local PLAYER_STAT_NORMAL = 1
local PLAYER_STAT_FULL = 2
local playerState = PLAYER_STAT_NORMAL

local PIG_STAT_NORMAL = 1
local PIG_STAT_DEAD = 2
local pigState = PIG_STAT_NORMAL


local countUpTimer = Timer.new()
local countUpCounter = 0

local walkTimer = Timer.new()

local scoreCounter = 0
local scoreTbl = {}


-- 初期処理（最初の１回のみ実行される）
function game:init()
    print("game:init")


end


-- 開始処理(enter時毎回実行される)
function game:enter()
    print("game:enter")

    -- ここに開始時に行う処理を記述
    background = love.graphics.newImage( "assets/img/game/background_1500x800.jpg")
    
    -- 敵（ゴースト）画像
    ghostImg = love.graphics.newImage("assets/img/game/ghost_150x150.png")

    -- ゴミ箱画像
    trashImg = love.graphics.newImage("assets/img/game/trash_150x150.png")

    endImg = love.graphics.newImage("assets/img/game/game_over_logo.png")
    hiScoreImg = love.graphics.newImage("assets/img/game/hiscore.png")


    -- ぶたくん（生きてるとき、やれれたとき）
    pigImgs[1] = love.graphics.newImage("assets/img/game/pig_150x150.png")
    pigImgs[2 ]= love.graphics.newImage("assets/img/game/pig_dead_150x150.png")
    
    -- プレイヤー（掃除機）の通常時とフル時の２パターンをロードする）
    playerImages[1] = love.graphics.newImage("assets/img/common/cursor_150x150.png")
    playerImages[2] = love.graphics.newImage("assets/img/common/cursor2_150x150.png")

    x, y, w, h = 20, 20, 60, 20

    scr_scale_w = wdw_w / background:getWidth()
    scr_scale_h = wdw_h / background:getHeight()

    canvas = love.graphics.newCanvas(background:getWidth(), background:getHeight())
    


    love.mouse.setPosition(0,0)

    bgmData = love.audio.newSource("assets/bgms/game_maoudamashii_1_battle27.mp3", "stream")

    bgmData:setLooping(true);
    bgmData:play();

    endSound = love.audio.newSource("assets/ses/game_end.ogg", "static")
    endSound:setLooping(false);

    -- 敵倒すときのエフェクト音（吸い込み)
    defeatSound = love.audio.newSource("assets/ses/se_maoudamashii_retro26.ogg", "static")
    defeatSound:setLooping(false);


    messagefont = love.graphics.setNewFont("fonts/PixelMplus12-Regular.ttf", 30)
    scorefont = love.graphics.setNewFont("fonts/PixelMplus12-Regular.ttf", 80)

    -- メインタイマ（カウントアップタイマ）周期を設定(1秒ごとに[mainTimerTick]をコールする)
    countUpTimer:every(1.0, mainTimerTick)
    countUpCounter = 0
    scoreCounter = 0

    --サブタイマ１（ 敵を歩かせるタイマ）を設定
    walkTimer:every(0.1, enemyWalkTick)


    -- ゲーム変数等の初期化を行う
    startGame()

end



-- 敵クラス生成
Enemy = {}
-- 敵クラス「Enemy」のインスタンス関数
Enemy.new = function(_x, _y)
    local obj = {}
    obj.X = _x
    obj.Y = _y

    -- 敵クラス「Enemy」の当たり判定用用関数（円判定）
    obj.collision = function( _targetX, _targetY, _tergetR)
                        local bRet = false
                        local a =  obj.X - _targetX
                        local b =  obj.Y - _targetY
                        local r = (enemyR + _tergetR)  *  (enemyR + _tergetR)
                        if((a * a + b * b) <= r) then
                            bRet = true
                        end
                        return bRet
                    end

    -- 敵クラス「Enemy」の歩行用関数
    obj.move = function(self)
 
                    print("test")
              end
    return obj



 end


 function enemyWalkTick()
     -- 敵を歩かせる(ここでやるかは検討。別に早いタイマ作ったほうがよい。きっと。)
    for i = 1, #enemies do
        local alpha = ( pigPosX - enemies[i].X ) / ( pigPosY - enemies[i].Y)
        local beta = pigPosX - ( alpha * pigPosY)
        local new_y = enemies[i].Y + currentdeltaY
        local new_x = alpha * new_y + beta

        enemies[i].X = new_x
        enemies[i].Y = new_y
    end
  
 end

 -- メインタイマ
function mainTimerTick()
    if (gameState == GAME_STAT_INIT ) then
        startGame()
    end   

    -- カウントアップ
    countUpCounter = countUpCounter + 1    

    -- ３秒ごとに敵を強くする
    if(countUpCounter % 3 == 0) then
        currentdeltaY = deltaYBase * math.floor(countUpCounter / 3)       
    end

    -- ゲーム中ならば敵生成ロジック処理
    if(gameState == GAME_STAT_PLAYING) then

        --　敵の涌くポイント３つのカウンタ処理
        pos1EnemyPopCntTimer = pos1EnemyPopCntTimer - 1;
        pos2EnemyPopCntTimer = pos2EnemyPopCntTimer - 1;
        pos3EnemyPopCntTimer = pos3EnemyPopCntTimer - 1;
        
        local newEnemIndex = #enemies + 1
        --
        if( pos1EnemyPopCntTimer < 0 ) then
            enemies[newEnemIndex] = Enemy.new(pos1X, pos1Y)
            newEnemIndex = newEnemIndex + 1
            pos1EnemyPopCntTimer = math.random(2, 6) -- 2～6秒後に再度生成させる
        end
    
        if( pos2EnemyPopCntTimer < 0 ) then
            enemies[newEnemIndex] = Enemy.new(pos2X, pos2Y)
            newEnemIndex = newEnemIndex + 1
            pos2EnemyPopCntTimer = math.random(2, 6) -- 2～6秒後に再度生成させる
        end
        
    
        if( pos3EnemyPopCntTimer < 0 ) then
            enemies[newEnemIndex] = Enemy.new(pos3X, pos3Y)
            newEnemIndex = newEnemIndex + 1
            pos3EnemyPopCntTimer = math.random(2, 6) -- 2～6秒後に再度生成させる
        end    
        
    end

end

-- ゲーム開始
function startGame()
    --ランク(スコア)取得
    scoreTbl = getRanks()

    -- ランダムシードのリセット
    math.randomseed(os.time())

    -- 敵配列の初期化
    enemies = {}

    -- プレイヤー状態初期化
    playerState = PLAYER_STAT_NORMAL

    -- ぶたくん状態初期化
    pigState = PIG_STAT_NORMAL

    -- ぶたくんの位置を決める
    pigPosX =  750 - 75
    pigPosY = 800 - 150

    -- ゴミ箱の位置を決める
    trashPosX = pigPosX + 200
    trashPosY = pigPosY
    

    -- 敵涌きポイントのカウントダウンタイマをランダムリセット
    pos1EnemyPopCntTimer = math.random(2, 5) -- 2～5秒
    pos2EnemyPopCntTimer = math.random(2, 5) -- 2～5秒
    pos3EnemyPopCntTimer = math.random(2, 5) -- 2～5秒

    -- ゲーム状態を開始にする
    gameState = GAME_STAT_PLAYING
end


-- 更新処理
function game:update(dt)
    -- タイマ系はここで必ずupdateをコールする
    countUpTimer:update(dt)
    walkTimer:update(dt)

    -- 一定間隔で行う処理を記述
    local tmp_mouse = {}
    tmp_mouse.x, tmp_mouse.y = love.mouse.getPosition()
    mouse.x =  math.floor(tmp_mouse.x * (1 / scr_scale_w)) -- - player:getWidth() / 2)
    mouse.y =  math.floor(tmp_mouse.y * (1 / scr_scale_h)) -- - player:getHeight() / 2)


    -- プレイヤーの状態リセットを確認する（※ごみ箱に当たり判定していればNORMALに戻す)
    local bCollision = false
    local a =  trashPosX - (mouse.x - 75)
    local b =  trashPosY - (mouse.y - 50)
    local r = (trashR + playerR)  *  (trashR + playerR)
    if((a * a + b * b) <= r) then
        bCollision = true
    end
    if(bCollision == true) then
        playerState = PLAYER_STAT_NORMAL
    end
    
    -- 敵が存在するかどうかをチェック
    if( #enemies >  0 and gameState ~= GAME_STAT_OVER) then
        -- print("enmCnt = " .. #enemies )
        -- 敵の数だけ表示する.あたり判定もここで実施
        for i =  #enemies, 1, -1 do
            local bHit = enemies[i].collision(mouse.x - 75, mouse.y - 50, playerR)
            if(bHit == true and playerState == PLAYER_STAT_NORMAL) then
                -- 当たったものは削除する
                table.remove(enemies, i)   

                -- 音を鳴らす
                defeatSound:play()

                --　スコアを＋１する
                scoreCounter = scoreCounter + 1

                --プレイヤーの状態をFULLにする
                playerState = PLAYER_STAT_FULL
            else
                -- ぶたさんとのあたり判定も行う
                bHit = enemies[i].collision(pigPosX, pigPosY, pigR)

                if(bHit == true) then
                    -- ぶたくんが攻撃されたらゲーム終了
                    gameState = GAME_STAT_OVER

                    -- ぶたくんの画像を差し替える
                    pigState = PIG_STAT_DEAD

                    -- ゲームタイマを-5秒しておく（5秒間結果表示させるため）
                    countUpCounter = -5
                    bgmData:stop()
                    endSound:play()
                    -- タイマもクリアしておく
                    walkTimer:clear()
                    Timer.cancel(walkTimer)
                    break

                end
            end

        end
    end

end



--描画処理
function game:draw()
    -- 描画処理を記述

    -- 画面クリア
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 1)

    love.graphics.setCanvas(canvas)

    --背景描写
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(background, 0, 0, 0)

    --残りタイマラベル描写
    love.graphics.setFont(messagefont)
    love.graphics.printf("つかまえた数           経過時間", 0, 0, background:getWidth(), 'right')

    --スコア値描写
    love.graphics.setFont(scorefont)
    love.graphics.setColor(0.5, 1, 0.5, 1)
    love.graphics.printf(tostring(scoreCounter) ,1100, 50, 500, 'left')

    --経過タイマ値描写
    love.graphics.setFont(scorefont)
    love.graphics.setColor(1, 1, 1, 1)
    local timeVal = countUpCounter
    if(countUpCounter < 0) then
        timeVal = 0
    end
    love.graphics.printf(tostring(timeVal) ,0, 50, background:getWidth(), 'right')
    

    --ぶたさん描写(1500x800の真ん中＋最下に配置->ぶたくんの画像サイズで位置調整)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(pigImgs[pigState], pigPosX, pigPosY, 0)    

    --ごみ箱描写
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(trashImg, trashPosX, trashPosY, 0)    
    
     -- 敵が存在するかどうかをチェック（※ゲームオーバ時も敵を表示したい）
     if( #enemies >  0) then
        -- 敵の数だけ表示する.
       for i =  #enemies, 1, -1 do
            love.graphics.draw( ghostImg, enemies[i].X, enemies[i].Y, 0)  
       end
   end

    -- ゲーム中かどうか判定
    if ( gameState ~= GAME_STAT_OVER) then
        -- ゲーム中

        -- プレイヤーキャラをマウスの場所に描写する
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw( playerImages[playerState], mouse.x - 75, mouse.y - 50, 0)
    
    else
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw( endImg,640, 150, 0)

        local bCheck = false
        local currentRank = -1
        local checkTble = {}
        bCheck, currentRank, checkTble = checkHiScore(scoreTbl, scoreCounter)


        if(bCheck == true) then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(hiScoreImg, 410, 270, 0, 2, 2)                

            love.graphics.setFont(scorefont)
            love.graphics.setColor(1, 0, 0.5, 1)
            love.graphics.printf( "Your New No." .. tostring(currentRank).. " !!" ,450, 400, background:getWidth(), 'left')
        end
        
        if( countUpCounter == 0 ) then
            -- スコア更新がある場合スコアテーブルを更新する
            if(bCheck == true) then
                updateFile(checkTble)
            end

            -- 変数およびタイマをクリアしておく（時間ゲーム開始のため）
            countUpCounter = 0
            scoreCounter = 0
            countUpTimer:clear()
            Timer.cancel(countUpTimer)
            set_state("title")
        end
    end


    -- キャンバスを画面に出力
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas, scr_ofsx, scr_ofsy, 0, wdw_w / background:getWidth(), wdw_h / background:getHeight())
end


return game
