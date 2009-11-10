" vim: foldmethod=marker:
" mY oWn Chaos taking.
" Author: Wu, Yue <vanopen@gmail.com>
" Last Change:	2009 Oct 09
" License: BSD

if exists("s:loaded_ywchaos")
    finish
endif
let s:loaded_ywchaos = 1

scriptencoding utf-8

let s:datefmt = "%m/%d/%Y"
let s:timefmt = "%H:%M:%S"

function Ywchaos_MakeTagsline() "{{{ Reflesh the TAGSLINE
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
    let oldtagsline = getline(1)
    let b:tagslst = tnlst
    execute 'syntax match ywchaoskwd /\('.escape(join(b:tagslst, '\|'), '/').'\)/'
    hi def link ywchaoskwd Statement
    if tagsline != oldtagsline
        if match(getline(1), '^TAGS:\s\+\S') == 0
            call setline(1, tagsline)
        else
            call append(0, tagsline)
        endif
    endif
endfunction "}}}

function Ywchaos_FindTag() "{{{ Using vimgrep to find the tag
    execute 'lvimgrep /@' . input("context: ", expand("<cword>"), "customlist,Ywchaos_ListTags") . '/j %'
    lopen
endfunction "}}}

function Ywchaos_FoldExpr(l) "{{{ Folding rule.
    let line=getline(a:l)
    let dateln = match(line, '^\d\{,2}/\d\{,2}/\d\{,4}')
    let timeln = match(line, '^\d\{2}:\d\{2}:\d\{2}')
    if dateln != -1
        return '>1'
    elseif timeln != -1
        return '>2'
    else
        return '='
    endif
endfunction "}}}

function Ywchaos_NewItem() "{{{ Create new entry.
    normal gg
    call search(strftime(s:datefmt), 'W')
    let lno = line(".")
    if lno != 1
        call append(lno, strftime(s:timefmt)." ")
        let newlno = lno + 1
    else
        call search('^[0-9/]\+', 'W')
        let lno = line(".")-1
        if lno != 0
            call append(lno, [strftime(s:datefmt), strftime(s:timefmt)." "])
            let newlno = lno + 2
        else
            let lno = line("$")
            call append(lno, [strftime(s:datefmt), strftime(s:timefmt)." "])
            let newlno = lno + 2
        endif
    endif
    silent! execute 'normal '.newlno.'Gzo'
    startinsert!
endfunction "}}}

function Ywchaos_Tab() "{{{ <Tab> key map.
    if line(".") == 1
        let col = col(".") - 1
        if col <= 5 || ( col > 5 && getline(".")[col] == ' ')
            normal W
        endif
        let cwd=expand("<cword>")
        if cwd !~ '\s\+' || cwd !~ 'TAGS:'
            let save_cursor = getpos(".")
            normal zM
            execute 'g/@'.cwd.'/normal zv'
            call setpos('.', save_cursor)
        endif
    else
        silent! normal za
    endif
endfunction "}}}

function Ywchaos_SynSnip(ftsnip,...) "{{{
    if !exists('b:ywchaos_syntax_'.a:ftsnip)
        let begin = '^\s*<BEGINSNIP=' . a:ftsnip . '>'
        let end = '^\s*<ENDSNIP=' . a:ftsnip . '>'
        if exists("a:1")
            let begin = a:1
        endif
        if exists("a:2")
            let end = a:2
        endif
        if exists("b:current_syntax")
            let oldcurrent_syntax = b:current_syntax
            unlet b:current_syntax
        endif
        execute 'syntax include @ywchaos_' . a:ftsnip . ' syntax/' . a:ftsnip . '.vim'
        execute 'syntax region ywchaos_' . a:ftsnip . 'Snip matchgroup=Snip start="' . begin . '" end="' . end . '" contains=@ywchaos_' . a:ftsnip
        execute 'let b:ywchaos_syntax_' . a:ftsnip . '=1'
        unlet b:current_syntax
        if exists("oldcurrent_syntax")
            let b:current_syntax = oldcurrent_syntax
        endif
    endif
endfunction "}}}

function Ywchaos_InsertSnip() "{{{
    echohl MoreMsg
    let ftsnip = input("Which filetype of snip? ", "", "customlist,Ywchaos_ListFt")
    echohl None
    call Ywchaos_SynSnip(ftsnip)
    execute 'normal o<BEGINSNIP=' . ftsnip . '>'
    execute 'normal o<ENDSNIP=' . ftsnip . '>'
    normal O
    startinsert
endfunction "}}}

" cmd-completion
function Ywchaos_ListTags(A,L,P) "{{{ Input cmdline's auto-completion
    let comp = []
    if match(getline(1), '^TAGS:\s\+\S') == -1
        call Ywchaos_MakeTagsline()
    endif
    for c in split(getline(1), '\s\+')[1:]
        if match(c, a:L) != -1
            call add(comp, c)
        endif
    endfor
    return comp
endfunction "}}}

function Ywchaos_ListFt(A,L,P) "{{{ Input cmdline's auto-completion
    let comp = []
    for p in split(&runtimepath, ',')
        for f in split(globpath(p.'/syntax/', '*.vim'), '\n')
            let ft = matchstr(f, '[^/]*\ze\.vim$')
            if match(ft, a:L) != -1
                call add(comp, ft)
            endif
        endfor
    endfor
    return comp
endfunction "}}}
