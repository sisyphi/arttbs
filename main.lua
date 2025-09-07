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
require('Helper')

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

INPUT_MAP = {
    DIR_UP = { 'w' },
    DIR_RIGHT = { 'd' },
    DIR_DOWN = { 's' },
    DIR_LEFT = { 'a' },
    ROT_LEFT = { 'q' },
    ROT_RIGHT = { 'e' },
    RESET = { 'space' },
    MODE_1 = { 'j' },
    MODE_2 = { 'i' },
    MODE_3 = { 'o' },
}

local function get_input(key)
    for _, input_key in ipairs(INPUT_MAP.DIR_UP) do
        if key == input_key then
            return 'DIR_UP'
        end
    end

    for _, input_key in ipairs(INPUT_MAP.DIR_RIGHT) do
        if key == input_key then
            return 'DIR_RIGHT'
        end
    end

    for _, input_key in ipairs(INPUT_MAP.DIR_DOWN) do
        if key == input_key then
            return 'DIR_DOWN'
        end
    end

    for _, input_key in ipairs(INPUT_MAP.DIR_LEFT) do
        if key == input_key then
            return 'DIR_LEFT'
        end
    end

    for _, input_key in ipairs(INPUT_MAP.ROT_LEFT) do
        if key == input_key then
            return 'ROT_LEFT'
        end
    end

    for _, input_key in ipairs(INPUT_MAP.ROT_RIGHT) do
        if key == input_key then
            return 'ROT_RIGHT'
        end
    end

    for _, input_key in ipairs(INPUT_MAP.RESET) do
        if key == input_key then
            return 'RESET'
        end
    end

    for _, input_key in ipairs(INPUT_MAP.MODE_1) do
        if key == input_key then
            return 'MODE_1'
        end
    end

    for _, input_key in ipairs(INPUT_MAP.MODE_2) do
        if key == input_key then
            return 'MODE_2'
        end
    end

    for _, input_key in ipairs(INPUT_MAP.MODE_3) do
        if key == input_key then
            return 'MODE_3'
        end
    end

    return nil
end

local function is_mode_input(input)
    return input == 'MODE_1' or input == 'MODE_2' or input == 'MODE_3'
end
local function is_dir_input(input)
    return input == 'DIR_UP' or input == 'DIR_RIGHT' or input == 'DIR_DOWN' or input == 'DIR_LEFT'
end

local function is_rot_input(input)
    return input == 'ROT_LEFT' or input == 'ROT_RIGHT'
end

local function translate_to_dir_vec(input)
    if input == 'DIR_UP' then return DIR.VEC[DIR.KEY.NORTH] end
    if input == 'DIR_RIGHT' then return DIR.VEC[DIR.KEY.EAST] end
    if input == 'DIR_DOWN' then return DIR.VEC[DIR.KEY.SOUTH] end
    if input == 'DIR_LEFT' then return DIR.VEC[DIR.KEY.WEST] end
    return DIR.VEC[DIR.KEY.NONE]
end
local function translate_to_rot(input)
    if input == 'ROT_LEFT' then return -1 end
    if input == 'ROT_RIGHT' then return 1 end
    return 0
end
local function translate_to_mode(input)
    if input == 'MODE_1' then return '' end
    if input == 'MODE_2' then return '' end
    if input == 'MODE_3' then return '' end
    return nil
end

local function handle_player_single_mode(input)
    if is_dir_input(input) then
        local dir = translate_to_dir_vec(input)
        player.move_dir = dir
        if not grid:is_oobs(player.pos:add(player.move_dir)) and grid:get_cell(player.pos:add(player.move_dir)) == nil then
            player:move(player.move_dir)
            player.render_pos = player.pos:add(Vec2:new(-1, -1)):mult(Vec2:new(cell_size, cell_size))
        end
    elseif is_rot_input(input) then
        player:rotate(translate_to_rot(input))
    elseif is_mode_input(input) then
        player.actions[1]:execute(player.pos, player.rot_dir, grid)
    end
    entity_manager:update_entities(cell_size, cell_size)
    grid:update_entities(entity_manager.entities)
    grid:print_debug()
end

