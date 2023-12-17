::
::  rss-sub example app
::
/+  default-agent, dbug, *rss-sub
|%
+$  state
  $:  =maximum
      =refresh
      =feed-state
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
        %add-feed
          :-  ~
          %=  this
            feed-state  (~(put by feed-state) link.action [now.bowl ~])
          ==
        %del-feed
          :-  ~
          %=  this
            feed-state  (~(del by feed-state) link.action)
          ==
        %refresh-now
          :_  this
          ?~  feed-state
            ~|  "{<q.byk.bowl>}: no saved feeds to update"
            !!
          %^    make-refresh-cards
              links.action
            q.byk.bowl
          feed-state
        ::
        %set-refresh
        ::  XX add logic here
        ::       need to cancel current timer
        ::       need to add new timer
        ::       needs to only cancel the timer for this app, not others
          `this
        ::
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
::
++  on-arvo  on-arvo:def
  ::  |=  [=(pole knot) =sign-arvo]
  ::  ^-  (quip card _this)
  ::
  ::  XX accept refresh timers from behn
  ::
  ::  XX handle facts from item and entry threads
  ::       cards: update +on-watch wires
  ::       this:  update feed-state
::
++  on-agent  on-agent:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
