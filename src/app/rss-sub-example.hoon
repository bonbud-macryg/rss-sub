::
::  rss-sub example app
::
/-  ra=rss-atom
/+  default-agent, dbug, rs=rss-sub
|%
+$  app-state
  $:  =maximum:rs
      =refresh:rs
      =feed-state:rs
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
      =/  action  !<(rss-sub-action:rs vase)
      ?-  -.action
        %add-feed
          ?~  (de-purl:html link.action)
            ~|  "{<q.byk.bowl>}: invalid URL {<link.action>}"
            !!
          :_  this
          :~  :*  %pass
                  ::  XX pass -rss-atom output to +on-agent,
                  ::     then in +on-agent pass output on
                  ::     to either -item or -entry
                  /rss-sub/update/rss-atom/(scot %t link.action)
                  %arvo
                  %k
                  %fard
                  q.byk.bowl
                  %rss-atom
                  %noun
                  !>  ^-  (pair time link:ra)
                  [now.bowl link.action]
              ==
          ==
          ::  :-  ~
          ::  %=  this
          ::    feed-state  (~(put by feed-state) link.action [now.bowl ~])
          ::  ==
        %del-feed
          :-  ~
          %=  this
            feed-state  (~(del by feed-state) link.action)
          ==
        ::
        ::  XX should this only take one (unit link)?
        ::     would simplify /lib; just split up feeds
        ::     on the client side and refresh each one
        %refresh-now
          :_  this
          ?~  feed-state
            ~|  "{<q.byk.bowl>}: no saved feeds to update"
            !!
          ::  XX check if feeds are all in feed-state; error if not
          %^    make-refresh-cards:rs
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
    ::
    ::  update rss-atom with new metadata and pass output
    ::  onto either -item or -entry
    [%rss-sub %update %rss-atom =link:ra ~]
      ?>  ?=([%khan %arow *] sign-arvo)
      ?.  ?=(%.y -.p.sign-arvo)
        ~&  >>>  "{<dap.bowl>}: failed to parse feed at {<link.pole>}"
        ~&  >>>  p.p.sign-arvo
        `this
      ::  XX should be [rss/atom rss-channel-element/atom-feed-element marl]
      =/  response  !<([?(%rss %atom) * marl] q.p.p.sign-arvo)
      ?-  -.response
      ::
          %rss
        ~&  >  "{<dap.bowl>}: parsed rss channel {<link.pole>}"
        `this
      ::
          %atom
        ~&  >  "{<dap.bowl>}: parsed atom feed {<link.pole>}"
        `this
      ==
    ::
    ::  update rss channel with new item
    [%rss-sub %update %rss-item =link:ra ~]
      ?>  ?=([%khan %arow *] sign-arvo)
      ?.  -.p.sign-arvo
        ~&  >>>  "{<dap.bowl>}: invalid rss item from url {<link.pole>}"
        `this
      ::  XX add result to the relevant state
      ~&  >  "{<dap.bowl>}: postive result from thread"
      `this
    ::
    ::  update atom feed with new entry
    [%rss-sub %update %atom-entry =link:ra ~]
      ?>  ?=([%khan %arow *] sign-arvo)
      ?.  -.p.sign-arvo
         ~&  >>>  "{<dap.bowl>}: invalid atom entry from url {<link.pole>}"
         `this
      ::  XX add result to the relevant state
      ~&  >  "{<dap.bowl>}: postive result from thread"
      `this
  ==  ::  end of pole branches
::
++  on-agent  on-agent:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
