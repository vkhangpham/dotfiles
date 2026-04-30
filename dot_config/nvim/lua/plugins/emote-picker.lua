return {
  {
    dir = vim.fn.expand("~/.config/nvim/local-plugins/emote-picker"),
    name = "emote-picker",
    dependencies = { "3rd/image.nvim" },
    keys = {
      {
        "<localleader>Ea",
        function()
          require("emote_picker").open()
        end,
        desc = "Emotes: add emote",
      },
      {
        "<localleader>Ec",
        function()
          require("emote_picker").convert_buffer()
        end,
        desc = "Emotes: convert :emote: tokens",
      },
      {
        "<localleader>Es",
        function()
          require("emote_picker").setup_prompt()
        end,
        desc = "Emotes: setup",
      },
    },
    opts = {
      emote_dir = "assets/emotes",
      insert = {
        style = "html",
        class = "inline-emote",
        use_intrinsic_size = true,
        width = 32,
        height = 32,
        leading_slash = true,
      },
      commands = {
        enabled = true,
        add = "EmotesAdd",
        convert = "EmotesConvert",
        setup = "EmotesSetup",
        open = "Emotes",
        compat_open = "EmotePicker",
      },
      preview = {
        enabled = true,
        engine = "auto",
      },
      search = {
        enabled = true,
        prompt_prefix = "Search: ",
        title_prefix = " Emotes ",
        empty_message = "No emotes match the current search",
      },
    },
    config = function(_, opts)
      require("emote_picker").setup(opts)
    end,
  },
}
