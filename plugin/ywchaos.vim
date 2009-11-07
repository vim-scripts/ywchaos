" vim: foldmethod=marker:
if exists("s:loaded_ywchaos")
    finish
endif
let s:loaded_ywhelp = 1

scriptencoding utf-8

function Ywchaos_MakeTagsline() "{{{
    let save_cursor = getpos(".")
    let tllst=[]
    let tnlst=[]
    g/@\S\+/call add(tllst, getline('.'))
    call setpos('.', save_cursor)
    for line in tllst
        for tagn in filter(split(line), 'v:val =~ "@\\S\\+"')
            let tag = tagn[1:]
            if index(tnlst, tag) == -1
                call add(tnlst, tag)
            endif
        endfor
    endfor
    let tagsline = 'TAGS: '.join(tnlst)
    let b:tagslst = tnlst
    execute 'syntax match ywchaoskwd /\('.escape(join(b:tagslst, '\|'), '/').'\)/'
    hi def link ywchaoskwd Statement
    if match(getline(1), '^TAGS: ') == 0
        call setline(1, tagsline)
    else
        call append(0, tagsline)
    endif
endfunction
"}}}

function Ywchaos_FindTag() "{{{
    execute 'lvimgrep /@' . input("context: ", expand("<cword>"), "customlist,Ywchaos_ListTags") . '/j %'
    lopen
endfunction
"}}}

function Ywchaos_ListTags(A,L,P) "{{{
    let comp = []
    if match(getline(1), '^TAGS: ') == -1
        call Ywchaos_MakeTagsline()
    endif
    for c in split(getline(1), '\s\+')[1:]
        if match(c, a:L) != -1
            call add(comp, c)
        endif
    endfor
    return comp
endfunction
"}}}

function Ywchaos_FoldExpr(l) "{{{
    let line=getline(a:l)
    let len = match(line, '^\d\{,2}/\d\{,2}/\d\{,4}')
    if len != -1
        return '>1'
    else
        return '='
    endif
endfunction
"}}}

function Ywchaos_NewItem() "{{{
    normal gg
    call search(strftime("%m/%d/%Y"), 'W')
    let lno = line(".")
    if lno != 1
        call append(lno, strftime("%H:%M")." ")
        let newlno = lno + 1
    else
        call search('^[0-9/]\+', 'W')
        let lno = line(".")-1
        if lno != 0
            call append(lno, [strftime("%m/%d/%Y"), strftime("%H:%M")." "])
            let newlno = lno + 2
        else
            let lno = line("$")
            call append(lno, [strftime("%m/%d/%Y"), strftime("%H:%M")." "])
            let newlno = lno + 2
        endif
    endif
    silent! execute 'normal '.newlno.'Gzo'
    startinsert!
endfunction
"}}}

function Ywchaos_Tab() "{{{
    if line(".") == 1
        let cwd=expand("<cword>")
        if cwd !~ '\s\+' || cwd !~ 'TAGS:'
            let save_cursor = getpos(".")
            normal zM
            execute 'g/@'.cwd.'/normal zo'
            call setpos('.', save_cursor)
        endif
    else
        normal za
    endif
endfunction
"}}}
