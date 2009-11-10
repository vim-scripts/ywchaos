" mY oWn Chaos taking.
" Author: Wu, Yue <vanopen@gmail.com>
" Last Change:	2009 Oct 09
" License: BSD

" Make @ as keyword.
setlocal iskeyword+=@-@

setlocal fdm=expr
setlocal foldexpr=Ywchaos_FoldExpr(v:lnum)
setlocal foldtext=getline(v:foldstart)

silent! call Ywchaos_MakeTagsline()

nmap <silent> <buffer> <C-]> :call Ywchaos_FindTag()<CR>
nmap <silent> <buffer> <Tab> :call Ywchaos_Tab()<CR>
nmap <silent> <buffer> <Leader>n :call Ywchaos_NewItem()<CR>
nmap <silent> <buffer> <Leader><C-l> :call Ywchaos_MakeTagsline()<CR>
nmap <silent> <buffer> <Leader>i :call Ywchaos_InsertSnip()<CR>
