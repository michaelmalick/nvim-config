-- atom.nvim -- an atomone neovim color theme
--
-- Version: 0.1
-- Designer: Michael Malick
--
-- For details of highlight groups see :h syntax
-- To inspect filetype syntax files use :e $VIMRUNTIME/syntax/html.vim

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
vim.g.colors_name = "atom"
local hi = vim.api.nvim_set_hl

local base0
local base1
local base2
local base3
local base4
local base5
local base6
local base7
local magenta_a
local red_a
local yellow_a
local green_a
local cyan_a
local blue_a
local magenta_b
local red_b
local yellow_b
local green_b
local cyan_b
local blue_b
local magenta_h
local red_h
local yellow_h
local green_h
local cyan_h
local blue_h
local magenta_d
local red_d
local yellow_d
local green_d
local cyan_d
local blue_d
local term_black
local term_brblack
local term_white
local term_brwhite

if vim.o.background == 'dark' then
    base0     = "#1D222B"
    base1     = "#252A32"
    base2     = "#2E323B"
    base3     = "#50545D"
    base4     = "#767B85"
    base5     = "#8E949E"
    base6     = "#C7CDDA"
    base7     = "#DFE6F3"
    magenta_a = "#C678DD"
    red_a     = "#E06C75"
    yellow_a  = "#D19A66"
    green_a   = "#98C379"
    cyan_a    = "#56B6C2"
    blue_a    = "#61AFEF"
    magenta_b = "#E484FF"
    red_b     = "#FF7D87"
    yellow_b  = "#F4A647"
    green_b   = "#94D755"
    cyan_b    = "#39CFE2"
    blue_b    = "#6DC0FF"
    magenta_h = "#6F2B80"
    red_h     = "#80262F"
    yellow_h  = "#6C481F"
    green_h   = "#445F2E"
    cyan_h    = "#1D5960"
    blue_h    = "#025682"
    magenta_d = "#470154"
    red_d     = "#54000E"
    yellow_d  = "#3E2400"
    green_d   = "#1C3300"
    cyan_d    = "#023034"
    blue_d    = "#032D47"
    term_black   = base0
    term_brblack = base4
    term_white   = base6
    term_brwhite = base7
else
    base0     = "#FAFAFA"
    base1     = "#EFEFEF"
    base2     = "#E4E4E3"
    base3     = "#B9BCBA"
    base4     = "#8E9392"
    base5     = "#757B7C"
    base6     = "#43484E"
    base7     = "#32343D"
    magenta_a = "#A626A4"
    red_a     = "#CA1243"
    yellow_a  = "#C18401"
    green_a   = "#50A14F"
    cyan_a    = "#0184BC"
    blue_a    = "#4078F2"
    magenta_b = "#DE2FDB"
    red_b     = "#F4263F"
    yellow_b  = "#E08824"
    green_b   = "#23B623"
    cyan_b    = "#2E98FC"
    blue_b    = "#4482FF"
    magenta_h = "#F2AFEF"
    red_h     = "#FFB3BB"
    yellow_h  = "#FCCFA2"
    green_h   = "#B9E1B9"
    cyan_h    = "#A5D5FF"
    blue_h    = "#C3CEFF"
    magenta_d = "#FFC2FD"
    red_d     = "#FFC9CF"
    yellow_d  = "#FFDCBD"
    green_d   = "#C5EDC5"
    cyan_d    = "#C1E0FF"
    blue_d    = "#D4DCFF"
    term_black   = base7
    term_brblack = base5
    term_white   = base2
    term_brwhite = base0
end

hi(0, "Normal", {fg = base7, bg = base0})

-- Basic syntax (:h group-name)
hi(0, "Comment", {fg = base3})
hi(0, "Constant", {fg = cyan_a})
hi(0, "String", {fg = base5, italic = true})
hi(0, "Identifier", {fg = blue_a})
hi(0, "Function", {fg = blue_a})
hi(0, "Operator", {fg = green_a})
hi(0, "Statement", {fg = magenta_a})
hi(0, "PreProc", {fg = yellow_a})
hi(0, "Type", {fg = magenta_a})
hi(0, "Special", {fg = yellow_a})
hi(0, "Delimiter", {fg = base4})
hi(0, "Tag", {fg = blue_a, underline = true, sp = blue_a})
hi(0, "Underlined", {underline = true, sp = base7})
hi(0, "Ignore", {fg = base2})
hi(0, "Error", {fg = red_a})
hi(0, "Todo", {fg = base7, bold = true})

