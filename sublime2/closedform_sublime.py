import sublime
import sublime_plugin  

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

def form_stack(s):
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

# Sublime-specific stuff ------------------------------------

def get_cursor(view):
  # assume selection is just cursor, not a block of text.
  for region in view.sel():
    if region.empty():
      return region.begin()
      return buf
  return None

def parse_stack(view):
  i = get_cursor(view)
  if i:
    buf = view.substr(sublime.Region(0,i))
    if buf:
      return form_stack(buf)      
  return []

def insert(view, edit, c):
  i = get_cursor(view)
  view.insert(edit, i, c)

class AppendClosingFormSymbolCommand(sublime_plugin.TextCommand):  
  def run(self, edit):
    stack = parse_stack(self.view)
    if len(stack) > 0:
      c = char_pair(stack[-1])
      insert(self.view, edit, c)

class AppendAllClosingFormSymbolsCommand(sublime_plugin.TextCommand):  
  def run(self, edit):
    stack = parse_stack(self.view)
    while len(stack) > 0:
      insert(self.view, edit, char_pair(stack.pop()))
