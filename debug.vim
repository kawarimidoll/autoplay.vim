execute $"set runtimepath+={expand('<script>:p:h')}"

call autoplay#reserve({
      \ 'wait': 40,
      \ 'spell_out': 1,
      \ 'scripts': [
      \   "\<c-l>iAutoplay start!\<cr>",
      \   "This plugin will operate Vim automatically.\<cr>",
      \   "You can use any commands in Vim!\<cr>",
      \   "For example, open help window :)\<esc>",
      \   {'wait': 1500},
      \   {'exec': 'h index'},
      \   {'exec': 'wincmd w'},
      \   {'wait': 700},
      \   "\<c-l>Go...Or change window size ;)\<esc>",
      \   {'wait': 100},
      \   {'exec': 'resize +1'},
      \   {'wait': 100},
      \   {'exec': 'resize +1'},
      \   {'wait': 100},
      \   {'exec': 'resize +1'},
      \   "\<c-l>GoIt looks cool, right?\<esc>",
      \   {'wait': 700},
      \   {'exec': 'only!'},
      \   {'wait': 700},
      \   "oIt will be useful for making Demo.\<esc>",
      \ ],
      \ })

call autoplay#reserve({
      \ 'wait': 60,
      \ 'spell_out': 1,
      \ 'remap': v:false,
      \ 'key': 'demo',
      \ 'scripts': [
      \   ":call autoplay#run()",
      \ ],
      \ })
      " \   {'wait': 300},
      " \   "\<cr>",

" DO NOT run autoplay in autoplay

nnoremap # <cmd>call autoplay#run('demo')<cr>
