let s:is_dict = {item -> type(item) == v:t_dict}
let s:is_list = {item -> type(item) == v:t_list}
let s:is_string = {item -> type(item) == v:t_string}
let s:has_key = {item, key -> s:is_dict(item) && has_key(item, key)}
let s:get = {item, key, default -> s:has_key(item, key) ? item[key] : default}
let s:ensure_list = {item -> s:is_list(item) ? item : [item]}

function s:spell_out(item) abort
  if !s:is_string(a:item) || strcharlen(a:item) < 2
    return a:item
  endif

  " to split special characters with code <80>k? like <bs>
  let chars = split(a:item, '\zs')
  let prefix = split("\<bs>", '\zs')[0:1]->join('')
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

let s:recursive_feed_list = []
let s:fmt = "%s\<cmd>call timer_start(%s,{->" .. expand('<SID>') .. "autoplay()})\<cr>"
function s:autoplay() abort
  if empty(s:recursive_feed_list)
    return
  endif
  let proc = remove(s:recursive_feed_list, 0)
  let feed = !s:is_dict(proc) ? proc
        \ : has_key(proc, 'call') ? [call(proc.call, get(proc, 'args', [])), ''][1]
        \ : has_key(proc, 'expr') ? call(proc.expr, get(proc, 'args', []))
        \ : has_key(proc, 'eval') ? eval(proc.eval)
        \ : has_key(proc, 'exec') ? [execute(proc.exec, ''), ''][1]
        \ : has_key(proc, 'text') ? proc.text
        \ : ''
  let wait = s:get(proc, 'wait', s:wait)

  if s:is_list(feed)
    if s:spell_out
      call map(feed, {_,v -> s:spell_out(v) })
    endif
    call extend(s:recursive_feed_list, feed, 0)
    return s:autoplay()
  endif

  call call(s:logger, [feed])

  call feedkeys(printf(s:fmt, feed, wait), s:flag)
endfunction

function autoplay#run(name = '') abort
  let config = s:configs[a:name]
  let s:wait = get(config, 'wait', 0)
  let s:spell_out = get(config, 'spell_out', v:false)
  let s:flag = get(config, 'remap', v:true) ? 'm' : 'n'
  let s:logger = get(config, 'logger', {_->0})
  let scripts = s:ensure_list(config.scripts)->copy()
  if empty(scripts)
    return
  endif
  if s:spell_out
    call map(scripts, {_,v -> s:spell_out(v) })
    call flatten(scripts, 1)
  endif
  let s:recursive_feed_list = scripts
  call s:autoplay()
endfunction

let s:configs = {}
function autoplay#reserve(config) abort
  let s:configs[get(a:config, 'name', '')] = a:config
endfunction
