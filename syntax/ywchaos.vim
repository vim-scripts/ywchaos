" mY oWn Chaos taking.
" Author: Wu, Yue <vanopen@gmail.com>
" Last Change:	2009 Oct 09
" License: BSD

if exists("b:current_syntax")
  finish
endif

syntax match ywchaosTag '\s\zs@\S*' contains=ywchaosTagPre
syntax match ywchaosTag '^\zs@\S*' contains=ywchaosTagPre
highlight def link ywchaosTag Tag

syntax match ywchaosTagPre contained '@'
highlight def link ywchaosTagPre Ignore

syntax match ywchaosDateEntry '^\d\{,2}/\d\{,2}/\d\{,4}'
highlight def link ywchaosDateEntry Title
syntax match ywchaosTimeEntry '^\d\{2}:\d\{2}:\d\{2}'
highlight def link ywchaosTimeEntry Number

highlight link Snip Comment
