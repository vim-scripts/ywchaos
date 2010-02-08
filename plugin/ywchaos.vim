" vim: foldmethod=marker:
" mY oWn Chaos taking.
" Author: Wu, Yue <ywupub@gmail.com>
" License: BSD

if exists("s:loaded_ywchaos")
    finish
endif
let s:loaded_ywchaos = 1
scriptencoding utf-8

let s:ywchaos_datefmt = "%m/%d/%Y"
let s:ywchaos_timefmt = "%H:%M:%S"
let s:ywchaos_sync_kwdext = '[^\x00-\xff]'
let s:ywchaos_htmltagprel = 1 " Html pre tag goes from this line.
let s:ywchaos_trsline = 2 " Tags region starts from this line
let s:ywchaos_htmltagcat = ['img src=', 'pre style=', 'strong', 'a href=', "blockquote"]

function Ywchaos_MakeTagsline(...) "{{{ Reflesh the TAGS list region and add it.
    let save_cursor = getpos(".")
    call Ywchaos_FindSnipft()
    let tllst=[]
    let tndic={}
    g/\(\s\|^\)@\S\+/call add(tllst, getline('.'))
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
                call sort(tndic[sltitle])
            endfor
        endfor
    endfor
    let s:ywchaos_tagsdic = tndic
    call Ywchaos_SynTags()
    let oldtagsdic = {}
    normal gg0
    let trsline = searchpos('^<TAGS>$', 'W')[0]
    let b:trsline = searchpos('^<TAGS>$', 'W')[0]
    let s:ywchaos_treline = searchpos('^<\/TAGS>$', 'W')[0]
    if (trsline == s:ywchaos_trsline) && (s:ywchaos_treline != 0)
        for l in range(s:ywchaos_trsline + 1, s:ywchaos_treline - 1)
            let cllst = split(getline(l), '\s\+')
            let clmem = []
            if len(cllst) > 1
                let clmem = cllst[1:]
            endif
            let oldtagsdic[cllst[0]] = clmem
        endfor
    endif
    if s:ywchaos_tagsdic != oldtagsdic || exists("a:1")
        let tagsline = <SID>Ywchaos_GetTagsline()
        let maxlen = 0
        for nl in keys(s:ywchaos_tagsdic)
            let len = strlen(nl)
            if len >= maxlen
                let maxlen = len
            endif
        endfor
        for n in range(0, len(tagsline) - 1)
            let tagsline[n] = substitute(tagsline[n], '\s\+\ze\S', repeat(' ', maxlen + 6 - strlen(split(tagsline[n], '\s\+')[0])), '')
        endfor
        if (trsline == s:ywchaos_trsline) && (s:ywchaos_treline != 0)
            setlocal nofoldenable
            execute (s:ywchaos_trsline + 1).','.(s:ywchaos_treline - 1).'delete'
            setlocal foldenable
            call append(s:ywchaos_trsline, tagsline)
        else
            call append(s:ywchaos_htmltagprel - 1, '<pre style=”word-wrap: break-word; white-space: pre-wrap; white-space: -moz-pre-wrap” >')
            call append((s:ywchaos_trsline - 1), ['<TAGS>'] + tagsline + ['</TAGS>'])
        endif
        let save_cursor[1] += len(s:ywchaos_tagsdic) - len(oldtagsdic)
    endif
    call setpos('.', save_cursor)
endfunction "}}}

function s:Ywchaos_GetTag() "{{{ Get the tag name under the curosr
    let i = line('.') - s:ywchaos_trsline
    let si = len(split(getline('.')[0 : col('.') - 1], '\s\+')) - 1
    let tagsline = split(<SID>Ywchaos_GetTagsline()[i - 1], '\s\+')
    let tag = tagsline[0]
    let stag = ''
    if si
        let stag = '[|]*:' . tagsline[si]
    endif
    return [tag, stag]
endfunction "}}}

function s:Ywchaos_GetTagsline() "{{{ Get TAGS list region
    let tagsline = []
    for n in sort(keys(s:ywchaos_tagsdic))
        call add(tagsline, n . ' ' . join(s:ywchaos_tagsdic[n]))
    endfor
    return tagsline
endfunction "}}}

