require('love')
-- Data Types
require('Vector2')
require('Timer')
require('InputBuffer')
-- Components
require('Grid')
require('Entity')
require('EntityAI')
require('EntityManager')
require('Action')
require('Effect')

local grid
local scale
local canvas
local player
local enemies
local test_enemy_1
local test_enemy_2
local cell_size
local entity_ai_pace_1
local entity_ai_pace_2
local entity_manager
local timer
local input_buffer

Config = {
    GAME_WIDTH = 320,
    GAME_HEIGHT = 180
}

-- TODO::Move to helper file
DIR = {
    VEC = {
        Vec2:new(0, -1),
        Vec2:new(0, 1),
        Vec2:new(1, 0),
        Vec2:new(-1, 0),
        Vec2:new(0, 0),
    },
    KEY = {
        NORTH = 1,
        SOUTH = 2,
        EAST = 3,
        WEST = 4,
        NONE = 5,
    }
}

-- TODO::Create list of valid inputs. Validate input based on if it's in the list.

local function is_valid_dir_key(key)
    return key == 'w' or key == 's' or key == 'd' or key == 'a'
end

local function is_valid_rotate_key(key)
    return key == 'q' or key == 'e'
end

local function is_valid_mode_key(key)
    return key == 'space' or key == 'j' or key == 'i' or key == 'r'
end

local function input_move_dir(key)
    if key == "w" then return DIR.VEC[DIR.KEY.NORTH] end
    if key == "s" then return DIR.VEC[DIR.KEY.SOUTH] end
    if key == "d" then return DIR.VEC[DIR.KEY.EAST] end
    if key == "a" then return DIR.VEC[DIR.KEY.WEST] end
    return DIR.VEC[DIR.KEY.NONE]
end

local function handle_player()
    for idx, input in ipairs(input_buffer.queue) do
        local key = input[idx]
        local is_move_key = is_valid_dir_key(key)
        local is_rotate_key = is_valid_rotate_key(key)
        local is_action_key = is_valid_mode_key(key)

        if is_move_key then
            player.move_dir = input_move_dir(key)
            if not grid:is_oobs(player.pos:add(player.move_dir)) and grid:get_cell(player.pos:add(player.move_dir)) == nil then
                player:move(player.move_dir)
                player.render_pos = player.pos:add(Vec2:new(-1, -1)):mult(Vec2:new(cell_size, cell_size))
            end
        elseif is_rotate_key then
            local rot_dir = 0
            if key == 'q' then
                rot_dir = -1
            elseif key == 'e' then
                rot_dir = 1
            end
            player:rotate(rot_dir)
        elseif is_action_key then
            if key == 'space' then
                player.actions[1]:execute(player.pos, player.rot_dir, grid)
            elseif key == 'j' then
                player.actions[2]:execute(player.pos, player.rot_dir, grid)
            elseif key == 'i' then
                player.actions[3]:execute(player.pos, player.rot_dir, grid)
            elseif key == 'r' then
                input_buffer:clear()
            end
        end
        entity_manager:update_entities(cell_size, cell_size)
        grid:update_entities(entity_manager.entities)
    end
end

local function handle_entities()

end

