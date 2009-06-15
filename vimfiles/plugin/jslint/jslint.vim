function! s:JSLint() range
  cclose " Close quickfix window
  cexpr [] " Create empty quickfix list

  " Detect range
  if a:firstline == a:lastline
    let b:firstline = 1
    let b:lastline = '$'
  else 
    let b:firstline = a:firstline
    let b:lastline = a:lastline
  endif

  " Delete previous matches
  if exists('b:errors')
    for error in b:errors
      call matchdelete(error)
    endfor
  endif

  " Set up command and parameters
  let s:plugin_path = '"' . expand("~/") . '"'
  if has("win32")
    let s:cmd = 'cscript /NoLogo '
    let s:plugin_path = s:plugin_path . "vimfiles"
    let s:runjslint_ext = 'wsf'
  else
    let s:cmd = 'js'
    let s:plugin_path = s:plugin_path . ".vim"
    let s:runjslint_ext = 'js'
  endif
  let s:plugin_path = s:plugin_path . "/plugin/jslint/"
  let s:cmd = "cd " . s:plugin_path . " && " . s:cmd . " " . s:plugin_path 
               \ . "runjslint." . s:runjslint_ext
  let b:jslint_output = system(s:cmd, join(getline(b:firstline, b:lastline), 
              \ "\n") . "\n")

  let b:errors = []
  let b:has_errors = 0

  for error in split(b:jslint_output, "\n")
    " Match {line}:{char}:{message}
    let b:parts = matchlist(error, "\\(\\d\\+\\):\\(\\d\\+\\):\\(.*\\)")
    if !empty(b:parts)
      let b:has_errors = 1
      let l:line = b:parts[1] + (b:firstline - 1) " Get line relative to selection
      " Add line to match list
      call add(b:errors, matchadd('Error', '\%' . l:line . 'l'))
      " Add to quickfix
      caddexpr expand("%") . ":" . l:line . ":" . b:parts[2] . ":" . b:parts[3]
    endif
  endfor

  " Open the quickfix window if errors are present
  if b:has_errors == 1
    copen
  else " Or not
    echo "JSLint: All good."
  endif
endfunction

command! -range JSLint <line1>,<line2>call s:JSLint()

