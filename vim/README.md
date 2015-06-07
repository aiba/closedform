
# vim-closedform

Vim plugin to automatically close open lisp forms.  I wrote this for editing
clojure code.

For example, if you type "({[", then call AppendClosingFormSymbol 3
times, it will insert "]", "}", and ")" in order.

There's also AppendAllClosingFormSymbols which will close all open
forms before the cursor.  Typing "({[" then calling
AppendAllClosingFormSymbols will insert "]})" at the cursor position.

I map this to M-; and M-: in both modes:

```vim
imap <M-;> <Esc>:AppendClosingFormSymbol<CR>a
nmap <M-;> <Esc>:AppendClosingFormSymbol<CR>
imap <M-:> <Esc>:AppendAllClosingFormSymbols<CR>a
nmap <M-:> <Esc>:AppendAllClosingFormSymbols<CR>
```


