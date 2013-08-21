vim-subbed
==========

A simple substitute command inspired by easyclip.

Overview
--------

This plugin remaps the `-` and `_` keys to perform a substitution. `-`
accepts motions and will replace text with the contents of the yank buffer.
`_` substitutes till the end of the current line, behaving similarly to `D`,
or `Y`.

Installation
------------

I recommend using either Vundle or NeoBundle to install this plugin.

Example
--------

If the cursor is represented by `^`, and `inquisitive` is in the yank
buffer then pressing `-w` will change the following text

```
and the ^hairy snail slimed ...
```

into

```
and the inquisitive^ snail slimed ... 
```

Why?
----

I got tired of substituting using `c<motion>^R"` or something similar. Subbed
changes this into `-<motion>` saving a few keystrokes and the finger curling
associated with reaching for the control key.

