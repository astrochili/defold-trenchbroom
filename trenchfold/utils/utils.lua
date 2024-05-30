--[[
  utils.lua
  github.com/astrochili/defold-trenchfold

  Copyright (c) 2022 Roman Silin
  MIT license. See LICENSE for details.
--]]

local math_min = math.min

local utils = {}

--
-- Local

local folder_separator = package.config:sub(1, 1)

local function make_flags_progression()
  local flags = { 1 }
  local max_flag = 0

  for index = 1, 31 do
    local flag = 2 ^ (index - 1)
    flags[index] = flag
    max_flag = max_flag + flag
  end

  return flags, max_flag
end

local flags, max_flag = make_flags_progression()

--
-- Public

function utils.keys(source)
  local keys = {}
  local index = 0

  for key, _ in pairs(source) do
    index = index + 1
    keys[index] = key
  end

  return keys
end

function utils.boolean_from_string(value)
  local boolean

  if value == 'true' then
    boolean = true
  elseif value == 'false' then
    boolean = false
  end

  return boolean
end

function utils.flags_from_integer(integer)
  if integer < 1 then
    return {}
  end

  local integer = math_min(integer, max_flag)
  local lower_flag = nil

  for index = 1, #flags do
    local flag = flags[index]

    if integer == flag then
      lower_flag = integer
      break
    end

    if flag < integer then
      lower_flag = flag
    else
      break
    end
  end

  local flags = utils.flags_from_integer(integer - lower_flag)
  table.insert(flags, lower_flag)

  return flags
end

function utils.count(dict)
  local count = 0

  for _ in pairs(dict) do
    count = count + 1
  end

  return count
end

function utils.shallow_copy(orig)
  if orig == nil then
    return nil
  end

  local copy = {}

  for key, value in pairs(orig) do
    copy[key] = value
  end

  return copy
end

function utils.has_prefix(str, prefix)
  return str:find(prefix, 1, true) == 1
end

function utils.trim(str)
  return str:match("^%s*(.-)%s*$")
end

function utils.is_file_exists(file)
  local file = io.open(file, 'r')

  if file then
    file:close()
    return true
  end

  return false
end

function utils.is_directory_exists(path)
  if path:sub(-1, -1) ~= folder_separator then
    path = path .. folder_separator
  end

  return utils.is_file_exists(path .. folder_separator)
end

function utils.clear_folder(path)
  local is_windows = folder_separator == '\\'
  local path = path:gsub('/', folder_separator)

  if utils.is_directory_exists(path) then
    local command = is_windows and 'rmdir /s /q' or 'rm -r'
    os.execute(command .. ' "' .. path .. '"')
  end

  os.execute('mkdir ' .. path)
end

function utils.save_file(content, path)
  local file = io.open(path, 'w')

  if file == nil then
    assert(file, 'Have you prepared map components folders? Can\'t save a file at path: ' .. path .. '.')
    return false
  end

  file:write(content)
  file:close()

  return true
end

function utils.read_file(path)
  local file = io.open(path, 'r')
  assert(file, 'File doesn\'t exist: ' .. path)

  local content = file:read('*a')
  file:close()

  return content
end

function utils.get_lines(content)
  local lines = {}

  for line in content:gmatch '[^\r\n]+' do
    table.insert(lines, line)
  end

  return lines
end

return utils
