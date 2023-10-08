::
:: read an atom entry and send out a %fact
::
/-  spider, *rss-atom
/+  *strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::
::  parse the item
::  typecheck and crash on failure
::  send card to example.hoon
::  paths is a one-item list containing the example.hoon wire
::
:: =/  =card:agent:gall
::   [%pass /poke %agent dock %poke cage]
::  ;<  ~  bind:m  (poke card)
::
!!