function Ywchaos_VimgrepTag() "{{{ vimgrep the tag
    let line = line('.')
    if line >= s:ywchaos_trsline && line <= s:ywchaos_treline && foldclosed('.') != 1
        let t = <SID>Ywchaos_GetTag()
        execute 'lvimgrep /\(@\||\)'. t[0] . t[1] . '/j %'
    else
        execute 'lvimgrep /@\(\S*\(:\||\)\|\)' . input("context: ", expand("<cword>"), "customlist,Ywchaos_ListTags") . '/j %'
    endif
    lopen
endfunction "}}}

function Ywchaos_NewItem() "{{{ Create new journey entry.
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

function Ywchaos_key_AutoTab(m) "{{{ The key <Tab> map.
    if a:m == "i" && pumvisible()
        return "\<C-n>"
    endif
    if a:m == 'normal'
        let line = line('.')
        if line > s:ywchaos_trsline && line < s:ywchaos_treline && foldclosed('.') != 1
            let t = <SID>Ywchaos_GetTag()
            let save_cursor = getpos(".")
            normal zMzv
            execute 'g/\(@\||\)'. t[0] . t[1] . '/normal zv'
            call setpos('.', save_cursor)
        else
            silent! normal za
        endif
    else
        let col = col('.') - 1
        let synn = synIDattr(synID(line("."), col, 1), "name")
        if synn =~ '\<ywchaosTag\(\|pre\)\>'
            return "\<C-x>\<C-u>"
        elseif synn =~ '\<htmlTag\>' && getline('.')[col - 4 : col - 1] == 'src='
            return input("Insert file: ", "", "file")
        endif
        return "\<tab>"
    endif
endfunction "}}}

function Ywchaos_Insert() "{{{ Insert func.
    echohl ModeMsg
    echon "Insert:\n"
    echohl MoreMsg
    echon "(s)nip; html(t)ag"
    let it = ''
    while it !~ '[st]'
        let it = nr2char(getchar())
        continue
    endwhile
    echohl None
    if it == 's'
        call Ywchaos_InsertSnip()
    elseif it == 't'
        call Ywchaos_Inserthtmltag()
    endif
endfunction "}}}

function Ywchaos_InsertSnip() "{{{ Insert snip.
    echohl ModeMsg
    redraw
    let ftsnip = input("snip type: ", "", "customlist,Ywchaos_ListFt")
    echohl None
    execute 'normal o<BEGINSNIP=' . ftsnip . '>'
    execute 'normal o<ENDSNIP=' . ftsnip . '>'
    normal O
    call Ywchaos_SynSnip(ftsnip)
    startinsert
endfunction "}}}

function Ywchaos_Inserthtmltag() "{{{ Insert html link tag.
    echohl MoreMsg
    redraw
    let htmltag = input("Html tag: ", "", "customlist,Ywchaos_ListHtmlTags")
    echohl None
    let htmltagl = '<' . htmltag
    let htmltagr = '/' . htmltag . '>'
    if htmltag =~ '\s\+src='
        let htmltagl = '<img src='
        let htmltagr = '>'
    elseif htmltag =~ '\S\s\+\S'
        let htmltagl = '<' . htmltag . '"'
        let htmltagr = '">'
    endif
    execute 'normal a' . htmltagl
    let save_cursor = getpos(".") | let save_cursor[2] += 1
    execute 'normal a' . htmltagr
    " TODO file completion
    call setpos('.', save_cursor)
    startinsert
endfunction "}}}

function Ywchaos_FindSnipft() "{{{ Check the Snip filetypes
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

function Ywchaos_SynSnip(ftsnip,...) "{{{ Syntax for snip
    if !exists('b:ywchaos_ftsnipsdic')
        let b:ywchaos_ftsnipsdic = {}
    endif
    if !has_key(b:ywchaos_ftsnipsdic, a:ftsnip)
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
        execute 'syntax region ywchaos_' . a:ftsnip . 'Snip matchgroup=Comment start="' . begin . '" end="' . end . '" contains=@ywchaos_' . a:ftsnip
        let b:ywchaos_ftsnipsdic[a:ftsnip] = ''
        unlet b:current_syntax
        if exists("oldcurrent_syntax")
            let b:current_syntax = oldcurrent_syntax
        endif
    endif
endfunction "}}}

