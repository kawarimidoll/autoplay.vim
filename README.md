# autoplay.vim

Operate Vim automatically 🛼

https://github.com/kawarimidoll/autoplay.vim/assets/8146876/bb246db0-8812-4183-ac04-4b429288c7d9

## example

```vim
call autoplay#reserve(
    \ 'wait': 40,
    \ 'spell_out': 1,
    \ 'scripts': [
    \   "iHello world!\<esc>",
    \ ],
    \ })

nnoremap # <cmd>call autoplay#run()<cr>
```