local function handle_player_buffer_mode(input)
    if is_mode_input(input) then
        player.mode = input
    elseif is_dir_input(input) then
        local dir = translate_to_dir_vec(input)
        if player.mode == 'MODE_1' then
            player.move_dir = dir
            if not grid:is_oobs(player.pos:add(player.move_dir)) and grid:get_cell(player.pos:add(player.move_dir)) == nil then
                player:move(player.move_dir)
                player.render_pos = player.pos:add(Vec2:new(-1, -1)):mult(Vec2:new(cell_size, cell_size))
            end
        elseif player.mode == 'MODE_2' then
            player.rot_dir = dir
            player.actions[1]:execute(player.pos, player.rot_dir, grid)
        elseif player.mode == 'MODE_3' then
            print('TODO::No implementation for MODE_3')
        end
    end
    entity_manager:update_entities(cell_size, cell_size)
    grid:update_entities(entity_manager.entities)
    grid:print_debug()
end

local function handle_entities()
    -- test_enemy_1:take_turn(grid)
    test_enemy_2:take_turn(grid)

    entity_manager:update_entities(cell_size, cell_size)
    grid:update_entities(entity_manager.entities)
    -- grid:print_debug()
end

function love.load()
    cell_size = 16
    grid = Grid:new { col_num = 10, row_num = 10 }
    player = Entity:new {
        category = 'player',
        pos = Vec2:new(1, 1),
        render_pos = Vec2:new(0, 0),
        actions = {
            Action:new({
                name = 'Punch',
                effects = {
                    Effect:new { pos = Vec2:new(0, -1), health = -1 },
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
    --     category = 'enemy',
    --     pos = Vec2:new(8, 8),
    --     render_pos = Vec2:new((8 - 1) * cell_size, (8 - 1) * cell_size),
    --     ai = entity_ai_pace_1
    -- }
    test_enemy_2 = Entity:new {
        category = 'enemy',
        pos = Vec2:new(6, 6),
        render_pos = Vec2:new((6 - 1) * cell_size, (6 - 1) * cell_size),
        ai = entity_ai_pace_2
    }

    enemies = {
        Entity:new {
            category = 'enemy',
            pos = Vec2:new(4, 4),
            render_pos = Vec2:new((4 - 1) * cell_size, (4 - 1) * cell_size),
            actions = {}
        },
        Entity:new {
            category = 'enemy',
            pos = Vec2:new(4, 3),
            render_pos = Vec2:new((4 - 1) * cell_size, (3 - 1) * cell_size),
            actions = {}
        },
        Entity:new {
            category = 'enemy',
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
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setMode(
        Config.GAME_WIDTH * scale,
        Config.GAME_HEIGHT * scale,
        {
            fullscreen = false,
            resizable = false,
        }
    )

    canvas = love.graphics.newCanvas(Config.GAME_WIDTH, Config.GAME_HEIGHT)

    timer = Timer:new(1)
    timer:start()

    input_buffer = InputBuffer:new({ size = 1 })
end

function love.keypressed(key)
    local input = get_input(key)

    if input == nil then return end

    input_buffer:push(input)
end

local action_timer = 0
local action_duration = 0.3
local is_executing = false
local current_action = nil
local action_queue = {}
local in_turn = false

function love.update(dt)
    timer:update(dt)

    if not in_turn and not timer.is_active then
        action_queue = input_buffer:flush()
        input_buffer:clear()
        timer:reset()
        in_turn = true
    end

    if in_turn then
        if is_executing then
            action_timer = action_timer - dt
            if action_timer <= 0 then
                is_executing = false
            end
        else
            current_action = table.remove(action_queue, 1)
            if current_action then
                handle_player_single_mode(current_action)
                action_timer = action_duration
                is_executing = true
            else
                handle_entities()
                timer:start()
                in_turn = false
            end
        end
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(Helper.hex_to_rgba('#e8c170'))
    grid:draw(Vec2:new(0, 0), cell_size, cell_size)
    entity_manager:draw(cell_size, cell_size)

    love.graphics.setCanvas()

    love.graphics.draw(canvas, 0, 0, 0, scale, scale)
end
