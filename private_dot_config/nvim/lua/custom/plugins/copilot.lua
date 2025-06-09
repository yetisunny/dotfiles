return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  enabled = false, -- Disable by default, enable manually if needed
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        yaml = false,
        latex = false,
        markdown = false,
        txt = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ['.'] = false,
      },
    }
  end,
}
