local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local themes = require("telescope.themes")

local M = {}

local function execute_command(bufnr)
  local selection = action_state.get_selected_entry(bufnr)
  actions.close(bufnr)
  local cmd = selection.command
  if cmd then
    local success, msg = pcall(cmd)
    if not success then
      vim.api.nvim_notify(msg, 2, {})
    end
  end
end

local function command_entry_maker(max_width)
  local make_display = function(en)
    local displayer = entry_display.create({
      separator = " - ",
      items = {
        { width = max_width },
        { remaining = true },
      },
    })

    return displayer({
      { en.label, "Type" },
      { en.hint, "Comment" },
    })
  end
  return function(entry)
    return {
      ordinal = entry.id,
      command = entry.command,
      hint = entry.hint,
      label = entry.label,
      display = make_display,
    }
  end
end

local function get_max_length(commands)
  local max = 0
  for _, value in ipairs(commands) do
    max = #value.label > max and #value.label or max
  end
  return max
end

function M.commands(opts)
  local commands = {
    {
      id = "flutter-tools-run",
      label = "Flutter tools: Run",
      hint = "Start a flutter project",
      command = require("flutter-tools.commands").run,
    },
    {
      id = "flutter-tools-hot-reload",
      label = "Flutter tools: Hot reload",
      hint = "Reload a running flutter project",
      command = require("flutter-tools.commands").reload,
    },
    {
      id = "flutter-tools-hot-restart",
      label = "Flutter tools: Hot restart",
      hint = "Restart a running flutter project",
      command = require("flutter-tools.commands").restart,
    },
    {
      id = "flutter-tools-quit",
      label = "Flutter tools: Quit",
      hint = "Quit running flutter project",
      command = require("flutter-tools.commands").quit,
    },
    {
      id = "flutter-tools-visual-debug",
      label = "Flutter tools: Visual Debug",
      hint = "Add the visual debugging overlay",
      command = require("flutter-tools.commands").visual_debug,
    },
    {
      id = "flutter-tools-list-devices",
      label = "Flutter tools: List Devices",
      hint = "Show the available physical devices",
      command = require("flutter-tools.devices").list_devices,
    },
    {
      id = "flutter-tools-list-emulators",
      label = "Flutter tools: List Emulators",
      hint = "Show the available emulator devices",
      command = require("flutter-tools.devices").list_emulators,
    },
    {
      id = "flutter-tools-open-outline",
      label = "Flutter tools: Open Outline",
      hint = "Show the current files widget tree",
      command = require("flutter-tools.outline").open,
    },
    {
      id = "flutter-tools-start-dev-tools",
      label = "Flutter tools: Start Dev Tools",
      hint = "Open flutter dev tools in the browser",
      command = require("flutter-tools.dev_tools").start,
    },
    {
      id = "flutter-tools-copy-profiler-url",
      label = "Flutter tools: Copy Profiler Url",
      hint = "Run the app and the DevTools first",
      command = require("flutter-tools.commands").copy_profiler_url,
    },

    {
      id = "flutter-tools-clear-dev-log",
      label = "Flutter tools: Clear Dev Log",
      hint = "Clear previous logs in the output buffer",
      command = require("flutter-tools.log").clear,
    },
  }

  opts = opts and not vim.tbl_isempty(opts) and opts or themes.get_dropdown({
    previewer = false,
    results_height = #commands,
  })

  pickers.new(opts, {
    prompt_title = "Flutter tools commands",
    finder = finders.new_table({
      results = commands,
      entry_maker = command_entry_maker(get_max_length(commands)),
    }),
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(_, map)
      map("i", "<CR>", execute_command)

      -- If the return value of `attach_mappings` is true, then the other
      -- default mappings are still applies.
      -- Return false if you don't want any other mappings applied.
      -- A return value _must_ be returned. It is an error to not return anything.
      return true
    end,
  }):find()
end

return M
