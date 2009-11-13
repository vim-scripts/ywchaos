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

let s:ywchaos_datefmt = "%m/%d/%Y"
let s:ywchaos_timefmt = "%H:%M:%S"

function Ywchaos_MakeTagsline(...) "{{{ Reflesh the TAGSLINE
    let save_cursor = getpos(".")
    call Ywchaos_FindSnipft()
    let tllst=[]
    let tndic={}
    g/@\S\+/call add(tllst, getline('.'))
    for line in tllst
        for tagn in filter(split(line), 'v:val =~ "@\\S\\+"')
            for mt in split(tagn[1:], '|')
                let sl = split(mt, ':')
                let sltitle = sl[0]
                let sd = []
                if len(sl) > 1
                    for st in sl[1:]
                        call add(sd, st)
                    endfor
                endif
                if !has_key(tndic, sltitle)
                    let tndic[sltitle] = sd
                else
                    for it in sd
                        if match(tndic[sltitle], it) == -1
                            call add(tndic[sltitle], it)
                        endif
                    endfor
                endif
            endfor
        endfor
    endfor
    let s:ywchaos_tagsdic = tndic
    call Ywchaos_SynTags()
    let tagsline = []
    for n in sort(keys(tndic))
        call add(tagsline, n . ' ' . join(tndic[n]))
    endfor
    normal gg0
    if match(getline(1), '^<TAGS>$') != -1
        let s:ywchaos_tagslineregions = 2
    else
        let s:ywchaos_tagslineregions = -1
    endif
    let s:ywchaos_tagslineregione = searchpos('^<\/TAGS>$', 'W')[0] - 1
    let oldtagsdic = {}
    if s:ywchaos_tagslineregione != -1 && s:ywchaos_tagslineregions == 2
        for l in range(s:ywchaos_tagslineregions, s:ywchaos_tagslineregione)
            let cllst = split(getline(l), '\s\+')
            let clmem = []
            if len(cllst) > 1
                let clmem = cllst[1:]
            endif
            let oldtagsdic[cllst[0]] = clmem
        endfor
    endif
    if s:ywchaos_tagsdic != oldtagsdic || exists("a:1")
        let maxlen = 0
        for nl in keys(tndic)
            let len = strlen(nl)
            if len >= maxlen
                let maxlen = len
            endif
        endfor
        for n in range(0, len(tagsline) - 1)
            let tagsline[n] = substitute(tagsline[n], '\s\+', repeat(' ', maxlen + 6 - strlen(split(tagsline[n], '\s\+')[0])), '')
        endfor
        if s:ywchaos_tagslineregions == 2 && s:ywchaos_tagslineregione != -1
            execute s:ywchaos_tagslineregions.','s:ywchaos_tagslineregione.'d'
            call append(1, tagsline)
        else
            call append(0, ['<TAGS>'] + tagsline + ['</TAGS>'])
        endif
    endif
    call setpos('.', save_cursor)
endfunction "}}}

function Ywchaos_VimgrepTag() "{{{ Using vimgrep to find the tag
    execute 'lvimgrep /@' . input("context: ", expand("<cword>"), "customlist,Ywchaos_ListTags") . '/j %'
    lopen
endfunction "}}}

function Ywchaos_NewItem() "{{{ Create new entry.
    normal gg
    call search(strftime(s:ywchaos_datefmt), 'W')
    let lno = line(".")
    if lno != 1
        call append(lno, strftime(s:ywchaos_timefmt)." ")
        let newlno = lno + 1
    else
        call search('^[0-9/]\+', 'W')
        let lno = line(".")-1
        if lno != 0
            call append(lno, [strftime(s:ywchaos_datefmt), strftime(s:ywchaos_timefmt)." "])
            let newlno = lno + 2
        else
            let lno = line("$")
            call append(lno, [strftime(s:ywchaos_datefmt), strftime(s:ywchaos_timefmt)." "])
            let newlno = lno + 2
        endif
    endif
    silent! execute 'normal '.newlno.'Gzo'
    startinsert!
