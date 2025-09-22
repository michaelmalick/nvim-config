"" pawn.vim - selective pandoc syntax support
"" Author:   Michael Malick <malickmj@gmail.com>


syn region pawnComment
  \ matchgroup=Comment start="<!--" end="-->" contains=@NoSpell
syn match pawnPCite /@\%[\w\-]*/ contains=@NoSpell
syn match pawnPCite /\[-\{0,1}@.\{-}\]/ contains=@NoSpell

syn match pawnWikiDelim   '\[\[.*\]\]' contains=pawnWikiLink,@NoSpell
syn match pawnWikiLink '\[\[\zs\d\{12}\ze\]\]' contained contains=@NoSpell

syn match pawnTitle /^%.*$/ contains=@NoSpell

unlet! b:current_syntax
syn include @tex syntax/tex.vim
syn region pawnMath start="\\\@<!\$" end="\$" contains=@tex keepend
syn region pawnMath start="\\\@<!\$\$" end="\$\$" contains=@tex keepend
syn match pawnStatement	"\\\a\+" contains=@tex keepend
call TexNewMathZone("A","displaymath",1)
call TexNewMathZone("B","eqnarray",1)
call TexNewMathZone("C","equation",1)
call TexNewMathZone("D","math",1)
call TexNewMathZone("D","align",1)

"" allow tex math in link caption text
syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart, pawnMath

"" The tpope markdown syntax file has the following line
"" syn match markdownListMarker "\%(\t\| \{0,4\}\)[-*+]\%(\s\+\S\)\@=" contained
"" which causes any list item with more than 4 spaces before it (third level) to
"" not be highlighted. Here I increase that level 5.
syn match markdownListMarker "\%(\t\| \{0,16\}\)[-*+]\%(\s\+\S\)\@=" contained

unlet! b:current_syntax
syn include @yamlTop syntax/yaml.vim
syn region pawnYaml start="\%^---$" end="^---$" contains=@yamlTop keepend

hi link pawnComment Comment
hi link pawnPCite Identifier
hi link pawnTitle Constant
hi link pawnMath Statement
hi link pawnYaml Comment
hi link pawnWikiLink markdownUrl
hi link pawnWikiDelim Delimiter

let b:current_syntax = "markdown"
