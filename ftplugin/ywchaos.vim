" Make @ as keyword.
setlocal iskeyword+=@-@

setlocal fdm=expr
setlocal foldexpr=Ywchaos_FoldExpr(v:lnum)
setlocal foldtext=getline(v:foldstart)

silent call Ywchaos_MakeTagsline()

nmap <silent> <buffer> <C-]> :call Ywchaos_FindTag()<CR>

nmap <silent> <buffer> <Tab> :call Ywchaos_Tab()<CR>
nmap <silent> <buffer> <Leader>n :call Ywchaos_NewItem()<CR>
