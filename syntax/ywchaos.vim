" Vim syntax file
" Language:	ywchaos file
" Maintainer:	Wu, Yue (vanopen@gmail.com)

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

syn match ywchaosTag		"\s\zs@\S*" contains=ywchaosTagPre
syn match ywchaosTag		"^\zs@\S*" contains=ywchaosTagPre
hi def link ywchaosTag		Tag

syn match ywchaosTagPre		contained "@"
hi def link ywchaosTagPre	Ignore
