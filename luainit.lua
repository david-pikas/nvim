-- LSP stuff
local nvim_lsp = require('lspconfig')
local lsp_util = require('lspconfig.util')
local langs = {
  hls = {},
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        procMacro = { enable = false }
      }
    }
  },
  clangd = {},
  texlab = {
    settings = {
      args = {"-pdf", "--shell-escape"}
    }
  },
  erlangls = {},
  eslint = {},
  pylsp = {},
  solargraph = { root_dir = lsp_util.root_pattern("Gemfile", ".git", ".svn", ".solargraph.yml") },
  -- ruby_ls = { root_dir = lsp_util.root_pattern("Gemfile", ".git", ".svn") },
  cmake = {},
}

-- debugger stuff
local dap = require('dap')

dap.adapters = {
  cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = vim.g.cppdbg_command,
    options = {
      detached = false
    },
  },
  cspy = {
    id = 'cspy',
    type = 'executable',
    command = (vim.g.iarew_target or '') .. '/common/bin/cspybat.exe',
  }
}

dap.configurations.c = {
  {
    name = 'Launch',
    type = 'cppdbg',
    request = 'launch',
    program = function()
      if vim.g.cppdbg_program_exe then
        vim.g.cppdbg_program_exe = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end
      return vim.g.cppdbg_program_exe
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
    MIMode = 'lldb',
  },
  {
    name = 'Launch',
    type = 'cspy',
    request = 'launch',
    program =  function()
      if vim.g.cspy_program_exe then
        vim.g.cspy_program_exe = vim.fn.input('Path to IAR target: ', vim.fn.getcwd() .. '/', 'file')
      end
      return vim.g.cspy_program_exe
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = vim.g.cspy_program_args
  }
}
dap.configurations.cpp = dap.configurations.c

vim.g.dap_configs = dap.configurations

local custom_attach = function(client, bufnr_)
bufnr = 0
local function map(mode, key, value)
  vim.keymap.set(mode,key,value,{noremap = true, silent = true, buffer = bufnr})
end
local function nmap(key, value) map('n', key, value) end
local function set_option(opt, val)
  vim.api.nvim_buf_set_option(bufnr_, opt, val)
end
set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
nmap('gd', vim.lsp.buf.definition)
nmap('gd', vim.lsp.buf.definition)
nmap('gd', vim.lsp.buf.definition)
nmap('gd', vim.lsp.buf.definition)
nmap('gd', vim.lsp.buf.definition)
nmap('gd', vim.lsp.buf.definition)
nmap('gD', vim.lsp.buf.type_definition)
nmap('gr', vim.lsp.buf.references)
nmap('gR', vim.lsp.buf.rename)
map('v', 'K', vim.lsp.buf.hover)
nmap('K',  vim.lsp.buf.hover)
nmap('ga', vim.lsp.buf.code_action)
nmap('=f', vim.lsp.buf.format)
nmap('].', vim.diagnostic.goto_next)
nmap('[.', vim.diagnostic.goto_prev)
nmap('<leader>i', function () vim.diagnostic.open_float(0, { scope = "line", padding="single" }) end)
nmap('<leader>d', vim.lsp.buf.code_action)
nmap('<leader>q', vim.diagnostic.setqflist)
end

for lang,opts in pairs(langs) do
nvim_lsp[lang].setup(opts)
nvim_lsp[lang].setup { on_attach = custom_attach }
end

