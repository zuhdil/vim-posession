if exists("g:loaded_posession") || v:version < 700 || &cp
  finish
endif
let g:loaded_posession = 1

if !exists(':Obsession')
  echo "vim-posession depends on tpope/vim-obsession, kindly install that first."
  finish
endif

if !exists('g:posession_dir')
  let g:posession_dir = '~/.local/share/vim-posession'
endif

if !isdirectory(fnamemodify(g:posession_dir, ':p'))
  call mkdir(fnamemodify(g:posession_dir, ':p'), 'p')
endif

function! s:StripTrailingSlash(name) "{{{1
  return a:name =~# '/$' ? a:name[:-2] : a:name
endfunction

function! s:GetDirName(...) "{{{1
  let dir = a:0 ? a:1 : getcwd()
  let dir = s:StripTrailingSlash(dir)
  return substitute(dir, '/', '%', 'g')
endfunction

function! s:GetSessionFileName(...) "{{{1
  let fname = a:0 && a:1 =~# '\.vim$' ? a:1 : call('s:GetDirName', a:000)
  let fname = s:StripTrailingSlash(fname)
  return fname =~# '\.vim$' ? fnamemodify(fname, ':t:r') : fnamemodify(fname, ':t')
endfunction

function! s:GetSessionFile(...) "{{{1
  return fnamemodify(g:posession_dir, ':p') . call('s:GetSessionFileName', a:000) . '.vim'
endfunction

function! s:IsBufferEmpty()
  return len(filter(range(1, bufnr('$')), '! empty(bufname(v:val)) && buflisted(v:val)')) < 1
endfunction

function! s:Posession(target)
  let sessionfile = call('s:GetSessionFile', !empty(a:target) ? [fnamemodify(expand(a:target), ':p')] : [])
  let targetdir = isdirectory(expand(a:target)) ? s:StripTrailingSlash(fnamemodify(expand(a:target), ':p')) : 0

  if !filereadable(sessionfile) && targetdir != getcwd()
    echo 'No session found for directory '.targetdir
    return ''
  endif

  if filereadable(sessionfile)
    if !empty(get(g:, 'this_obsession', ''))
      silent Obsession " Stop current session
      silent! noautocmd bufdo bw
    endif

    if !empty(get(g:, 'this_obsession', '')) || s:IsBufferEmpty()
      silent execute 'source' fnameescape(sessionfile)
    endif
  endif

  execute 'Obsession' fnameescape(sessionfile)
endfunction

command! -bar -nargs=? -complete=file Posession call s:Posession(<q-args>)
