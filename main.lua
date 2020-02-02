local jsonData = require ("json");

-- 画面遷移用ライブラリ
local Gamestate = require "libs.hump.gamestate"

-- タイマ用ライブラリ
Timer = require "libs.hump.timer"

-- 画面遷移リスト
local states = {
  -- ここに遷移先となる画面のメインluaのファイルを記述
  -- [state_name] = require [遷移先のluaファイルパス]
  title = require "states.title.main",
  game = require "states.game.main"
}
-- 画面名
local state_name = ""

-- 画面遷移処理
-- name: 画面遷移リストに存在する名前
function set_state(name)
  state_name = name
  Gamestate.switch(states[state_name])
end

function init_state()
  state_name = "title"
  Gamestate.pop()
end


-- 開始処理
function love.load()
  -- ウィンドウサイズの取得
  wdw_w, wdw_h = love.graphics.getDimensions()
  Gamestate.registerEvents()
  -- ここに開始時に行う処理を記述
  set_state("title")
end

-- 更新処理
function love.update(dt)
  -- 一定間隔で行う処理を記述
end

-- 描画処理
function love.draw()
  -- 描画処理を記述
end

-- キーボード処理(キーが離された時)
function love.keyreleased(key)
    -- エスケープキーでゲーム終了
    if key == "escape" then
      love.event.quit()
    end
end

function getImageScaleForNewDimensions( image, newWidth, newHeight )
  local currentWidth, currentHeight = image:getDimensions()
  return ( newWidth / currentWidth ), ( newHeight / currentHeight )
end


function createScoreFile()
  local info = love.filesystem.getInfo( "score.txt" )
  if (info ~= nil) then
    print("YES")
  else
    print("NO")
    local rankInfo = {no1 = 0, no2 = 0, no3 = 0, no4 = 0, no5 = 0}
    local strData = jsonData.encode(rankInfo)
    love.filesystem.write( "score.txt", strData )
  end 
end

function getRanks()
  ret_tbl = {0,0,0,0,0}
  local rankInfo = {no1 = 0, no2 = 0, no3 = 0, no4 = 0, no5 = 0}
  local contents, size
  contents, size = love.filesystem.read( "score.txt" )
  local rankInfo = jsonData.decode(contents)
  ret_tbl[1] = rankInfo["no1"]
  ret_tbl[2] = rankInfo["no2"]
  ret_tbl[3] = rankInfo["no3"]
  ret_tbl[4] = rankInfo["no4"]
  ret_tbl[5] = rankInfo["no5"]
  return ret_tbl
end



function updateFile(_tbl)
  local rankInfo = {no1 = 0, no2 = 0, no3 = 0, no4 = 0, no5 = 0}
  rankInfo["no1"] = _tbl[1]
  rankInfo["no2"] = _tbl[2]
  rankInfo["no3"] = _tbl[3]
  rankInfo["no4"] = _tbl[4]
  rankInfo["no5"] = _tbl[5]
  jsonData.encode(rankInfo)
  local strData = jsonData.encode(rankInfo)
  love.filesystem.write( "score.txt", strData )

end


function checkHiScore( _tbl, _score)
  local bCheck = false
  local rank = -1
  local old_score = 0
  local retTbl =  {unpack(_tbl)}
  for key, value in pairs(_tbl) do
    if(bCheck == false) then
      if(value < _score) then
        bCheck = true
        rank = key
        old_score = value
        retTbl[key] = _score      
      end  
    else
      retTbl[key] = old_score
      old_score = value    
    end
  end
  return bCheck, rank, retTbl
end

