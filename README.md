# autoplay.vim

Operate Vim automatically 🛼

https://github.com/kawarimidoll/autoplay.vim/assets/8146876/bb246db0-8812-4183-ac04-4b429288c7d9

## example

```vim
call autoplay#reserve({
    \ 'wait': 40,
    \ 'spell_out': v:true,
    \ 'logger': {item -> execute('echomsg ' .. string(item), '')},
    \ 'scripts': [
    \   "iHello world!\<esc>",
    \ ],
    \ })

nnoremap # <cmd>call autoplay#run()<cr>
```

<details>
<summary>Neovim Lua</summary>

```lua
vim.fn['autoplay#reserve']({
  wait = 40,
  spell_out = true,
  logger = function(item)
    vim.notify(tostring(item))
  end,
  scripts = {
    "iHello world!\\<esc>",
  },
})

vim.keymap.set('n', '#', function() vim.fn['autoplay#run']() end)
```
</details>

```vim
" Multiple presses example
let g:autoplay_count = 0
let s:scripts_list = [
      \ ["iFirst line!\<esc>"],
      \ ["oSecond Line?\<esc>"],
      \ ["oThird line :)\<esc>"],
      \ ]

" Reserve all scripts with numbered names
for i in range(len(s:scripts_list))
  call autoplay#reserve({
        \ 'name': 'phase_' .. (i + 1),
        \ 'wait': 40,
        \ 'spell_out': v:true,
        \ 'scripts': s:scripts_list[i],
        \ })
endfor

function! RunAutoplayByCount() abort
  let g:autoplay_count = v:count > 0 ? v:count : (g:autoplay_count + 1)
  if g:autoplay_count > len(s:scripts_list)
    echo 'Autoplay finished!'
    return
  endif
  let phase_name = 'phase_' .. g:autoplay_count
  call autoplay#run(phase_name)
  echo phase_name
endfunction

nnoremap # <cmd>call RunAutoplayByCount()<cr>
```

```vim
" Full-featured example
augroup autoplay-demo
  autocmd!
  autocmd User autoplay_start echomsg 'autoplay start!'
  autocmd User autoplay_finish echomsg 'autoplay finish!'
augroup END

call autoplay#reserve({
    \ 'wait': 50,
    \ 'spell_out': v:true,
    \ 'remap': v:false,
    \ 'logger': {item, script -> writefile([string(script) .. ' ' .. item], './autoplay.log', 'a')},
    \ 'scripts': [
    \   'iThis line is displayed one character ',
    \   { 'text':"at a time!\<esc>", 'spell_out': v:true },
    \   { 'wait': 800 },
    \   { 'text':"oThis line is displayed all at once!\<cr>", 'wait': 800 },
    \   'Today: ',
    \   { 'expr': 'strftime', 'args': ['%Y/%m/%d'] , 'wait': 800 },
    \   "\<cr>Normal commands also work.\<esc>",
    \   { 'exec': 'normal! v3k5>' },
    \   'ODelay time ...',
    \   { 'wait': 800 },
    \   { 'text': repeat("\<bs>", 3) .. 'can also ...', 'wait': 100, 'spell_out': v:true },
    \   { 'wait': 800 },
    \   { 'text': repeat("\<bs>", 3) .. "be modified.\<cr>", 'wait': 200, 'spell_out': v:true },
    \   { 'text': "This line will be changed by `setline`.\<esc>", 'wait': 1000 },
    \   { 'call': 'setline', 'args': ['.', '3'], 'wait': 1000 },
    \   { 'call': 'setline', 'args': ['.', '2'], 'wait': 1000 },
    \   { 'call': 'setline', 'args': ['.', '1'], 'wait': 1000 },
    \   { 'call': 'setline', 'args': ['.', 'done!'] }
    \ ],
    \ })

call autoplay#run()
```