-- Builtin highlight groups (:h highlight-groups)
hi(0, "ColorColumn", {link = "CursorLine"})
hi(0, "Conceal", {link = "Ignore"})
hi(0, "CurSearch", {link = "IncSearch"})
hi(0, "Cursor", {fg = base1, bg = base7})
hi(0, "lCursor", {link = "Cursor"})
hi(0, "CursorIM", {link = "Cursor"})
hi(0, "CursorColumn", {link = "CursorLine"})
hi(0, "CursorLine", {bg = base1})
hi(0, "Directory", {fg = blue_a})
hi(0, "DiffAdd", {fg = green_a, bg = base1})
hi(0, "DiffChange", {fg = blue_a, bg = base1})
hi(0, "DiffDelete", {fg = red_a, bg = base1})
hi(0, "DiffText", {fg = yellow_a, bg = base1})
hi(0, "EndOfBuffer", {link = "NonText"})
hi(0, "TermCursor", {link = "Cursor"})
hi(0, "TermCursorNC", {link = "Cursor"})
hi(0, "ErrorMsg", {link = "Error"})
hi(0, "WinSeparator", {fg = base3})
hi(0, "VertSplit", {link = "WinSeparator"})
hi(0, "Folded", {link = "Normal"})
hi(0, "FoldColumn", {fg = base3})
hi(0, "SignColumn", {link = "FoldColumn"})
hi(0, "IncSearch", {fg = red_b, bg = red_d})
hi(0, "Substitute", {link = "IncSearch"})
hi(0, "LineNr", {fg = base3})
hi(0, "LineNrAbove", {link = "LineNr"})
hi(0, "LineNrBelow", {link = "LineNr"})
hi(0, "CursorLineNr", {fg = base5})
hi(0, "CursorLineSign", {link = "CursorLineNr"})
hi(0, "CursorLineFold", {link = "CursorLineNr"})
hi(0, "MatchParen", {fg = red_a, bg = base2})
hi(0, "ModeMsg", {fg = cyan_a})
hi(0, "MsgArea", {link = "Normal"})
hi(0, "MsgSeparator", {link = "StatusLine"})
hi(0, "MoreMsg", {link = "ModeMsg"})
hi(0, "NonText", {fg = base3})
hi(0, "NormalFloat", {link = "PMenu"})
hi(0, "FloatBorder", {fg = base2, bg = base1})
hi(0, "NormalNC", {link = "Normal"})
hi(0, "PMenu", {fg = base6, bg = base1})
hi(0, "PMenuSel", {fg = base0, bg = blue_a})
hi(0, "PMenuSbar", {fg = base4, bg = base2})
hi(0, "PMenuThumb", {fg = base4, bg = base2})
hi(0, "Question", {fg = cyan_a})
hi(0, "QuickFixLine", {link = "Special"})
hi(0, "Search", {fg = green_b, bg = green_d})
hi(0, "SpecialKey", {fg = base7})
hi(0, "SpellBad", {sp = red_a, undercurl = true})
hi(0, "SpellCap", {sp = red_a, undercurl = true})
hi(0, "SpellLocal", {sp = cyan_a, undercurl = true})
hi(0, "SpellRare", {sp = cyan_a, undercurl = true})
hi(0, "StatusLine", {fg = base7, bg = base2})
hi(0, "StatusLineNC", {fg = base0, bg = base2})
hi(0, "StatusLineTerm", {link = "StatusLine"})
hi(0, "StatusLineTermNC", {link = "StatusLineNC"})
hi(0, "TabLine", {link = "StatusLine"})
hi(0, "TabLineFill", {link = "TabLine"})
hi(0, "TabLineSel", {fg = base6, bg = base0, bold = true})
hi(0, "Title", {fg = blue_a})
hi(0, "Visual", {bg = blue_h})
hi(0, "VisualNOS", {bg = blue_h})
hi(0, "WarningMsg", {fg = yellow_a})
hi(0, "Whitespace", {link = "Comment"})
hi(0, "WildMenu", {link = "PMenuSel"})
hi(0, "WinBar", {link = "StatusLine"})
hi(0, "WinBarNC", {link = "StatusLineNC"})


