push = require 'push'

WELCOME_SCREEN = 'welcome'
PLAY_SCREEN = 'play'

g = love.graphics

WINDOW_WIDTH = 500
WINDOW_HEIGHT = 700

GRID_SIZE = WINDOW_WIDTH
CELL_SIZE = GRID_SIZE / 3

xSprite = love.graphics.newImage('x.png')
oSprite = love.graphics.newImage('o.png')

current_player = 'x'

winner = ''
game_over = false

grid = {
    '', '', '', 
    '', '', '',
    '', '', ''
}

function love.load()
    love.window.setTitle('Tic Tac Toe')
    push:setupScreen(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
    })
    loadFonts()
    current_screen = WELCOME_SCREEN
end

function love.draw()
    push:apply('start')

    g.setFont(bigFont)

    if current_screen == WELCOME_SCREEN then
        welcomeScreen()
    elseif current_screen == PLAY_SCREEN then
        playScreen()
    end      

    push:apply('end')
end

function love.keypressed(key)
    if current_screen == WELCOME_SCREEN and key == 'return' then
        current_screen = PLAY_SCREEN
    elseif current_screen == PLAY_SCREEN and game_over then
        if key == 'return' then
            newGame()
        else
            love.event.quit()
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if current_screen ~= PLAY_SCREEN then return end
    if game_over then return end
    if button ~= 1 then return end

    local x = math.floor(x / CELL_SIZE) + 1
    local y = math.floor(y / CELL_SIZE) + 1
    local index = gridIndex(x, y)

    if y > 3 or grid[index] ~= '' then return end

    grid[index] = current_player
    if hasWon(current_player) then
        winner = current_player
        game_over = true
        return
    end

    if isDraw(current_player) then
        game_over = true
    end

    if current_player == 'x' then
        current_player = 'o'
    else
        current_player = 'x'

    end
end


function drawGrid()
    g.line(0, GRID_SIZE / 3, GRID_SIZE, GRID_SIZE / 3)
    g.line(0, 2 * GRID_SIZE / 3, GRID_SIZE, 2 * GRID_SIZE / 3)

    g.line(GRID_SIZE / 3, 0, GRID_SIZE / 3, GRID_SIZE)
    g.line(2 * GRID_SIZE / 3, 0, 2 * GRID_SIZE / 3, GRID_SIZE)
end

function drawSprite(sprite, index)
    local x = math.floor((index - 1) / 3) + 1
    local y = (index - 1) % 3 + 1  
    local x_margin = (CELL_SIZE - sprite:getWidth()) / 2
    local y_margin = (CELL_SIZE - sprite:getHeight()) / 2

    g.draw(sprite, x_margin + (x - 1) * CELL_SIZE, y_margin + (y - 1) * CELL_SIZE)
    
end 

function welcomeScreen()
    g.printf('Welcome to Tic Tac Toe!!', 0, 20, WINDOW_WIDTH, 'center')
    g.setFont(smallFont)
    g.printf('Enter to play', 0 , 70, WINDOW_WIDTH, 'center')
end

function playScreen()
    drawGrid()
    drawNonEmptyCells()
    if not game_over then 
        drawCurrentPlayer()
    else
        drawGameOverMessage() 
    end
end

function drawNonEmptyCells()
    for index = 1, 9 do
        if grid[index] ~= '' then
            if grid[index] == 'x' then
                drawSprite(xSprite, index) 
            else
                drawSprite(oSprite, index)
            end
        end
    end
end

function hasWon(player)
    win_table = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9},
        {1, 4, 7},
        {2, 5, 8},
        {3, 6, 9},
        {1, 5, 9},
        {3, 5, 7}
    } 

    for row = 1, 8 do
        local cell1 = grid[win_table[row][1]]
        local cell2 = grid[win_table[row][2]]
        local cell3 = grid[win_table[row][3]]
        if cell1 == player and cell2 == player and cell3 == player then
            return true
        end
    end
    return false
end

function isDraw(player)
    if hasWon(player) then return false end
    for x = 1, 9 do
        if grid[x] == '' then return false end
    end
    return true
end

function loadFonts()
    bigFont = g.newFont('Noteworthy.ttf', 40)
    smallFont = g.newFont('Noteworthy.ttf', 30)
end

function gridIndex(x, y)    
    return 3 * (x - 1) + y
end

function drawGameOverMessage()
    g.printf('GAME OVER', 0, GRID_SIZE, WINDOW_WIDTH, 'center')
    if winner ~= '' then
        g.printf('Player ' .. current_player ..' wins!!!', 0, GRID_SIZE + 50, WINDOW_WIDTH, 'center')
    end
    if isDraw(current_player) then
        g.printf('Draw!!!!', 0 , GRID_SIZE + 50, WINDOW_WIDTH, 'center')
    end
    g.setFont(smallFont)
    g.printf('Press enter to replay, any other key to exit.', 0, GRID_SIZE + 110, WINDOW_WIDTH, 'center')
end

function drawCurrentPlayer()
    g.printf("Player " .. current_player .. "'s turn", 0, GRID_SIZE, WINDOW_WIDTH, 'center')
end

function newGame()
    game_over = false
    winner = ''
    current_player = 'x'
    for index = 1, 9 do
        grid[index] = ''
    end
end
