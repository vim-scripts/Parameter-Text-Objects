" A Vim plugin that defines a parameter text object.
" Maintainer: David Larson <david@thesilverstream.com>
" Last Change: Feb 18, 2010
" See: :help text-objects
"   For a description of what can be done with text objects
" Also See: :help a(
"
" This script adds operators that can be used in normal or visual mode to
" operate on a parameter text object. A parameter is one argument of a
" function's argument list and is the text between parentheses or commas. If
" you want to remove the parentheses, then try a(.
"
"    aP    "a parameter", select a parameter, including one comma (if there is
"          one).
"
"    iP    "inner parameter", select a parameter, not including commas.
"
" TODO:
" - How can the script handle counts? (eg. 2daP)

if exists("loaded_parameter_objects") || &cp
  finish
endif
let loaded_parameter_objects = 1

vmap <silent> aP :<C-U>call <SID>parameter_object("a")<cr>
vmap <silent> iP :<C-U>call <SID>parameter_object("i")<cr>
omap <silent> aP :call <SID>parameter_object("a")<cr>
omap <silent> iP :call <SID>parameter_object("i")<cr>
function s:parameter_object(mode)
   let ve_save = &ve
   set virtualedit=onemore
   let l_save = @l
   try
      " Search for the end of the parameter text object
      if searchpair('(',',',')', 'mWs', "s:skip()") == 0
         return
      endif
      normal! "lyl
      if a:mode == "a" && @l == ','
         let gotone = 1
         normal! ml
      else
         normal! h
         normal! ml
         normal! l
      endif

      " Search for the start of the parameter text object
      if searchpair('(',',',')', 'bmW', "s:skip()") == 0
         normal! `'
         return
      endif
      normal! "lyl
      if a:mode == "a" && @l == ',' && !exists("gotone")
      else
         normal! l
      endif
      normal! v`l
   finally
      let &ve = ve_save
      let @l = l_save
   endtry
endfunction
function s:skip()
   let name = synIDattr(synID(line("."), col("."), 0), "name")
   if name =~? "comment"
      return 1
   elseif name =~? "string"
      return 1
   endif
   return 0
endfunction

" vim:fdm=marker fmr=function\ ,endfunction