--Diagnostics (:h diagnostic-highlights)
hi(0, "DiagnosticError", {fg = red_a})
hi(0, "DiagnosticWarn", {fg = yellow_a})
hi(0, "DiagnosticInfo", {fg = cyan_a})
hi(0, "DiagnosticHint", {fg = blue_a})
hi(0, "DiagnosticVirtualTextError", {link = "DiagnosticError"})
hi(0, "DiagnosticVirtualTextWarn", {link = "DiagnosticWarn"})
hi(0, "DiagnosticVirtualTextInfo", {link = "DiagnosticInfo"})
hi(0, "DiagnosticVirtualTextHint", {link = "DiagnosticHint"})
hi(0, "DiagnosticUnderlineError", {underline = true, sp = red_a})
hi(0, "DiagnosticUnderlineWarn", {underline = true, sp = yellow_a})
hi(0, "DiagnosticUnderlineInfo", {underline = true, sp = cyan_a})
hi(0, "DiagnosticUnderlineHint", {underline = true, sp = blue_a})
hi(0, "DiagnosticSignError", {link = "DiagnosticError"})
hi(0, "DiagnosticSignWarn", {link = "DiagnosticWarn"})
hi(0, "DiagnosticSignInfo", {link = "DiagnosticInfo"})
hi(0, "DiagnosticSignHint", {link = "DiagnosticHint"})
hi(0, "DiagnosticFloatingError", {bg = base1, fg = red_a})
hi(0, "DiagnosticFloatingWarn", {bg = base1, fg = yellow_a})
hi(0, "DiagnosticFloatingInfo", {bg = base1, fg = cyan_a})
hi(0, "DiagnosticFloatingHint", {bg = base1, fg = blue_a})


