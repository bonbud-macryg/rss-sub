::
::  rss-sub example app
::
/-  *example
/+  default-agent, dbug, *rss-sub
|%
+$  state  *
--
%-  agent:dbug
=|  state
^-  agent:gall
|_  =bowl:gall
+*  this  .
    card  card:agent:gall
    def   ~(. (default-agent this %.n) bowl)
::
++  on-init  on-init:def
++  on-save  on-save:def
++  on-load  on-load:def
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
    %sub-action
      =/  action  !<(ex-action vase)
      ?-  -.action
        %ex-add-feed
          `this
        %ex-del-feed
          `this
        %ex-refresh
          `this
        %ex-set-refresh
          `this
      ==  ::  end of -.action branches
  ==  ::  end of mark branches
::
++  on-watch  on-watch:def
  ::|=  =path
  ::^-  (quip card _this)
  ::`this
  ::  XX think about sub paths
++  on-peek  on-peek:def
  ::|=  =path
  ::^-  (unit (unit cage))
  ::  XX think about scry paths
++  on-arvo  on-arvo:def
  ::  XX accept refresh timers from behn
++  on-agent  on-agent:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
