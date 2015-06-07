if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

"-------------------------------------------------------------------------------
python << EOF
import vim

CHARPAIRS = ["()", "[]", "{}"];

def char_pair(c):
  for p in CHARPAIRS:
    if p[0]==c: return p[1]
    if p[1]==c: return p[0]
  return None

def is_opener(c):
  return (0 < len([x for x in CHARPAIRS if x[0]==c]))

def is_closer(c):
  return (0 < len([x for x in CHARPAIRS if x[1]==c]))

def cursor():
  (r,c) = vim.current.window.cursor
  return (r-1,c) # 0-based line

def append_char(c):
  (cline,ccol) = cursor()
  s = vim.current.buffer[cline]
  vim.current.buffer[cline] = s[:ccol+1] + c + s[ccol+1:]
  vim.current.window.cursor = (cline+1,ccol+1)

def buffer_until_cursor():
  buf = vim.current.buffer
  (cline, ccol) = vim.current.window.cursor
  cline -= 1 # make 0-based
  return ("\n".join(buf[0:cline]) + "\n" + buf[cline][0:ccol+1] + "\n")

def form_stack():
  s = buffer_until_cursor()
  i=0
  in_str=False
  stack = []
  while (i != -1) and (i < len(s)):
    c=s[i]
    if c=='\\': i += 2; continue
    if c=='"': in_str = not in_str; i += 1; continue
    if not in_str:
      if c==';':
        i = s.find('\n', i) # skip to end of line
        continue
      if is_opener(c): stack.append(c)
      if is_closer(c) and (len(stack) > 0) and (c == char_pair(stack[-1])):
        stack.pop()
    i += 1
    continue
  return stack

EOF

"-------------------------------------------------------------------------------
function! AppendClosingFormSymbol()
python << EOF
stack=form_stack()
if len(stack) > 0:
  append_char(char_pair(stack[-1]))
else:
  print "No open forms."
EOF
endfunction

"-------------------------------------------------------------------------------
function! AppendAllClosingFormSymbols()
python << EOF
stack=form_stack()
while len(stack) > 0:
  append_char(char_pair(stack.pop()))
EOF
endfunction

"-------------------------------------------------------------------------------
command! -nargs=0 AppendClosingFormSymbol call AppendClosingFormSymbol()
command! -nargs=0 AppendAllClosingFormSymbols call AppendAllClosingFormSymbols()

