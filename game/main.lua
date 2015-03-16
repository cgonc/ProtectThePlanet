display.setStatusBar(display.HiddenStatusBar)

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local spawnEnemy
local gameTitle
local scoreText
local score = 0
local hitPlanet
local planet
local enemyArrivalTime = 4000
local planetHealtBarClosure

local sndKill = audio.loadSound("boing-1.wav")
local sndBlast = audio.loadSound("blast.mp3")
local sndLose = audio.loadSound("wahwahwah.mp3")

local function createPlayScreen()
    local background = display.newImage("background.png")
    background.y = 130
    background.alpha = 0

    planet = display.newImage("planet.png")
    planet.x = centerX
    planet.y = display.contentHeight + 60
    planet.alpha = 0

    transition.to(background, {time = 2000, alpha = 1, y = centerY, x= centerX })

    local function showTitle()
        gameTitle = display.newImage("gametitle.png")
        gameTitle.alpha = 0
        gameTitle:scale(4,4)
        transition.to(gameTitle, {time=500 , alpha=1, xScale=1, yScale=1})
        startGame()
    end
    transition.to(planet, {time=2000, alpha =1, y=centerY, onComplete=showTitle})
end

function spawnEnemy()
    local kindOfEnemy = math.random(3)
    local enemy
    if kindOfEnemy == 1 then
        enemy = display.newImage("beetleship.png")
    elseif kindOfEnemy == 2 then
        enemy = display.newImage("octopus.png")
    else
        enemy = display.newImage("rocketship.png")
    end

    enemy:addEventListener("tap" , shipSmash)
    if math.random(2) == 1 then
        enemy.x = math.random (-100, -10)
    else
        enemy.x = math.random(display.contentWidth + 10, display.contentWidth + 100)
        enemy.xScale = -1
    end
    enemy.y = math.random(20, display.contentHeight-20)
    enemy.trans = transition.to (enemy, {x=centerX, y=centerY, time=enemyArrivalTime, onComplete = hitPlanet})
end

function startGame()
    local text = display.newText("Tap here to start. Protect the planet!", 0, 0, "Helvetica", 24)
    text.x = centerX
    text.y = display.contentHeight - 30

    local function goAway(event)
        display.remove(event.target)
        text = nil
        display.remove(gameTitle)
        spawnEnemy()
        scoreText = display.newText("Score : 0",0,0,"Helvetica",22)
        scoreText.x = centerX
        scoreText.y = 10
        score = 0
        planetHealtBarClosure = planetHealthDemage()
        planet.numHits = 100
        planet.alpha = 1
        local enemyArrivalTime = 4000
    end
    text:addEventListener("tap", goAway)

end

local function planetDamage()
    planet.numHits = planet.numHits - 10
    planet.alpha = planet.numHits / 100
    if planet.numHits < 10 then
        planet.alpha = 0.01
        timer.performWithDelay ( 1000, startGame )
        audio.play ( sndLose )
        display.remove( scoreText )
        display.remove( healthBar )
        display.remove( damageBar )
    else
        local function goAway(obj)
            planet.xScale = 1
            planet.yScale = 1
            planet.alpha = planet.numHits / 100
        end
        transition.to (planet, {time = 200, xScale=1.4, yScale=1.4, alpha=1, onComplete=goAway})
    end
    planetHealtBarClosure(10)
end


function hitPlanet(obj)
    display.remove(obj)
    planetDamage()
    audio.play(sndBlast)
    enemyArrivalTime = 4000
    if planet.numHits > 1 then
        spawnEnemy()
    end
end


function shipSmash(event)
    if enemyArrivalTime > 2000 then
        enemyArrivalTime = enemyArrivalTime - 100
    end
    local obj = event.target
    display.remove(obj)
    audio.play(sndKill)
    transition.cancel (event.target.trans)
    score = score + 10
    scoreText.text = "Score: " .. score
    spawnEnemy()
    return true
end

function planetHealthDemage()
    local maxHealth = 100
    local currentHealth = 100
    healthBar = display.newRect(centerX - maxHealth /2, centerY + planet.height/2, maxHealth, 20)
    healthBar:setFillColor( 0, 255, 0 )
    healthBar.strokeWidth = 1

    damageBar = display.newRect(centerX - maxHealth /2, centerY + planet.height/2, 0, 20)
    damageBar:setFillColor( 255, 0, 0 )

    local function updateDamageBar()
        damageBar.width = maxHealth - currentHealth
        damageBar.x = healthBar.x - (healthBar.width/2 - damageBar.width/2)
    end

    local closure = function(damageTaken)
        currentHealth = currentHealth - damageTaken
        updateDamageBar()
    end
    return closure
end

createPlayScreen()




