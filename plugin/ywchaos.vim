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
    normal gg
    let snipl = searchpos('^\s*<BEGINSNIP=', 'W')[0]
    let snipdic = {}
    while snipl
        let snipname = matchstr(getline(snipl), '^\s*<BEGINSNIP=\zs\S\+\ze>')
        let snipdic[snipname] = 1
        let snipl = searchpos('^\s*<BEGINSNIP', 'W')[0]
    endwhile
    for snip in keys(snipdic)
        call Ywchaos_SynSnip(snip)
    endfor
    let tllst=[]
    let tndic={}
    g/@\S\+/call add(tllst, getline('.'))
    call setpos('.', save_cursor)
    for line in tllst
        for tagn in filter(split(line), 'v:val =~ "@\\S\\+"')
            for mt in split(tagn[1:], '|')
                let tndic[mt] = 1
            endfor
        endfor
    endfor
    let s:ywchaos_tagsdic = tndic
    let tagsline = 'TAGS: '.join(keys(tndic))
    let oldtagsline = getline(1)
    execute 'syntax match ywchaoskwd /\('.escape(join(keys(tndic), '\|'), '/').'\)/'
    hi def link ywchaoskwd Statement
    if tagsline != oldtagsline
        if match(getline(1), '^TAGS:\s\+\S') == 0
            call setline(1, tagsline)
        else
            call append(0, tagsline)
        endif
    endif
endfunction "}}}

function Ywchaos_VimgrepTag() "{{{ Using vimgrep to find the tag
    execute 'lvimgrep /@' . input("context: ", expand("<cword>"), "customlist,Ywchaos_ListTags") . '/j %'
    lopen
endfunction "}}}

function Ywchaos_FoldExpr(l) "{{{ Folding rule.
    let line=getline(a:l)
    if match(line, '^\d\{,2}/\d\{,2}/\d\{,4}') != -1
        return '>1'
    elseif match(line, '^\d\{,2}:\d\{,2}') != -1
        return '>2'
    elseif match(line, '^\s*<BEGINSNIP=.*') != -1
        return 'a1'
    elseif match(line, '^\s*<ENDSNIP=.*') != -1
        return 's1'
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

function Ywchaos_Tab(m) "{{{ <Tab> key map.
    if a:m == 'n' && line(".") == 1
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
    elseif a:m == 'i'
        if pumvisible()
            return "\<C-n>"
        endif
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] !~ '\(@\||\)' && line[start - 1] !~ '\s'
            let start -= 1
        endwhile
        if line[start - 1] =~ '\(@\||\)'
            return "\<C-x>\<C-u>"
        endif
        return "\<tab>"
    else
        normal za
    endif
endfunction "}}}

function Ywchaos_SynSnip(ftsnip,...) "{{{ syntax syn
    if !exists('b:ywchaos_syntax_'.a:ftsnip)
        let begin = '^\s*<BEGINSNIP=.*'
        let end = '^\s*<ENDSNIP=.*'
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

function Ywchaos_InsertSnip() "{{{ Insert snip.
    echohl MoreMsg
    let ftsnip = input("Which filetype of snip? ", "", "customlist,Ywchaos_ListFt")
    echohl None
    call Ywchaos_SynSnip(ftsnip)
    execute 'normal o<BEGINSNIP=' . ftsnip . '>'
    execute 'normal o<ENDSNIP=' . ftsnip . '>'
    normal O
    startinsert
endfunction "}}}

function Ywchaos_CompleteTags(findstart, base) "{{{ Tag name completion for insert mode
    if a:findstart
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] !~ '\(@\||\)' && line[start - 1] !~ '\s'
            let start -= 1
        endwhile
        if start >= 0 && line[start - 1] =~ '\s'
            return -1
        endif
        return start
    else
        let res = []
        for m in keys(s:ywchaos_tagsdic)
            if m =~ '^' . a:base
                call add(res, m)
            endif
        endfor
        return res
    endif
endfunction "}}}

function Ywchaos_ListTags(A,L,P) "{{{ Input cmdline's auto-completion
    let comp = {}
    if match(getline(1), '^TAGS:\s\+\S') == -1
        call Ywchaos_MakeTagsline()
    endif
    for c in split(getline(1), '\s\+')[1:]
        if match(c, a:L) != -1
            let comp[c] = 1
        endif
    endfor
    return keys(comp)
endfunction "}}}

function Ywchaos_ListFt(A,L,P) "{{{ Input cmdline's auto-completion
    let comp = {}
    for p in split(&runtimepath, ',')
        for f in split(globpath(p.'/syntax/', '*.vim'), '\n')
            let ft = matchstr(f, '[^/]*\ze\.vim$')
            if match(ft, '^'.a:L) != -1
                let comp[ft] = 1
            endif
        endfor
    endfor
    return keys(comp)
endfunction "}}}
