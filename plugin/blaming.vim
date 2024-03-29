""" Scafolding of a git blame plugin
let g:strobe=1
let s:temp="/tmp/tmp"
let s:current_line = -1

let s:target_refresh_time = 300

let s:old_update = &updatetime

if str2nr(s:old_update) > s:target_refresh_time
    exec "set updatetime=" . s:target_refresh_time
endif

function Make_and_open_tempfile()
    let g:temp = tempname()
    let l:make_file = "silent! exec '! touch " . g:temp
    silent! exec l:make_file
    let l:open_file = "split!|view! " . g:temp
    silent! exec l:open_file
    call CycleAndSet()
    call CycleAndSet()
endfunction

function Clean_tempfile()
    wincmd o
    call delete(g:temp)
endfunction

function Get_line()
    let l:pos = getcurpos()
    return l:pos[1]
endfunction

function Ref()
    let l:make_file = "silent! exec '! echo " . Get_line() . " > " . g:temp . "'"
    silent! exec l:make_file
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
    let l:path = expand('%:p')
    let l:cmd = 'autocmd CursorHold ' . l:path . ' ++once call CycleAndSet()'
    if g:strobe == 1
        exec l:cmd
    endif
    call Process()
endfunction

