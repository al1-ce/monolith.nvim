local vim         = vim
local uv          = vim.loop
local curl        = require("plenary.curl")
local json        = require("lib.json")
local utils       = require("after.codestats.utils")
local filetypes   = require("after.codestats.types")
-- Global variables
local async_utils = require("plenary.async_lib.util")
local a           = require("plenary.async_lib.async")

-- Originally YannickFricke/codestats.nvim

local await = a.await
local async = a.async

local galaxyline_available, galaxyline = pcall(require, 'galaxyline')

-- Local variables
local timer = nil

-- The last timestamp when the XP where sent to CodeStats
local last_timestamp = utils.unix_timestamp()

-- The semaphore which is used for "thread safety"
local semaphore = async_utils.Semaphore.new(1)

local opts = {
  token = nil,
  endpoint = "https://codestats.net",
  -- The interval in seconds which should be used to calculate the new timestamp when the XP should be sent
  interval = 60,

  -- internal things
  version = "0.0.1"
}

local function get_initial_xp_table()
  local result = {}

  setmetatable(result, {
    __index = function() return 0 end
  })

  return result
end

-- Contains all XP that have not yet been sent to CodeStats
local gained_xp = get_initial_xp_table()

local M = {}

local function isempty(s)
  return s == nil or s == ''
end

function M.setup(options)
  options = options or {}

  local merged_options = vim.tbl_extend('keep', options, {
    endpoint = "https://codestats.net",
    token = nil,
    interval = 60,
  })

  opts["token"] = merged_options["token"] or vim.env.CODESTATS_API_KEY or os.getenv("CODESTATS_API_KEY")
  opts["endpoint"] = merged_options["endpoint"]
  opts["interval"] = merged_options["interval"]

  assert(isempty(opts.token) == false, "The CodeStats API token cannot be nil or empty")

  vim.api.nvim_command("augroup CodeStats")
    vim.api.nvim_command("autocmd InsertCharPre,TextChanged * lua require('after.codestats.setup').insert_xp()")
    vim.api.nvim_command("autocmd VimLeavePre * lua require('after.codestats.setup').shutdown()")
  vim.api.nvim_command("augroup end")

  -- Instantiate the timer loop
  timer = uv.new_timer()

  -- Start the timer loop
  timer:start(1000, 1000, vim.schedule_wrap(function ()
    -- Check if the last_timestamp + interval is greater than the current unix timestamp
    if last_timestamp + opts.interval > utils.unix_timestamp() then
      return
    end

    a.run(async(function ()
      -- Send the XP to CodeStats
      M.send_pulses()

      -- Update the "last_timestamp" variable to the current unix timestamp
      last_timestamp = utils.unix_timestamp()
    end)())
  end))
end

function M.send_pulses()
  local xps = M.get_xps()

  if #xps == 0 then
    return
  end

  local plain_body = {
    ["coded_at"] = utils.get_date_string(),
    ["xps"] = xps
  }

  local body = json.encode(plain_body)
  local headers = {
    content_type = "application/json",
    ["X-API-Token"] = opts.token,
  }

  curl.post({
    url = opts.endpoint .. "/api/my/pulses",
    accept = "application/json",
    headers = headers,
    body = body,
    callback = function(response)
      if response.status == 201 then
        return
      end

      vim.notify("Could not send Code::Stats XP")
    end
  })
end

function M.insert_xp()
  local fileType = vim.bo.filetype

  if filetypes.is_filetype_ignored(fileType) then
    return
  end

  local language = filetypes.get_language(fileType)

  a.run(async(function()
    local permit = await(semaphore:acquire())

    gained_xp[language] = gained_xp[language] + 1

    permit.forget()
  end)())
end

---Shuts down the timer loop
function M.shutdown()
  async_utils.block_on(async(function ()
    -- Send the remaining XP to CodeStats
    M.send_pulses()
  end)())

  if timer ~= nil then
    timer:stop()
  end
end

function M.get_xp_count()
  local result = 0

  for _, value in pairs(gained_xp) do
    result = result + value
  end

  return result
end

---Sends the current XP to CodeStats
function M.get_xps()
  local permit = await(semaphore:acquire())
  local result = {}

  for language, xp in pairs(gained_xp) do
    table.insert(result, {
      language = language,
      xp = xp
    })
  end

  gained_xp = get_initial_xp_table()

  permit.forget()

  if galaxyline_available then
    galaxyline.load_galaxyline()
  end

  return result
end

return M