function Ywchaos_SynTags() "{{{ Syntax for tag name
    let hldic = copy(s:ywchaos_tagsdic)
    for k in keys(hldic)
        for sk in hldic[k]
            if !has_key(hldic, sk)
                let hldic[sk] = ''
            endif
        endfor
    endfor
    let spat = []
    for s in reverse(sort(keys(hldic)))
        if s !~ s:ywchaos_sync_kwdext
            call add(spat, '\<' . s . '\>')
        else
            call add(spat, s)
        endif
    endfor
    syntax clear ywchaoskwd
    execute 'syntax match ywchaoskwd /\('.escape(join(spat, '\|'), '/$.').'\)\c/'
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
    elseif ( match(line, '^<TAGS>$') != -1 ) && ( a:l == s:ywchaos_trsline )
        let s:temp_tagsp = 1
        return '>1'
    elseif ( match(line, '^<\/TAGS>$') != -1 ) && exists("s:temp_tagsp") && ( a:l == s:ywchaos_treline )
        unlet s:temp_tagsp
        return '<1'
    else
        return '='
    endif
endfunction "}}}

function Ywchaos_CompleteFunc(findstart, base) "{{{ Completion func for Tag name in insert mode
    if a:findstart
        let s:line = getline('.')
        let line = s:line
        let s:orig = col('.') - 1
        let start = s:orig
        let s:temp_synn = synIDattr(synID(line("."), col(".") - 1, 1), "name")
        if s:temp_synn =~ '\<ywchaosTag\(\|pre\)\>'
            while start > 0 && line[start - 1] !~ '[@[:blank:]]'
                if line[start - 1] == ':'
                    if !exists("stag") && !exists("mtags")
                        let stag = start
                    endif
                    if !exists("mtags")
                        let s:mtage = start - 2
                    endif
                elseif line[start - 1] == '|' && !exists("mtags")
                    let mtags = start
                endif
                let start -= 1
            endwhile
            if line[start - 1] == '@'
                if exists("stag")
                    let s:stag = stag
                    if exists("mtags")
                        let s:mtags = mtags
                    else
                        let s:mtags = start
                    endif
                    return stag
                elseif exists("mtags")
                    let s:mtags = mtags
                    return mtags
                else
                    return start
                endif
            endif
        " elseif s:temp_synn =~ '\<htmlValue\>'
        "     while start > 0 && line[start - 1] !~ '[<=[:blank:]]'
        "         let start -= 1
        "     endwhile
        "     return start
        endif
    else
        if s:temp_synn =~ '\<ywchaosTag\(\|pre\)\>'
            unlet s:temp_synn
            let res = []
            for m in keys(s:ywchaos_tagsdic)
                if exists("s:stag")
                    if m =~ '^' . s:line[s:mtags : s:mtage]
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
            unlet! s:mtags
            unlet! s:mtage
            return res
        " elseif s:temp_synn =~ '\<htmlValue\>'
        "     unlet s:temp_synn
        "     return split(globpath('.', a:base.'*'), "\n")
        endif
    endif
endfunction "}}}

function Ywchaos_ListTags(A,L,P) "{{{ Completion func for tags in cmdline
    let comp = {}
    if match(s:ywchaos_trsline, '^<TAGS>$') == -1
        call Ywchaos_MakeTagsline()
    endif
    for k in keys(s:ywchaos_tagsdic)
        if match(k, a:L) != -1
            let comp[k] = ''
        endif
        for sk in s:ywchaos_tagsdic[k]
            if match(sk, a:L) != -1
                let comp[sk] = ''
            endif
        endfor
    endfor
    return keys(comp)
endfunction "}}}

function Ywchaos_ListFt(A,L,P) "{{{ Completion func for snip filetypes to insert in cmdline
    let comp = {}
    for p in split(&runtimepath, ',')
        for f in split(globpath(p.'/syntax/', '*.vim'), '\n')
            let ft = matchstr(f, '[^/]*\ze\.vim$')
            if match(ft, '^'.a:L) != -1
                let comp[ft] = ''
            endif
        endfor
    endfor
    return keys(comp)
endfunction "}}}

function Ywchaos_ListHtmlTags(A,L,P) "{{{ Completion func for html tag to insert in cmdline
    let comp = []
    for p in s:ywchaos_htmltagcat
        if match(p, '^'.a:A) != -1
            call add(comp, p)
        endif
    endfor
    return comp
endfunction "}}}
