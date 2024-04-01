""" Scafolding of a git blame plugin
let s:running=0
let s:current_line = -1
let s:target_refresh_time = 300


" This function start's the plugin, running it is the entry point.
" It's sets the plugin's state and display.
function blaming#Start_vim_blaming()
    " Ensure that we can run the plugin.
    if s:running == 1
        echom "Error, vim-blaming is already running"
        return
    endif
    " Set plugin's state
    let s:inspected_file = expand('%:p')
    let s:temp = tempname()
    let s:running = 1
    let s:old_update = &updatetime
    if str2nr(s:old_update) > s:target_refresh_time
        exec "set updatetime=" . s:target_refresh_time
    endif
    " Create plugin's temp file
    let l:make_file = "silent! exec '! touch " . s:temp
    silent! exec l:make_file
    wincmd t
    " Open plugin's temp file on new split
    let l:open_file = "split!|view! " . s:temp
    silent! exec l:open_file
    wincmd p " TODO: jump back to previous window
    call Write_file(s:temp, "log.txt")
    " Create autocomand to stop the plugin if we close the plugin's window
    let l:cmd = 'autocmd BufWinLeave ' . s:temp . ' ++once let s:running = 0'
    exec l:cmd
    " Run the refresh command to prepare the normal use of the plugin
    call CycleAndSet()
    call CycleAndSet()
endfunction

" Stop the plugin if it is already running and close the display.
function blaming#Stop_vim_blaming()
    if s:running == 0
        echom "Error, vim-blaming is not running"
        return
    endif
    wincmd t
    quit
    wincmd p
    call Clean_state()
endfunction

" Toggle the state of the plugin
function blaming#Toggle_vim_blaming()
    if s:running
        call blaming#Stop_vim_blaming()
    else
        call blaming#Start_vim_blaming()
    endif
endfunction

" Cleanup the plugin's state, should be ran after stopping the display.
function Clean_state()
    call delete(s:temp)
    let s:running = 0
    let l:cmd = 'autocmd! BufWinLeave ' . s:temp
    exec l:cmd
    exec "set updatetime=" . s:old_update
endfunction

" Return the current line the cursor is on.
function Get_line()
    let l:pos = getcurpos()
    return l:pos[1]
endfunction

" DEBUG
function Write_file(txt, file)
    call writefile(split(a:txt, "\n", 1), a:file, 'a')
endfunction

" Return as a string containing the output of git log for the current line.
function Get_current_line_log()
    let l:commit_get_command = "git blame " . s:inspected_file . " | head -n " . Get_line() . " | tail -n 1 | cut -d ' ' -f 1"
    call Write_file(l:commit_get_command, "log.txt")
    let l:commit = system(l:commit_get_command)
    call Write_file(l:commit, "log.txt")
    let l:commit = l:commit[:-2]
    if l:commit == "000000000000"
        let l:log = "Not commited yet."
    else
        let l:log = system("git log " . l:commit . " -n 1")
    endif
    call Write_file(l:log, "log.txt")
    return l:log
endfunction

" Reload the plugin with a fresh log content.
function Refresh()
    if &modified == 1
        let l:displayed_text = "The vim-blaming plugin might not work if the changes on the file are not saved."
    else
        let l:displayed_text = Get_current_line_log()
    endif
    call writefile(split(l:displayed_text, "\n", 1), s:temp, 'b')
    wincmd t
    silent edit!
    wincmd p
    redraw!
endfunction

" Refresh the plugin if we changed line.
function Process()
    if s:current_line != Get_line()
        let s:current_line = Get_line()
        call Refresh()
    endif
endfunction

" If the plugin is still running, refresh the display and reset the autocomand
" that call it again.
function CycleAndSet()
    let l:cmd = 'autocmd CursorHold,BufWritePost ' . s:inspected_file . ' ++once call CycleAndSet()'
    if s:running == 1
        exec l:cmd
        call Process()
    endif
endfunction

