""" Scafolding of a git blame plugin
let g:strobe=1
let g:temp="/tmp/tmp"

function Make_and_open_tempfile()
    let g:temp = tempname()
    let l:make_file = "silent! exec '! touch " . g:temp
    silent! exec l:make_file
    let l:open_file = "split!|view! " . g:temp
    silent! exec l:open_file
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

function CycleAndSet()
    let l:path = expand('%:p')
    let l:cmd = 'autocmd CursorMovedI,CursorMoved ' . l:path . ' ++once call CycleAndSet()'
    if g:strobe == 1
        exec l:cmd
    endif
    call Ref()
endfunction

call Make_and_open_tempfile()
call CycleAndSet()
call CycleAndSet()