-- tree sitter stuff
require'nvim-treesitter.configs'.setup {
ensure_installed = {
  "c",
  "cpp",
  "elixir",
  "haskell",
  "javascript",
  "json",
  "latex",
  "lua",
  "perl",
  "python",
  "regex",
  "ruby",
  "rust",
  "tsx",
  "typescript",
  "query",
},
highlight = { enable = true },
incremental_selection = {
  enable = true,
  keymaps = {
    init_selection = "<M-s>",
    node_incremental = "<M-s>",
    scope_incremental = "<M-a>",
    node_decremental = "<M-d>",
  },
},
indent = {
   enable = true,
   disable = { "c", "cpp" }
},
textobjects = {
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
    },
    selection_modes = {
      ['@function.outer'] = 'V',
      ['@class.outer'] = 'V',
    },
    include_surrounding_whitespace = true,
  },
  move = {
    enable = true,
    set_jumps = true,
    goto_next_start = {
      ["]]"] = "@function.outer",
      ["]m"] = "@class.outer",
    },
    goto_next_end = {
      ["]["] = "@function.outer",
      ["]M"] = "@class.outer",
    },
    goto_previous_start = {
      ["[["] = "@function.outer",
      ["[m"] = "@class.outer",
    },
    goto_previous_end = {
      ["[]"] = "@function.outer",
      ["[M"] = "@class.outer",
    }
  },
  lsp_interop = {
    enable = true,
    peek_definition_code = {
      ["<leader>pf"] = "@function.outer",
      ["<leader>pc"] = "@class.outer",
      ["<leader>ps"] = "@statement.outer",
      ["<leader>pp"] = "@paramater.outer"
    }
  }
}
}

local function treesitter_do(querystr, line1, line2, callback)

  local mark_ns = vim.api.nvim_create_namespace('ts-ex')
  local lang_tree = vim.treesitter.get_parser(0)

  local query = vim.treesitter.parse_query(lang_tree:lang(), querystr)

  for _, tree in ipairs(lang_tree:trees()) do
    local emarks = {}
    local captures = {}
    for _, match, metadata in query:iter_matches(tree:root(), bufnr, line1, line2) do
      local ml1, mc1, ml2, mc2
      for id, node in pairs(match) do
        local name = query.captures[id]
        local l1, c1, l2, c2 = node:range()
        if name == "match" then
          ml1, mc1, ml2, mc2 = l1, c1, l2, c2
        end
        -- replace the @name with the text captured by the query in cmd
        captures[name] = {
          l1, c1, l2, c2
        }
      end
      if ml1 ~= nil then
        local emark1 = vim.api.nvim_buf_set_extmark(0, mark_ns, ml1, mc1, {})
        local emark2 = vim.api.nvim_buf_set_extmark(0, mark_ns, ml2, mc2, {})
        table.insert(emarks, {emark1, emark2})
      end
    end
    for _,emarks in pairs(emarks) do
      local emark1, emark2 = unpack(emarks)
      -- i f the marks are equal that means that the region between them has been deleted
      local el1, ec1 = unpack(vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, emark1, {}))
      local el2, ec2 = unpack(vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, emark2, {}))
      if el1 ~= el2 or ec1 ~= ec2 then
        callback(captures, mark_ns, emark1, emark2)
      end
    end
  end
end

local function sub_captures(s, captures)
  for name, range in pairs(captures) do
    local l1, c1, l2, c2 = unpack(range)
    local lines = vim.fn.getline(l1+1, l2+1)
    lines[1] = string.sub(lines[1], c1+1)
    lines[#lines] = string.sub(lines[#lines], 0, c2)
    if string.find(s, "@"..name.."%f[%A]") then
        s = string.gsub(s, "@"..name.."%f[%A]", table.concat(lines, "\n"))
    end
  end
  return s
end

-- perform ex commands on results of treesitter queries
local function treesitter_ex(args)
  local _, _, querystr, cmd = string.find(args.args, "([^/]+)/(.*)")
  if not string.find(querystr, "@match%f[%A]") then
      querystr = querystr.." @match"
  end
  treesitter_do(querystr, args.line1, args.line2,
    function(captures, mark_ns, emark1, emark2)
      local localcmd = sub_captures(cmd, captures)
      vim.fn.ExtmarkSplitEx(mark_ns, emark1, emark2, localcmd)
    end
  )
end

local function treesitter_sub(args)
  local _, _, querystr, sub = string.find(args.args, "([^/]+)/(.*)")
  if not string.find(querystr, "@match%f[%A]") then
      querystr = querystr.." @match"
  end
  treesitter_do(querystr, args.line1, args.line2,
    function(captures, mark_ns, emark1, emark2)
      local localsub = sub_captures(sub, captures)
      -- lua doesn't have a split function
      local sublines = vim.fn.split(localsub, "\n")
      local el1, ec1 = unpack(vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, emark1, {}))
      local el2, ec2 = unpack(vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, emark2, {}))
      local prefix = string.sub(vim.fn.getline(el1+1), 0, ec1)
      local postfix = string.sub(vim.fn.getline(el2+1), ec2+1)
      if el2 ~= el1 then
        deletebufline(0, el1+2, el2+1)
      end
      if #sublines == 1 then
        vim.fn.setline(el1+1, prefix..localsub..postfix)
      else
        vim.fn.setline(el1+1, prefix..sublines[1])
        table.remove(sublines, 1)
        sublines[#sublines] = sublines[#sublines]..suffix
        vim.fn.append(el1+1, sublines)
      end
    end
  )
