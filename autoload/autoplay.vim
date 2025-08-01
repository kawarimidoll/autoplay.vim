let s:is_dict = {item -> type(item) == v:t_dict}
let s:is_list = {item -> type(item) == v:t_list}
let s:is_string = {item -> type(item) == v:t_string}
let s:has_key = {item, key -> s:is_dict(item) && has_key(item, key)}
let s:get = {item, key, default -> s:has_key(item, key) ? item[key] : default}
let s:ensure_list = {item -> s:is_list(item) ? item : [item]}

function s:echoerr(...) abort
  echohl ErrorMsg
  for str in a:000
    echomsg '[autoplay]' str
  endfor
  echohl NONE
endfunction

" almost same as split(item, '\zs')
" but handle special characters with code <80>k? like <bs>
function s:str_split(item) abort
  if !s:is_string(a:item) || strcharlen(a:item) < 2
    return a:item
  endif

  let chars = split(a:item, '\zs')
  let prefix = "\<bs>"[0:1]
  let result = []
  let i = 0
  while i < len(chars)
    if chars[i : i+1]->join('') ==# prefix
      call add(result, chars[i : i+2]->join(''))
      let i += 2
    else
      call add(result, chars[i])
    endif
    let i += 1
  endwhile
  return result
endfunction

function s:spell_out_list(list) abort
  let list = a:list
  call map(list, {_,v -> s:str_split(v) })
  call flatten(list, 1)
  return list
endfunction

function s:do_user(event_name) abort
  if exists('#User#autoplay_' .. a:event_name)
    execute 'doautocmd <nomodeline> User autoplay_' .. a:event_name
  endif
endfunction

let s:recursive_feed_list = []
let s:fmt = "%s\<cmd>call timer_start(%s,{->" .. expand('<SID>') .. "autoplay()})\<cr>"
function s:autoplay() abort
  if empty(s:recursive_feed_list)
    return s:do_user('finish')
  endif
  let proc = remove(s:recursive_feed_list, 0)
  if s:has_key(proc, 'break') && call(proc.break, [])
    return s:do_user('break')
  endif

  try
    let feed = !s:is_dict(proc) ? proc
          \ : has_key(proc, 'call') ? [call(proc.call, get(proc, 'args', [])), ''][1]
          \ : has_key(proc, 'expr') ? call(proc.expr, get(proc, 'args', []))
          \ : has_key(proc, 'eval') ? eval(proc.eval)
          \ : has_key(proc, 'exec') ? [execute(proc.exec, ''), ''][1]
          \ : has_key(proc, 'text') ? proc.text
          \ : ''
  catch
    call s:echoerr('Error in script execution:', v:exception, 'Script:', string(proc))
    let feed = ''
  endtry
  let wait = s:get(proc, 'wait', s:wait)

  if s:is_list(feed) || s:is_dict(feed)
        \ || (s:is_string(feed) && s:has_key(proc, 'spell_out'))
    let feed = s:ensure_list(feed)
    if s:get(proc, 'spell_out', s:spell_out)
      let feed = s:spell_out_list(feed)
    endif

    " ensure dict & apply wait
    call map(feed, {_, v -> s:is_string(v) ? {'text': v} : v })
    call map(feed, {_, v -> s:is_dict(v) ? extend({'wait': wait}, v) : v })

    call extend(s:recursive_feed_list, feed, 0)
    " use timer to avoid maxfuncdepth
    return timer_start(0, {->s:autoplay()})
  endif

  call call(s:logger, [feed, proc])

  let flag = s:get(proc, 'remap', s:remap) ? 'm' : 'n'
  call feedkeys(printf(s:fmt, feed, wait), flag)
endfunction

function autoplay#run(name = '') abort
  if !has_key(s:configs, a:name)
    call s:echoerr('Config not found:', empty(a:name) ? '(default)' : a:name)
    return
  endif
  let config = s:configs[a:name]
  let s:wait = get(config, 'wait', 0)
  let s:spell_out = get(config, 'spell_out', v:false)
  let s:remap = get(config, 'remap', v:true)
  let s:logger = get(config, 'logger', {_->0})
  let scripts = s:ensure_list(config.scripts)->copy()
  if empty(scripts)
    return
  endif
  if s:spell_out
    let scripts = s:spell_out_list(scripts)
  endif
  let s:recursive_feed_list = scripts
  call s:do_user('start')
  call s:autoplay()
endfunction

let s:configs = {}
function autoplay#reserve(config) abort
  let s:configs[get(a:config, 'name', '')] = a:config
endfunction
