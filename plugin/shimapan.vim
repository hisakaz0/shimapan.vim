" Author:  hisakazu <cantabilehisa@gmail.com>
" License: MIT License

let s:save_cpo = &cpo
set cpo&vim


if exists("g:loaded_shimapan")
  finish
endif
let g:loaded_shimapan = 1

if !exists("g:shimapan_first_color")
  let g:shimapan_first_color  = "ctermfg=255 ctermbg=26"
endif

if !exists("g:shimapan_second_color")
  let g:shimapan_second_color = "cterm=reverse"
endif

execute "highlight ShimapanFirstColor  " . g:shimapan_first_color
execute "highlight ShimapanSecondColor " . g:shimapan_second_color

sign define ShimapanFirstSign  linehl=ShimapanFirstColor  text=>
sign define ShimapanSecondSign linehl=ShimapanSecondColor text=<

" shi-ma-pan-tsu
let s:shimapan_sign_id = 4082

" buflist has key-value pairs list.
"   keys<String>: buffer number
"   value<Integer>: last line
" When a pair is not stored in the list, new pair is created, and 'value'
" which is mean 'last line' is initialized by '1'.
let s:shimapan_bufline_dict = {}

" buflist has key-value pairs list.
"   keys<String>: buffer number
"   value<Integer>: name of original filetype
let s:shimapan_bufft_dict = {}


let s:shimapan_fname = ''
let s:shimapan_bufnr = 0

" ============================================================================
" function

function! s:ShimapanSet()
  let s:shimapan_fname = expand('%:p')
  let s:shimapan_bufnr = bufnr('%')
endfunction

function s:ShimapanGo()
  if s:shimapan_fname == '' | return | endif
  let s:shimapan_bufft_dict[s:shimapan_bufnr] = &filetype
  setlocal filetype=shimapan
endfunction

function! s:ShimapanUpdate()
  if &filetype != 'shimapan' | return | endif
  if s:shimapan_fname == '' | return | endif
  if has_key(s:shimapan_bufline_dict, s:shimapan_bufnr)
    let l:i = s:shimapan_bufline_dict[s:shimapan_bufnr]
  else
    let l:i = 1
  endif
  let l:lim = line('$')
  while l:i <= lim
    if l:i%2 == 0
      let l:name = "ShimapanFirstSign"
    else
      let l:name = "ShimapanSecondSign"
    endif
    execute printf(
          \"sign place %d line=%d name=%s file=%s",
          \ s:shimapan_sign_id, l:i, l:name, s:shimapan_fname)
    let i += 1
  endwhile
  let s:shimapan_bufline_dict[s:shimapan_bufnr] = l:i
endfunction

function! s:ShimapanBye()
  if &filetype != 'shimapan' | return | endif
  if s:shimapan_fname == '' | return | endif
  let l:i = 1
  let l:lim = line('$')
  while l:i <= l:lim
    execute printf("sign unplace %d file=%s",
          \ s:shimapan_sign_id, s:shimapan_fname)
    let l:i += 1
  endwhile
  let &filetype= s:shimapan_bufft_dict[s:shimapan_bufnr]
  call remove(s:shimapan_bufft_dict, s:shimapan_bufnr)
  call remove(s:shimapan_bufline_dict, s:shimapan_bufnr)
endfunction

" ============================================================================
" autocmd
autocmd Filetype shimapan call <SID>ShimapanUpdate()
autocmd TextChanged *     call <SID>ShimapanUpdate()
autocmd TextChangedI *    call <SID>ShimapanUpdate()
autocmd BufEnter *        call <SID>ShimapanSet()
" autocmd BufWritePost *    call <SID>ShimapanSet()


" ============================================================================
" command
command! ShimapanGo  call <SID>ShimapanGo()
command! ShimapanBye call <SID>ShimapanBye()


let &cpo = s:save_cpo
unlet s:save_cpo