end

local function treesitter_grep(args)
  local fullstr = args.args;
  local regex
  local regex_start, regex_end = string.find(fullstr, "/.*[^\\]/")
  if regex_start and regex_end then
    regex = string.sub(fullstr, regex_start+1, regex_end-1)
    fullstr = string.sub(fullstr, 0, regex_start-1) .. string.sub(fullstr, regex_end+1)
  end
  local querystr
  local querystr_start, querystr_end = string.find(fullstr, "%b()[@%w%d]*")
  if querystr_start and querystr_end then
    querystr = string.sub(fullstr, querystr_start, querystr_end)
    fullstr = string.sub(fullstr, 0, querystr_start-1) .. string.sub(fullstr, querystr_end+1)
  else
    error "Failure parsing treesitter grep: Couldn't find treesitteer query"
  end
  if not string.find(querystr, "@match%f[%A]") then
      querystr = querystr.." @match"
  end
  local matches = {};
  treesitter_do(querystr, args.line1, args.line2,
    function(captures, mark_ns, emark1, emark2)
      local el1, ec1 = unpack(vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, emark1, {}))
      local el2, ec2 = unpack(vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, emark2, {}))
      local lines = vim.fn.getline(el1+1, el2+1)
      lines[1] = string.sub(lines[1], ec1)
      lines[#lines] = string.sub(lines[#lines], 0, ec2+1)
      local text = vim.fn.join(lines, "\n")
      if not regex or vim.fn.match(text, regex) > -1 then
        table.insert(matches, {
            filename = vim.fn.expand('%'),
            lnum = el1+1,
            end_lnum = el2+1,
            col = ec1,
            end_col = ec2,
            text = text,
        })
      end
    end
  )
  vim.fn.setqflist(matches)
  vim.cmd("copen")
end

vim.api.nvim_create_user_command("TSGlobal", treesitter_ex,  { range='%', nargs=1 })
vim.api.nvim_create_user_command("TSG", treesitter_ex,  { range='%', nargs=1 })
vim.api.nvim_create_user_command("TSSubstitute", treesitter_sub, { range='%', nargs=1 })
vim.api.nvim_create_user_command("TSGrep", treesitter_grep, { range='%', nargs=1 })

-- preview code lsp actions
local actions_preview = require('actions-preview')
actions_preview.setup {
  backend = { 'telescope', 'nui' },
  telescope = require('telescope.themes').get_dropdown { winblend = 10 },
}
vim.api.nvim_create_user_command(
  'ActionsPreview', function() actions_preview.code_actions() end, { range='%', nargs=0 }
)

-- refactoring stuff
-- currently out commented because we want to lazily load this plugin. not sure if calling setup is needed
-- require('refactoring').setup({})

-- telescope stuff
telescope = require('telescope')
tele_actions = require('telescope.actions')
telescope.setup({
defaults = {
  history = {

  },
  mappings = {
    i = {
      ["<C-Down>"] = tele_actions.cycle_history_next,
      ["<C-Up>"] = tele_actions.cycle_history_prev,
    },
  },
},
extensions = {
  live_grep_args = {
    auto_quoting = true
  }
}
})
telescope.load_extension('fzf')
telescope.load_extension('ultisnips')
telescope.load_extension('hoogle')
telescope.load_extension('harpoon')
