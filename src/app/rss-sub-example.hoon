::
::  rss-sub example app
::
/+  default-agent, dbug, *rss-sub
|%
+$  app-state
  $:  =maximum
      =refresh
      =feed-state
  ==
--
%-  agent:dbug
=|  app-state
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    card  card:agent:gall
    def   ~(. (default-agent this %.n) bowl)
::
++  on-init
  ^-  (quip card _this)
  ::  XX start refresh timer on init
  :-  ~
  %=  this
    refresh  ~m15
    maximum  `1.000
  ==
++  on-save
  !>(state)
++  on-load
  |=  =vase
  ^-  (quip card _this)
  =/  saved-state  !<(app-state vase)
  `this(state saved-state)
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
    %rss-sub
      =/  action  !<(rss-sub-action vase)
      ?-  -.action
        %add-feed
          ?~  (de-purl:html link.action)
            ::  XX should probably acccept 'example.com'
            ::     as valid input and prepend http or https
            ::     to make it a valid URL
            ~|  "{<q.byk.bowl>}: invalid URL {<link.action>}"
            !!
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
++  on-arvo
  ::
  ::  XX accept refresh timers from behn
  ::
  ::  XX handle facts from item and entry threads
  ::       cards: update +on-watch wires
  ::       this:  update feed-state
  ::
  |=  [=(pole knot) =sign-arvo]
  ^-  (quip card _this)
  ?+  pole  (on-arvo:def `wire`pole sign-arvo)
    [%rss-sub %update =link ~]
      ?>  ?=([%khan %arow *] sign-arvo)
      ::  XX ugly
      =*  link=link  (slav %t link.pole)
      ::
      %-  (slog [[%leaf "sign-arvo: {<sign-arvo>}"] ~])
      %-  (slog [[%leaf "received updated from khan; terminating"] ~])
      `this
  ==  ::  end of pole branches
::
++  on-agent  on-agent:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
