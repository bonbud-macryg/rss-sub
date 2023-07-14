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
++  on-watch
  |=  =path
  ^-  (quip card _this)
  `this
  ::  XX "subscribe to items/entries" path
::
++  on-peek  on-peek:def
  ::|=  =path
  ::^-  (unit (unit cage))
  ::
  ::  XX "scry feeds" path
  ::  XX "scry refresh time" path
  ::  XX "scry rss-channel at url" path
  ::  XX "scry rss entries at url" path
++  on-arvo  on-arvo:def
  ::  XX accept refresh timers from behn
++  on-agent  on-agent:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
