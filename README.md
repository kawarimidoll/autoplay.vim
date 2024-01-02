# autoplay.vim

Operate Vim automatically 🛼

https://github.com/kawarimidoll/autoplay.vim/assets/8146876/bb246db0-8812-4183-ac04-4b429288c7d9

## example

```vim
call autoplay#reserve({
    \ 'wait': 40,
    \ 'spell_out': 1,
    \ 'scripts': [
    \   "iHello world!\<esc>",
    \ ],
    \ })

nnoremap # <cmd>call autoplay#run()<cr>
```

```vim
call autoplay#reserve({
    \ 'wait': 50,
    \ 'spell_out': 1,
    \ 'remap': v:false,
    \ 'scripts': [
    \   "iThis line is displayed one character at a time.\<esc>",
    \   { "wait": 800 },
    \   {'text':"oThis line is displayed at a time!\<cr>", "wait": 800},
    \   "Today: ",
    \   { "expr": "strftime", "args": ["%Y/%m/%d"] , "wait": 800},
    \   "\<cr>normal command also works.\<esc>",
    \   { "exec": 'normal! vip5>' },
    \   "ODelay time ...",
    \   { "wait": 800 },
    \   repeat("\<bs>", 3) .. "can also ...",
    \   { "wait": 800 },
    \   repeat("\<bs>", 3) .. "be modified.\<cr>",
    \   { 'text': "This line will be changed by `setline`.\<esc>", "wait": 1000 },
    \   { "call": "setline", "args": ['.', '3'], "wait": 1000 },
    \   { "call": "setline", "args": ['.', '2'], "wait": 1000 },
    \   { "call": "setline", "args": ['.', '1'], "wait": 1000 },
    \   { "call": "setline", "args": ['.', 'done!'] }
    \ ],
    \ })

call autoplay#run()
```
