function Doc_fmt() abort
  if &filetype != 'help'
    setfiletype help
  endif

  let save_cursor = getcurpos()

  " 行末空白、ファイル末空行を削除
  silent %s/\s\+$\|\n\+\%$//e

  " 見出しタグ位置を調整
  silent %s/\v^(.*\S)\s*(\*\S+\*)$/\=submatch(1) .. repeat(' ', max([1, 78-len(submatch(1) .. submatch(2))])) .. submatch(2)/e

  " インデント
  let newline_pat = '^\S.*[*]$'
  let skip_pat = '[-~=<>]$\|' .. newline_pat
  let skip_hls = ['helpExample']
  let blanks = 4
  let i = 7
  while i < line('$')
    call cursor(i, 1)
    let line = getline(i)
    if !empty(line) && line !~ skip_pat && index(skip_hls, synIDattr(synID(line('.'), col('.'), 0), 'name'))
      if line =~ '^\s*-'
        let blanks = 6
        call setline(i, substitute(' ' .. line, '^\s*', repeat(' ', blanks), ''))
        let blanks = 8
      else
        call setline(i, substitute(' ' .. line, '^\s*', repeat(' ', blanks), ''))
        normal! gql
      endif
    else
      let blanks = 4
      if line =~ newline_pat && line !~ '^\s*$'
        call append(i, '')
      endif
    endif
    let i += 1
  endwhile

  " 見出しタグ位置を調整
  silent %s/\v^\s*(\*\S+\*)$/\=repeat(' ', max([1, 78-len(submatch(1))])) .. submatch(1)/e

  " 連続空行を削除
  silent %s/^\n\zs\n\+//e

  call setpos('.', save_cursor)
endfunction