endfunction "}}}

function Ywchaos_Tab(m) "{{{ <Tab> key map.
    if a:m == 'n'
        let line = line('.')
        if line >= s:ywchaos_tagslineregions && line <= s:ywchaos_tagslineregione && foldclosed('.') != 1
            let cwd=expand("<cword>")
            if cwd !~ '\s\+' || cwd !~ 'TAGS:'
                let save_cursor = getpos(".")
                normal zMzv
                execute 'g/\(@\|@\S\+\(|\|:\)\)'.cwd.'\>/normal zv'
                call setpos('.', save_cursor)
            endif
        else
            silent! normal za
        endif
    elseif a:m == 'i'
        if pumvisible()
            return "\<C-n>"
        endif
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] !~ '\s'
            let start -= 1
        endwhile
        if line[start] == '@'
            return "\<C-x>\<C-u>"
        endif
        return "\<tab>"
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

function Ywchaos_FindSnipft() "{{{ Find the Snips filetype
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
    call setpos('.', save_cursor)
endfunction "}}}

function Ywchaos_SynSnip(ftsnip,...) "{{{ snip syntax
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
        execute 'syntax region ywchaos_' . a:ftsnip . 'Snip matchgroup=Comment start="' . begin . '" end="' . end . '" contains=@ywchaos_' . a:ftsnip
        execute 'let b:ywchaos_syntax_' . a:ftsnip . '=1'
        unlet b:current_syntax
        if exists("oldcurrent_syntax")
            let b:current_syntax = oldcurrent_syntax
        endif
    endif
endfunction "}}}

function Ywchaos_SynTags() "{{{ tags syntax
    let hldic = copy(s:ywchaos_tagsdic)
    for k in keys(hldic)
        for sk in hldic[k]
            if !has_key(hldic, sk)
                let hldic[sk] = ''
            endif
        endfor
    endfor
    execute 'syntax match ywchaoskwd /\('.escape(join(reverse(sort(keys(hldic))), '\|'), '/$.').'\)/'
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
    elseif a:l == 1 && match(line, '^<TAGS>$') != -1
        let s:ywchaos_tagsp = 1
        return '>1'
    elseif match(line, '^<\/TAGS>$') != -1 && exists("s:ywchaos_tagsp")
        unlet s:ywchaos_tagsp
        return '<1'
    else
        return '='
    endif
endfunction "}}}

function Ywchaos_CompleteTags(findstart, base) "{{{ Tag name completion for insert mode
    if a:findstart
        let s:line = getline('.')
        let line = s:line
        let s:orig = col('.') - 1
        let start = s:orig
        while start > 0 && line[start - 1] != '@' && line[start - 1] !~ '\s'
            if line[start - 1] == ':' && !exists("stag") && !exists("mtag")
                let stag = start
            elseif line[start - 1] == '|' && !exists("mtag")
                let mtag = start
            endif
            let start -= 1
        endwhile
        if line[start - 1] == '@'
            if exists("stag")
                let s:stag = stag
                if exists("mtag")
                    let s:mtag = mtag
                else
                    let s:mtag = start
                endif
                return stag
            elseif exists("mtag")
                let s:mtag = mtag
                return mtag
            else
                return start
            endif
        endif
    else
        let res = []
        for m in keys(s:ywchaos_tagsdic)
            if exists("s:stag")
                if m =~ '^' . s:line[s:mtag : ( s:stag - 2 )]
                    for s in s:ywchaos_tagsdic[m]
                        if s =~ '^' . a:base
                            call add(res, s)
                        endif
                    endfor
                endif
            else
                if m =~ '^' . a:base
                    call add(res, m)
                endif
            endif
        endfor
        unlet! s:orig
        unlet! s:line
        unlet! s:stag
        unlet! s:mtag
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
