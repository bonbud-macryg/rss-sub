::
:: read an rss item and send out a %fact
::
/-  spider, *rss-atom
/+  *strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::
::  NOTE not using text parser anymore, some logic still applies
::
::  send card to example.hoon
::  paths is a one-item list containing the example.hoon wire
::
::  =/  =card:agent:gall
::    [%pass /poke %agent dock %poke cage]
::  ;<  ~  bind:m  (poke card)
::
::  look at item cord
::  pose with one of title, link, pubDate, etc.
::  MVP: title, date, link
::  in theory looks kind of like this? with title, link, desc., other elems
::  (scan "abcdef" (star ;~(pose (just 'a') (just 'c') (just 'b') (jest 'def'))))
::  might have to use +knee to parse arbitraty length strings
::  XX refamiliarise with the tafjest stuff from hoon-rss
::
!!