-- Treesitter
-- See: https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md#highlights
hi(0, "@comment", {link = "Comment"})
hi(0, "@error", {link = "Error"})
hi(0, "@none", {})
hi(0, "@preproc", {link = "PreProc"})
hi(0, "@define", {link = "Define"})
hi(0, "@operator", {link = "Operator"})
hi(0, "@punctuation.delimiter", {link = "Delimiter"})
hi(0, "@punctuation.bracket", {link = "Delimiter"})
hi(0, "@punctuation.special", {link = "Special"})
hi(0, "@string", {link = "String"})
hi(0, "@string.regex", {link = "Special"})
hi(0, "@string.escape", {link = "Special"})
hi(0, "@string.special", {link = "Special"})
hi(0, "@character", {link = "Character"})
hi(0, "@character.special", {link = "SpecialChar"})
hi(0, "@boolean", {link = "Boolean"})
hi(0, "@number", {link = "Number"})
hi(0, "@float", {link = "Float"})
hi(0, "@function", {link = "Function"})
hi(0, "@function.builtin", {link = "Function"})
hi(0, "@function.call", {link = "Function"})
hi(0, "@function.macro", {link = "Macro"})
hi(0, "@method", {link = "Function"})
hi(0, "@method.call", {link = "Function"})
hi(0, "@constructor", {link = "SpecialChar"})
hi(0, "@parameter", {})
hi(0, "@keyword", {link = "Keyword"})
hi(0, "@keyword.function", {link = "Type"})
hi(0, "@keyword.operator", {link = "Operator"})
hi(0, "@keyword.return", {link = "Keyword"})
hi(0, "@conditional", {link = "Conditional"})
hi(0, "@repeat", {link = "Repeat"})
hi(0, "@debug", {link = "Debug"})
hi(0, "@label", {link = "Label"})
hi(0, "@include", {link = "Include"})
hi(0, "@exception", {link = "Exception"})
hi(0, "@type", {link = "Type"})
hi(0, "@type.builtin", {link = "Type"})
hi(0, "@type.definition", {link = "Typedef"})
hi(0, "@type.qualifier", {link = "Type"})
hi(0, "@storageclass", {link = "StorageClass"})
hi(0, "@storageclass.lifetime", {link = "Type"})
hi(0, "@attribute", {link = "Type"})
hi(0, "@field", {link = "Structure"})
hi(0, "@property", {link = "Structure"})
hi(0, "@variable", {})
hi(0, "@variable.builtin", {link = "Identifier"})
hi(0, "@constant", {link = "Constant"})
hi(0, "@constant.builtin", {link = "Constant"})
hi(0, "@constant.macro", {link = "Constant"})
hi(0, "@namespace", {link = "Identifier"})
hi(0, "@symbol", {link = "Special"})
hi(0, "@text", {})
hi(0, "@text.strong", {bold = true})
hi(0, "@text.emphasis", {italic = true})
hi(0, "@text.underline", {underline = true})
hi(0, "@text.strike", {strikethrough = true})
hi(0, "@text.title", {link = "Title"})
hi(0, "@text.literal", {link = "Constant"})
hi(0, "@text.uri", {link = "Tag"})
hi(0, "@text.math", {link = "Constant"})
hi(0, "@text.environment", {link = "Statement"})
hi(0, "@text.environment.name", {})
hi(0, "@text.reference", {link = "Identifier"})
hi(0, "@text.todo", {link = "Todo"})
hi(0, "@text.note", {link = "Todo"})
hi(0, "@text.warning", {link = "WarningMsg"})
hi(0, "@text.danger", {link = "Error"})
hi(0, "@text.diff.add", {link = "DiffAdd"})
hi(0, "@text.diff.delete", {link = "DiffDelete"})
hi(0, "@tag", {link = "Type"})
hi(0, "@tag.attribute", {link = "Identifier"})
hi(0, "@tag.delimiter", {link = "Delimiter"})


-- Builtin filetypes
hi(0, "htmlH1", {fg = blue_a})
hi(0, "htmlH2", {fg = magenta_a})
hi(0, "htmlH3", {fg = green_a})
hi(0, "htmlH4", {fg = cyan_a})
hi(0, "htmlH5", {fg = yellow_a})
hi(0, "htmlH6", {fg = red_a})
hi(0, "htmlItalic", {italic = true})
hi(0, "htmlLink", {link = "Tag"})
hi(0, "healthSuccess", {fg = green_a})
hi(0, "helpHyperTextJump", {link = "Tag"})
hi(0, "helpHyperTextEntry", {fg = cyan_a})
hi(0, "helpSectionDelim", {fg = magenta_a})
hi(0, "markdownUrl", {link = "Tag"})
hi(0, "markdownCode", {fg = cyan_a})
hi(0, "markdownLinkText", {link = "Normal"})
hi(0, "markdownLinkTextDelimiter", {fg = blue_a})
hi(0, "markdownHeadingDelimiter", {link = "Delimiter"})
hi(0, "markdownRule", {link = "Delimiter"})
hi(0, "diffAdded", {link = "DiffAdd"})
hi(0, "diffRemoved", {link = "DiffDelete"})
hi(0, "diffChanged", {link = "DiffChange"})
hi(0, "diffLine", {fg = base6, bold = true, underline = true, sp = base6})
hi(0, "diffFile", {fg = blue_a, bg = base2, bold = true})
hi(0, "diffNewFile", {fg = blue_a})
hi(0, "diffOldFile", {link = "diffNewfile"})
hi(0, "diffSubName", {fg = base6, underline = true, sp = base6})
hi(0, "diffIndexLine", {fg = blue_a})
hi(0, "gitDiff", {link = "Comment"})
hi(0, "gitKeyword", {link = "Normal"})
hi(0, "gitIdentity", {fg = base7})
hi(0, "gitEmail", {link = "Normal"})
hi(0, "gitDate", {fg = cyan_a})
hi(0, "gitHash", {link = "Comment"})
hi(0, "gitIdentityKeyword", {link = "Comment"})
hi(0, "gitcommitBranch", {fg = magenta_a})
hi(0, "gitcommitOnBranch", {link = "Normal"})
hi(0, "gitcommitHeader", {fg = blue_a})
hi(0, "gitcommitType", {link = "Normal"})
hi(0, "gitcommitFile", {link = "Normal"})
hi(0, "gitcommitSummary", {link = "Normal"})
hi(0, "gitcommitOverflow", {link = "WarningMsg"})
hi(0, "gitcommitDiff", {link = "gitDiff"})
hi(0, "texCite", {fg = cyan_a})
hi(0, "texSection", {link = "Title"})
hi(0, "texRefZone", {fg = magenta_a})
hi(0, "texMath", {fg = green_a})
hi(0, "texGreek", {link = "texMath"})
hi(0, "texSubscript", {link = "Normal"})
hi(0, "texSubscripts", {link = "Normal"})
hi(0, "texSuperscript", {link = "Normal"})
hi(0, "texSuperscripts", {link = "Normal"})
hi(0, "bibType", {fg = magenta_a})
hi(0, "bibKey", {fg = yellow_a})
hi(0, "makeTarget", {fg = red_a})
hi(0, "makeInclude", {fg = blue_a})
hi(0, "makeCommands", {fg = cyan_a})
hi(0, "rDollar", {link = "Delimiter"})
hi(0, "rPrompt", {fg = green_a})
hi(0, "rLstElmt", {fg = base6})
hi(0, "yamlDocumentStart", {link = "Comment"})
hi(0, "yamlKeyValueDelimiter", {link = "Comment"})


