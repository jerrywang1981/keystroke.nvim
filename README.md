# keystroke.nvim
Keystroke plugin for NeoVim

# Requirements

* Neovim 0.5+

# Installation

## packer

### Enable keystroke sound

* audio files was taken from [vim-keysound](https://github.com/skywind3000/vim-keysound)
* for now, auto_start is default to false, you need to enable it.

```lua
  packer.use({
    "jerrywang1981/keystroke.nvim",
    config = [[
      require"keystroke".setup({
        handlers = {
          -- insert mode
          ["i"] = {
            -- or a table with callback/options key
            -- it will call the function with key as first and options as second parameter
            -- callback(key, options)
            {
              callback = require"keystroke.sound".play_sound,
              options = {
                -- the sound style, valid value: default/bubble/mario/sword/typewriter
                style = "default",
              }
            },
          },
        }
      })
    ]]
  })

```
### Enable keyword message tip

```lua
  packer.use({
    "jerrywang1981/keystroke.nvim",
    config = [[
      require"keystroke".setup({
        handlers = {
          -- insert mode
          ["i"] = {
            -- this is an example or demo, when you input keyword
            -- jerry
            -- or 1958/06/30
            -- it will
            -- pop up messages
            require"keystroke.keyword".keyword_message,
          },
        }
      })
    ]]
  })
```

### Detail instruction
```lua
  packer.use({
    "jerrywang1981/keystroke.nvim",
    config = [[
      require"keystroke".setup({
        -- auto start/enable or not, if not, you need to :KeyStrokeEnable to get it work
        auto_start = true,
        -- handlers for different modes, function with one string parameter
        handlers = {
          -- insert mode
          ["i"] = {
            -- can be function
            require"keystroke.sound".play_sound,
            -- or a table with a key and callback/options/enable table as value
            -- it will call the function with key as first and options as second parameter
            -- callback(key, options)
            sound = {
              enable = true, -- enable handler or not
              callback = require"keystroke.sound".play_sound,
              options = {
                -- the sound style, valid value: default/bubble/mario/sword/typewriter
                style = "default",
              }
            },
            -- this is an example or demo, when you input keyword jerry or 1958/06/30 , it will
            -- pop up messages
            require"keystroke.keyword".keyword_message,
          },
          -- normal mode
          ["n"] = {
          },
          -- all modes
          ["*"] = {}
        }
      })
    ]]
  })
```
# Usage

## Enable plugin
```
:KeyStrokeEnable
```
## Disable plugin
```
:KeyStrokeDisable
```
## Toggle plugin
```
:KeyStrokeToggle
```
## You can also enable/disable/toggle one named handler

* it should be named handler

```
KeyStroke enable sound
```
```
KeyStroke disable sound
```
```
KeyStroke toggle sound
```


# Maintainers
[@jerrywang1981](https://github.com/jerrywang1981)

# Contributors
[![](https://github.com/jerrywang1981.png?size=50)](https://github.com/jerrywang1981)

# License
MIT License
