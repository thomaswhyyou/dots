-- https://github.com/b0o/incline.nvim
return {
  "b0o/incline.nvim",
  config = function()
    -- Experiment: render the `term [i/N]` search badge in incline's float
    -- instead of as virtual text (see `lua/searchcount_incline.lua`).
    local searchcount = require("searchcount_incline")
    searchcount.setup()

    require("incline").setup({
      render = function(props)
        local name = vim.api.nvim_buf_get_name(props.buf)
        local filename = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")

        local res = { filename }

        -- Only the focused window owns the search state; computing the badge
        -- there avoids drawing it on every split.
        if props.focused then
          local badge = searchcount.render_badge()
          if badge then
            vim.list_extend(res, badge)
          end
        end

        return res
      end,
    })
  end,
}
