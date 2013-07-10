
let s:activeRegister = easyclip#GetDefaultReg()
let s:moveCursor = 0

function! s:OnPreSubstitute(register, moveCursor)
  let s:activeRegister = a:register

  " This is necessary to get around a bug in vim where the active register persists to
  " the next command. Repro by doing "_d and then a command that uses v:register
  if a:register == "_"
    let s:activeRegister = subbed#GetDefaultReg()
  endif

  let s:moveCursor = a:moveCursor
endfunction

function! s:SubstituteMotion(type, ...)

  let startPos = getpos('.')

  if a:type ==# 'line'
    exe "normal! '[V']"
  elseif a:type ==# 'char'
    exe "normal! `[v`]"
  else
    echom "Unexpected selection type"
    return
  endif

  let reg = s:activeRegister

  if (getreg(reg) =~# "\n")
    " For some reason using "c" change doesn't work correctly for multiline,
    " Adds an extra line at the end
    exe "normal! \"_d"

    exec "normal! \"".reg."P"
  else
    " No ! since we want to hook into our custom paste
    exe "normal! \"_c\<c-r>". reg
  endif

  if !s:moveCursor
    call setpos('.', startPos)
  end
endfunction

" For some reason I couldn't get this to work without defining it as a function
function! s:SubstituteLine(reg, keepNewLine)
  let isOnLastLine = (line(".") == line("$"))

  if a:keepNewLine
    exec "normal! 0\"_d$"
  else
    exe "normal! \"_dd"
  endif

  exec "normal! \"".a:reg.(isOnLastLine ? "p" : "P")
endfunction

function! s:SubstituteToEndOfLine(reg, moveCursor)
  let startPos = getpos('.')
  exec "normal! \"_d$"

  exe "normal! \"".a:reg."p"

  if !a:moveCursor
    call setpos('.', startPos)
  endif
endfunction

nnoremap <plug>SubstituteOverMotionMap :<c-u>call <sid>OnPreSubstitute(v:register, 1)<cr>:set opfunc=<sid>SubstituteMotion<cr>g@
nnoremap <plug>G_SubstituteOverMotionMap :<c-u>call <sid>OnPreSubstitute(v:register, 0)<cr>:set opfunc=<sid>SubstituteMotion<cr>g@

nnoremap <plug>SubstituteToEndOfLine :call <sid>SubstituteToEndOfLine(v:register, 1)<cr>:call repeat#set("\<plug>SubstituteToEndOfLine")<cr>
nnoremap <plug>G_SubstituteToEndOfLine :call <sid>SubstituteToEndOfLine(v:register, 0)<cr>:call repeat#set("\<plug>G_SubstituteToEndOfLine")<cr>

nnoremap <plug>NoNewlineSubstituteLine :call <sid>SubstituteLine(v:register, 1)<cr>
nnoremap <plug>SubstituteLine :call <sid>SubstituteLine(v:register, 0)<cr>

if !exists('g:SubbedBlackholeXandC') || g:SubbedBlackholeXandC
  noremap x "_x
  xnoremap x "_x

  nnoremap c "_c
  xnoremap c "_c

  " This is more consistent with yy and dd
  nnoremap cc "_S
  nnoremap cC "_S

  nnoremap C "_C
  xnoremap C "_C
endif

if !exists('g:SubbedInstallBindings') || g:SubbedInstallBindings

  let subKey = get(g:, 'SubbedSubstituteKey', '-')
  let subKeyLine = get(g:, 'SubbedSubstituteKeyLine', '_')
  let doubleSubKey = subKey . subKey
  let subKeyAndLine = subKey . subKeyLine

  execute "nmap <silent>" subKey "<Plug>SubstituteOverMotionMap"
  execute "nmap <silent>" subKeyLine "<Plug>SubstituteToEndOfLine"
  execute "nmap" doubleSubKey "<Plug>SubstituteLine"
  execute "nmap" subKeyAndLine "<Plug>NoNewlineSubstituteLine"

  execute "xmap" subKey "p"

endif


