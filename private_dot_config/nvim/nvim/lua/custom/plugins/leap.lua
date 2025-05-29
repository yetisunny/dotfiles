return {
  'ggandor/leap.nvim',
  setup = function()
    require('leap').setup {}

    -- Deprecated option. Try it without this setting first, you might find
    -- you don't even miss it.
    require('leap').opts.highlight_unlabeled_phase_one_targets = true
    require('leap').opts.safe_labels = {}
    require('leap').opts.preview_filter = function()
      return false
    end

    vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' }) -- or some grey
    vim.api.nvim_set_hl(0, 'LeapMatch', {
      -- For light themes, set to 'black' or similar.
      fg = 'white',
      bold = true,
      nocombine = true,
    })
  end,
}
