function love.load()
  sprites = {}
  sprites.player = love.graphics.newImage("sprites/player.png")
  sprites.zombie = love.graphics.newImage("sprites/zombie.png")
  sprites.bullet = love.graphics.newImage("sprites/bullet.png")
  sprites.background = love.graphics.newImage("sprites/background.png")

  player ={}
  player.x=love.graphics.getWidth()/2
  player.y=love.graphics.getHeight()/2
  player.speed =180

  zombies ={}
  bullets={}
  gameState=1
  maxTime=2
  timer=maxTime
  score=0
  myfont = love.graphics.newFont(20)
end


-- para achar valor em radianos formula = angula*(pi/180)
function love.update(dt)
if gameState==2 then
  if love.keyboard.isDown("s") and player.y<love.graphics.getHeight() then
    player.y =player.y+player.speed*dt
  end
  if love.keyboard.isDown("w") and player.y >0 then
    player.y=player.y-player.speed*dt
  end
  if love.keyboard.isDown("d") and player.x < love.graphics.getWidth()then
    player.x=player.x+player.speed*dt
  end
  if love.keyboard.isDown("a") and player.x>0  then
    player.x=player.x-player.speed*dt
  end

  for i,z in ipairs(zombies) do
    -- seno e cosceno utilizado para calcular a angulação de movimento
    z.y= z.y+ math.sin(calcula_Angulo_Zombie(z))*z.speed*dt
    z.x= z.x + math.cos(calcula_Angulo_Zombie(z))*z.speed*dt
    distancia = math.sqrt((z.y-player.y)^2 + (z.x-player.x)^2)
    if distancia < 3 then
      for i,z in ipairs(zombies) do
        zombies[i]=nil
        gameState=1
        maxTime=2
        timer=maxTime
        score=0
        player.x=love.graphics.getWidth()/2
        player.y=love.graphics.getHeight()/2
      end
    end
  end
  for i,b in ipairs(bullets) do
    b.y=b.y+ math.sin(b.direcao)*b.speed*dt
    b.x=b.x + math.cos(b.direcao)*b.speed*dt
  end

  for i=#bullets,1,-1 do
    local b = bullets[i]
    if b.x<0 or b.y<0 or b.x>love.graphics.getWidth() or b.y>love.graphics.getHeight() then
      table.remove(bullets,i)
    end
    if b.dead then
      table.remove(bullets,i)
    end
  end

  for i,z in ipairs(zombies) do
    for j,b in ipairs(bullets) do
        distancia2 = math.sqrt((z.y-b.y)^2 + (z.x-b.x)^2)
        if distancia2<20 then
          z.dead=true
          b.dead=true
          score=score+1
        end
    end
  end
  for i=#zombies,1,-1 do
    local z = zombies[i]
    if z.dead then
      table.remove(zombies,i)
    end
  end
  if gameState==2 then
    timer=timer-dt
    if timer <=0 then
      cria_Zombie()
      maxTime=maxTime*0.95
      timer=maxTime
    end
  end
end
end

function love.draw()
  love.graphics.draw(sprites.background, 0, 0)
  if gameState==1 then
    love.graphics.setFont(myfont)
    love.graphics.printf("Clique em qualquer lugar para iniciar!",0,50,love.graphics.getWidth(),"center")
  else
    love.graphics.setFont(myfont)
    love.graphics.print("Score: "..score,0,0)
  love.graphics.draw(sprites.player, player.x, player.y, calcula_Angulo(),nil,nil,sprites.player:getWidth()/2, sprites.player:getHeight()/2)

  for i,z in ipairs(zombies) do
    love.graphics.draw(sprites.zombie, z.x, z.y, calcula_Angulo_Zombie(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
  end

  for i,b in ipairs(bullets) do
    love.graphics.draw(sprites.bullet,b.x ,b.y,nil,0.5,0.5,sprites.bullet:getWidth()/2,sprites.bullet:getHeight()/2)
  end
end

end


function calcula_Angulo()
  return math.atan2(player.y - love.mouse.getY(),player.x - love.mouse.getX())+math.pi
end

function calcula_Angulo_Zombie(inimigo)
  return math.atan2(player.y - inimigo.y,player.x - inimigo.x)
end

function cria_Zombie()
  local side = math.random(1, 4)
  zombie={}
  zombie.x=0
  zombie.y=0
  zombie.speed=100
  zombie.dead=false

  if side==1 then
    zombie.x=-30
    zombie.y=math.random(0, love.graphics.getHeight())
  elseif side==2 then
  zombie.x=math.random(0, love.graphics.getWidth())
  zombie.y=-30
elseif side==3 then
  zombie.x=love.graphics.getWidth()+30
  zombie.y=math.random(0, love.graphics.getHeight())
else
  zombie.x=math.random(0, love.graphics.getWidth())
  zombie.y=love.graphics.getHeight()+30
  end
  table.insert(zombies,zombie)
end
function cria_Tiro()
  bullet ={}
  bullet.x=player.x
  bullet.y=player.y
  bullet.speed=500
  bullet.dead=false
  bullet.direcao=calcula_Angulo()
  table.insert(bullets,bullet)
end

function love.mousepressed(x, y, button, isTouch)
  if gameState==1 then
    gameState=2
  else
    if button==1 and gameState==2 then
      cria_Tiro()
    end
  end
end
