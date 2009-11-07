" Make @ as keyword.
setlocal iskeyword+=@-@

setlocal fdm=expr
setlocal foldexpr=Ywchaos_FoldExpr(v:lnum)
setlocal foldtext=getline(v:foldstart)

let tagsline = getline(1)
if match(tagsline, '^TAGS: ') != -1
    let b:tagslst = split(tagsline)[1:]
else
    call Ywchaos_MakeTagsline()
endif
execute 'syntax match ywchaoskwd /\('.escape(join(b:tagslst, '\|'), '/').'\)/'
hi def link ywchaoskwd Statement

nmap <silent> <buffer> <C-]> :call Ywchaos_FindTag()<CR>

nmap <silent> <buffer> <Tab> :call Ywchaos_Tab()<CR>
nmap <silent> <buffer> <Leader>n :call Ywchaos_NewItem()<CR>
