""" Scafolding of a git blame plugin
let g:strobe=1
let s:temp="/tmp/tmp"
let s:current_line = -1
let s:inspected_file = expand('%:p')

let s:target_refresh_time = 300

let s:old_update = &updatetime

if str2nr(s:old_update) > s:target_refresh_time
    exec "set updatetime=" . s:target_refresh_time
endif

function Make_and_open_tempfile()
    let s:temp = tempname()
    let l:make_file = "silent! exec '! touch " . s:temp
    silent! exec l:make_file
    let l:open_file = "split!|view! " . s:temp
    silent! exec l:open_file
    call Write_file(s:temp, "log.txt")
    call CycleAndSet()
    call CycleAndSet()
endfunction

function Clean_tempfile()
    wincmd o
    call delete(s:temp)
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
        let l:log = system("git log " . l:commit . "~1.." . l:commit)
    endif
    call Write_file(l:log, "log.txt")
    return l:log
endfunction

function Ref()
    call writefile(split(Get_current_line_log(), "\n", 1), s:temp, 'b')
    wincmd t
    silent edit!
    wincmd b
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
    if g:strobe == 1
        exec l:cmd
    endif
    call Process()
endfunction

