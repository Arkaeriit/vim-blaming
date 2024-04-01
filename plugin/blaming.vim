""" Scafolding of a git blame plugin
let s:running=0
let s:temp="/tmp/tmp"
let s:current_line = -1

let s:target_refresh_time = 300

let s:old_update = &updatetime

if str2nr(s:old_update) > s:target_refresh_time
    exec "set updatetime=" . s:target_refresh_time
endif

" This function start's the plugin, running it is the entry point.
" It's sets the plugin's state and display.
function Start_vim_blaming()
    if s:running == 1
        echom "Error, vim-blaming is already running"
        return
    endif
    " Set plugin's state
    let s:inspected_file = expand('%:p')
    let s:temp = tempname()
    let s:running = 1
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
function Stop_vim_blaming()
    if s:running == 0
        echom "Error, vim-blaming is not running"
        return
    endif
    wincmd t
    quit
    wincmd p
    call Clean_state()
endfunction

" Cleanup the plugin's state, should be ran after stopping the display.
function Clean_state()
    call delete(s:temp)
    let s:running = 0
    let l:cmd = 'autocmd! BufWinLeave ' . s:temp
    exec l:cmd
endfunction

function Get_line()
    let l:pos = getcurpos()
    return l:pos[1]
endfunction

function Write_file(txt, file)
    call writefile(split(a:txt, "\n", 1), a:file, 'a')
endfunction

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

function Ref()
    call writefile(split(Get_current_line_log(), "\n", 1), s:temp, 'b')
    wincmd t
    silent edit!
    wincmd p
    redraw!
endfunction

function Process()
    if s:current_line != Get_line()
        let s:current_line = Get_line()
        call Ref()
    endif
endfunction

function CycleAndSet()
    let l:cmd = 'autocmd CursorHold ' . s:inspected_file . ' ++once call CycleAndSet()'
    if s:running == 1
        exec l:cmd
        call Process()
    endif
endfunction

