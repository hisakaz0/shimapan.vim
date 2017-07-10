" Author:  hisakazu <cantabilehisa@gmail.com>
" License: MIT License

let s:save_cpo = &cpo
set cpo&vim


if exists("g:loaded_shimapan")
  finish
endif
let g:loaded_shimapan = 1

if (&t_Co < 256)
  finish
endif

if !exists("g:shimapan_first_color")
  let g:shimapan_first_color  = "ctermfg=255 ctermbg=26"
endif

if !exists("g:shimapan_second_color")
  let g:shimapan_second_color = "cterm=reverse"
endif

if !exists("g:shimapan_first_texticon")
  let g:shimapan_first_texticon = ">"
endif

if !exists("g:shimapan_second_texticon")
  let g:shimapan_second_texticon = "<"
endif


" NOTE: shi-ma-pan-tsu
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

function! s:ShimapanUpdateAppearance()
  execute printf("highlight ShimapanFirstColor %s", g:shimapan_first_color)
  execute printf("highlight ShimapanSecondColor %s", g:shimapan_second_color)
  execute printf("sign define ShimapanFirstSign linehl=ShimapanFirstColor text=%s",
        \ g:shimapan_first_texticon)
  execute printf("sign define ShimapanSecondSign linehl=ShimapanSecondColor text=%s",
        \ g:shimapan_second_texticon)
endfunction

" This function is invoked at BufReadPost event to prevent that vim tries to
" change from 'shimapan' to original filetype of buffer.
function s:ShimapanAlready()
  let l:bufnr = bufnr('%')
  if has_key(s:shimapan_bufft_dict, l:bufnr)
    setlocal filetype=shimapan
  endif
endfunction

function s:ShimapanGo()
  " if s:shimapan_fname == '' | return | endif
  let l:bufnr = bufnr('%')
  if !has_key(s:shimapan_bufft_dict, l:bufnr)
    let s:shimapan_bufft_dict[l:bufnr] = &filetype
    setlocal filetype=shimapan
  endif
endfunction

function! s:ShimapanUpdate()
  if &filetype != 'shimapan' | return | endif
  " if s:shimapan_fname == '' | return | endif
  if has_key(s:shimapan_bufline_dict, s:shimapan_bufnr)
    let l:i = s:shimapan_bufline_dict[s:shimapan_bufnr]
  else
    let l:i = 1
  endif
  let l:lim = line('$')
  " TODO: if-elseの実行回数を減らす書き方に変更
  while l:i <= lim
    if l:i%2 == 0
      let l:name = "ShimapanFirstSign"
    else
      let l:name = "ShimapanSecondSign"
    endif
    execute printf(
          \"sign place %d line=%d name=%s buffer=%d",
          \ s:shimapan_sign_id, l:i, l:name, s:shimapan_bufnr)
    let i += 1
  endwhile
  let s:shimapan_bufline_dict[s:shimapan_bufnr] = l:i
endfunction

function! s:ShimapanBye()
  if &filetype != 'shimapan' | return | endif
  " if s:shimapan_fname == '' | return | endif
  let l:bufnr = bufnr('%')
  let l:i = 1
  let l:lim = line('$')
  while l:i <= l:lim
    execute printf("sign unplace %d buffer=%d",
          \ s:shimapan_sign_id, l:bufnr)
    let l:i += 1
  endwhile
  let &filetype = s:shimapan_bufft_dict[l:bufnr]
  call remove(s:shimapan_bufft_dict, l:bufnr)
  call remove(s:shimapan_bufline_dict, l:bufnr)
endfunction

" ============================================================================
" autocmd

" To update sign placement
autocmd Filetype shimapan call <SID>ShimapanUpdate()
autocmd TextChanged *     call <SID>ShimapanUpdate()
autocmd TextChangedI *    call <SID>ShimapanUpdate()

" To prevent that vim set original filetype when the target buffer is re-edit.
autocmd BufReadPost *     call <SID>ShimapanAlready()


" ============================================================================
" command
command! ShimapanGo     call <SID>ShimapanGo()
command! ShimapanBye    call <SID>ShimapanBye()
command! ShimapanUpdate call <SID>ShimapanUpdateAppearance()

ShimapanUpdate

let &cpo = s:save_cpo
unlet s:save_cpo