function love.load()
    cell_size = 16
    grid = Grid:new { col_num = 10, row_num = 10 }
    player = Entity:new {
        pos = Vec2:new(1, 1),
        render_pos = Vec2:new(0, 0),
        actions = {
            Action:new({
                name = 'Punch',
                effects = {
                    Effect:new { pos = Vec2:new(0, -1), health = -1 },
                    Effect:new { pos = Vec2:new(0, -2), health = -1 },
                }
            }),
            Action:new({
                name = 'Push',
                effects = {
                    Effect:new { pos = Vec2:new(0, -1), health = 0, move_dir = Vec2:new(0, -1) },
                }
            }),
            Action:new({
                name = 'Pull',
                effects = {
                    Effect:new { pos = Vec2:new(0, -2), health = 0, move_dir = Vec2:new(0, 1) },
                }
            })
        }
    }

    -- entity_ai_pace_1 = EntityAI.Pace:new {
    --     move_dir = Vec2:new(1, 0),
    --     max_steps = 1,
    -- }

    entity_ai_pace_2 = EntityAI.Pace:new {
        move_dir = Vec2:new(0, -1),
        max_steps = 2,
    }

    -- test_enemy_1 = Entity:new {
    --     pos = Vec2:new(8, 8),
    --     render_pos = Vec2:new((8 - 1) * cell_size, (8 - 1) * cell_size),
    --     ai = entity_ai_pace_1
    -- }
    test_enemy_2 = Entity:new {
        pos = Vec2:new(6, 6),
        render_pos = Vec2:new((6 - 1) * cell_size, (6 - 1) * cell_size),
        ai = entity_ai_pace_2
    }

    enemies = {
        Entity:new {
            pos = Vec2:new(4, 4),
            render_pos = Vec2:new((4 - 1) * cell_size, (4 - 1) * cell_size),
            actions = {}
        },
        Entity:new {
            pos = Vec2:new(4, 3),
            render_pos = Vec2:new((4 - 1) * cell_size, (3 - 1) * cell_size),
            actions = {}
        },
        Entity:new {
            pos = Vec2:new(5, 3),
            render_pos = Vec2:new((5 - 1) * cell_size, (3 - 1) * cell_size),
            actions = {}
        },
    }

    entity_manager = EntityManager:new {}
    entity_manager:add_entity(player)
    for _, enemy in ipairs(enemies) do
        entity_manager:add_entity(enemy)
    end
    -- entity_manager:add_entity(test_enemy_1)
    entity_manager:add_entity(test_enemy_2)

    grid:update_entities(entity_manager.entities)

    scale = 3
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setMode(
        Config.GAME_WIDTH * scale,
        Config.GAME_HEIGHT * scale,
        {
            fullscreen = false,
            resizable = false,
        }
    )

    canvas = love.graphics.newCanvas(Config.GAME_WIDTH, Config.GAME_HEIGHT)

    timer = Timer:new(2)
    timer:start()

    input_buffer = InputBuffer:new({ size = 4 })
end

function love.keypressed(key)
    local is_move_key = is_valid_dir_key(key)
    local is_rotate_key = is_valid_rotate_key(key)
    local is_action_key = is_valid_mode_key(key)

    if (not is_move_key) and (not is_rotate_key) and (not is_action_key) then
        return
    end

    input_buffer:push(key)

    if is_move_key then
        player.move_dir = input_move_dir(key)
        if not grid:is_oobs(player.pos:add(player.move_dir)) and grid:get_cell(player.pos:add(player.move_dir)) == nil then
            player:move(player.move_dir)
            player.render_pos = player.pos:add(Vec2:new(-1, -1)):mult(Vec2:new(cell_size, cell_size))
        end
    elseif is_rotate_key then
        local rot_dir = 0
        if key == 'q' then
            rot_dir = -1
        elseif key == 'e' then
            rot_dir = 1
        end
        player:rotate(rot_dir)
    elseif is_action_key then
        if key == 'space' then
            player.actions[1]:execute(player.pos, player.rot_dir, grid)
        elseif key == 'j' then
            player.actions[2]:execute(player.pos, player.rot_dir, grid)
        elseif key == 'i' then
            player.actions[3]:execute(player.pos, player.rot_dir, grid)
        elseif key == 'r' then
            input_buffer:clear()
        end
    end
    entity_manager:update_entities(cell_size, cell_size)
    grid:update_entities(entity_manager.entities)

    -- test_enemy_1:take_turn(grid)
    test_enemy_2:take_turn(grid)

    entity_manager:update_entities(cell_size, cell_size)
    grid:update_entities(entity_manager.entities)
    -- grid:print_debug()

    input_buffer:print_debug()
end

function love.update(dt)
    timer:update(dt)
    if not timer.is_active then
        timer:reset()
        timer:start()
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 1)

    grid:draw(Vec2:new(0, 0), cell_size, cell_size)
    entity_manager:draw(cell_size, cell_size)

    love.graphics.setCanvas()

    love.graphics.draw(canvas, 0, 0, 0, scale, scale)
end
