::
::  rss-sub example app
::
/+  default-agent, dbug, *rss-sub
|%
+$  state
  $:  =rss-state
      =rss-refresh
  ==
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
  ::  XX start refresh timer on init
++  on-save  on-save:def
++  on-load  on-load:def
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
    %rss-sub
      =/  action  !<(rss-sub-action vase)
      ?-  -.action
        ::  XX could remove "rss" from these action types,
        ::     since we're routing on the wire
        %add-rss-feed
          :-  ~
          %=  this
            rss-state  (add-rss-feed link.action rss-state)
          ==
        %del-rss-feed
          :-  ~
          %=  this
            rss-state  (~(del by rss-state) link.action)
          ==
        %rss-refresh-now
          :-  ~
          %=  this
            rss-state  (rss-refresh-now links.action)
          ==
        %set-rss-refresh
        ::  XX add logic here
        ::       need to cancel current timer
        ::       need to add new timer
        ::       needs to only cancel the timer for this app, not others
          :-  ~  this
      ==  ::  end of -.action branches
  ==  ::  end of mark branches
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  `this
  ::
  ::  XX "subscribe to updates for this url" path
  ::  XX "subscribe to updates for all urls" path
::
++  on-peek  on-peek:def
  ::|=  =path
  ::^-  (unit (unit cage))
  ::
  ::  XX "scry urls" path
  ::  XX "scry refresh time" path
  ::  XX "scry last update at url" path
  ::  XX "scry rss-feed at url" path
  ::  XX "scry items/entries at url" path
++  on-arvo  on-arvo:def
  ::  XX accept refresh timers from behn
++  on-agent  on-agent:def
  ::  XX handle responses from rss/atom threads
  ::  XX handle facts from rss/atom threads
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