-- Plugins
hi(0, "fugitiveHeader", {link = "Normal"})
hi(0, "fugitiveHunk", {link = "gitDiff"})
hi(0, "fugitiveSymbolicRef", {link = "gitcommitBranch"})
hi(0, "fugitiveHelpHeader", {link = "Comment"})
hi(0, "fugitiveHelpTag", {link = "Comment"})
hi(0, "fugitiveUnstagedModifier", {fg = base5})
hi(0, "fugitiveStagedModifier", {link = "fugitiveStagedModifier"})
hi(0, "fugitiveHeading", {link = "Title"})
hi(0, "fugitiveUnstagedHeading", {link = "Title"})
hi(0, "fugitiveStagedHeading", {link = "Title"})
hi(0, "gvMeta", {link = "gitcommitBranch"})
hi(0, "gvAuthor", {link = "gitIdentity"})
hi(0, "gvDate", {link = "gitDate"})
hi(0, "gvSha", {link = "gitHash"})
hi(0, "gvTag", {link = "Tag"})
hi(0, "Sneak", {link = "IncSearch"})
hi(0, "SneakScope", {fg = base1, bg = base7, bold = true})
hi(0, "LocalHighlight", {bg=base2})
hi(0, "TelescopeSelection", {fg = cyan_a, bg = base1})
hi(0, "TelescopePreviewLine", {link = "CursorLine"})
hi(0, "TelescopeMatching", {link = "IncSearch"})
hi(0, "TelescopeSelectionCaret", {fg = red_a})



-- Terminal
vim.g.terminal_color_0  = term_black
vim.g.terminal_color_1  = red_a
vim.g.terminal_color_2  = green_a
vim.g.terminal_color_3  = yellow_a
vim.g.terminal_color_4  = blue_a
vim.g.terminal_color_5  = magenta_a
vim.g.terminal_color_6  = cyan_a
vim.g.terminal_color_7  = term_white
vim.g.terminal_color_8  = term_brblack
vim.g.terminal_color_9  = red_b
vim.g.terminal_color_10 = green_b
vim.g.terminal_color_11 = yellow_b
vim.g.terminal_color_12 = blue_b
vim.g.terminal_color_13 = magenta_b
vim.g.terminal_color_14 = cyan_b
vim.g.terminal_color_15 = term_brwhite

