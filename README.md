# Vim Blaming

A plugin to show the output of `git log` for the commit that made the current line.

![alt text](https://github.com/Arkaeriit/vim-blaming/blob/master/vim-blaming.gif?raw=true)

## Usage

The plugin exposes 3 commands.

* `BlamingStart`: Start the plugin and open the log window.
* `BlamingStop`: Stop the plugin and close the log window.
* `BlamingToggle`: If the plugin is not started, start it; otherwise, stop it.

## Notes

The plugin is still a tag rough around the edges, it could use a wee bit of polish.

The most convenient way to use vim-blaming is to map some keybindings to the `BlamingToggle` command. 
You can do so by adding the following line in your `vimrc`.

```vimscript
nnoremap <leader>gb :BlamingToggle<Cr>
```

