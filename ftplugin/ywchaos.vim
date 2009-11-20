" mY oWn Chaos taking.
" Author: Wu, Yue <vanopen@gmail.com>
" License: BSD

" Make @ as keyword.
" setlocal iskeyword+=@-@
setlocal fdm=expr
setlocal foldexpr=Ywchaos_FoldExpr(v:lnum)
setlocal foldtext=getline(v:foldstart)

setlocal completefunc=Ywchaos_CompleteTags

silent! call Ywchaos_MakeTagsline()

nmap <silent> <buffer> <C-]> :call Ywchaos_VimgrepTag()<CR>
nmap <silent> <buffer> <Tab> :call Ywchaos_Tab('n')<CR>
nmap <silent> <buffer> <Leader>n :call Ywchaos_NewItem()<CR>
nmap <silent> <buffer> <Leader><C-l> :call Ywchaos_MakeTagsline(1)<CR>
nmap <silent> <buffer> <Leader>i :call Ywchaos_InsertSnip()<CR>

imap <silent> <expr> <buffer> <Tab> Ywchaos_Tab('i')
