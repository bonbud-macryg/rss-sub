::
::  read an atom feed and output new entries
::
/-  spider, *rss-atom
::  /+  *strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
!!
::|=  strand-input:spider
::
::  above is all boilerplate
::
::  ;<  t1=@da  bind:m  get-time
::  ;<  t2=@da  bind:m  get-time
::  ;<  output  bind:m  any-gate
::  (pure:m !>([t1 t2]))
::  (pure:m !>(final-output))
::
::?+    q.arg  [~ %fail %not-foo ~]
::    %foo
::  [~ %done arg]
::==
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
