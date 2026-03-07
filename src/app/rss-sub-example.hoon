::
::  rss-sub example app
::
/-  ra=rss-atom
/+  default-agent, dbug, verb, rs=rss-sub
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
%+  verb  &
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
          ::  XX pass -rss-atom output to +on-agent,
          ::     then in +on-agent pass output on
          ::     to either -item or -entry
          :~  :*  %pass  /rss-sub/update/feed/(scot %t link.action)
                  %arvo  %k
                  %fard  q.byk.bowl
                  %rss-atom  [%noun !>([now.bowl link.action])]
              ==
          ==
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
    [%rss-sub %update %feed =link:ra ~]
      ?>  ?=([%khan %arow *] sign-arvo)
      ?.  ?=(%& -.p.sign-arvo)
        ~&  >>>  %on-arvo
        ~&  >>>  "{<dap.bowl>}: failed to parse rss channel or atom feed at {<link.pole>}"
        `this
      ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
      =/  [%khan %arow %.y %noun =vase]  sign-arvo
      ::  XX should be [rss/atom rss-channel-element/atom-feed-element marl]
      =/  res  !<([?(%rss %atom) feed=* items=(list manx)] vase)
      ?-  -.res
      ::
          %rss
        ~&  >  %on-arvo
        ~&  >  "{<dap.bowl>}: parsed rss channel {<link.pole>}"
        :-  %+  turn
              items.res
            |=  =manx
            ^-  card
            :*  %pass  /rss-sub/update/item/[link.pole]
                %arvo  %k
                %fard  q.byk.bowl
                %rss-item  [%noun !>(manx)]
            ==
        %=  this
           feed-state  %-  ~(put by feed-state)
                       :-  (slav %t link.pole)
                       :-  now.bowl
                       %-  some
                       ^-  feed:rs
                       :-  %.y
                       ^-  channel:rss:ra
                       ::  XX what goes in headers?
                       [%channel ~ ((list channel-element:rss:ra) feed.res) ~]
        ==
      ::
          %atom
        ~&  >  %on-arvo
        ~&  >  "{<dap.bowl>}: parsed atom feed {<link.pole>}"
        :-  %+  turn
              items.res
            |=  =manx
            ^-  card
            :*  %pass  /rss-sub/update/atom-entry/[link.pole]
                %arvo  %k
                %fard  q.byk.bowl
                %atom-entry  [%noun !>(manx)]
            ==
        %=  this
           feed-state  %-  ~(put by feed-state)
                       :-  (slav %t link.pole)
                       :-  now.bowl
                       %-  some
                       ^-  feed:rs
                       :-  %.n
                       ^-  feed:atom:ra
                       ::  XX what goes in headers?
                       [%feed ~ ((list feed-element:atom:ra) feed.res) ~]
        ==
      ==
    ::
    ::  update rss channel with new item
    [%rss-sub %update %item =link:ra ~]
      ?>  ?=([%khan %arow *] sign-arvo)
      ?.  ?=(%& -.p.sign-arvo)
        ~&  >>>  %on-arvo
        ~&  >>>  "{<dap.bowl>}: invalid rss item from url {<link.pole>}"
        `this
      ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
      =/  [%khan %arow %.y %noun =vase]  sign-arvo
      =/  =item:rss:ra  !<(item:rss:ra vase)
      =/  feed  (~(get by feed-state) (slav %t link.pole))
      ?~  feed
        `this
      ?<  ?=(~ q.u.feed)
      ?>  -.u.q.u.feed
      ?>  -.u.q.u.feed
      ?>  ?=([%channel *] +.u.q.u.feed)
      =/  =channel:rss:ra  +.u.q.u.feed
      :-  ~
      %=  this
        feed-state  %-  ~(put by feed-state)
                    :-  (slav %t link.pole)
                    :-  now.bowl
                    %-  some
                    ^-  feed:rs
                    :-  %.y
                    ^-  channel:rss:ra
                    %=  channel
                      items  :-(item items.channel)
                    ==
      ==
    ::
    ::  update atom feed with new entry
    [%rss-sub %update %atom-entry =link:ra ~]
      ?>  ?=([%khan %arow *] sign-arvo)
      ?.  ?=(%& -.p.sign-arvo)
        ~&  >>>  %on-arvo
        ~&  >>>  "{<dap.bowl>}: invalid atom entry from url {<link.pole>}"
        `this
      ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
      =/  [%khan %arow %.y %noun =vase]  sign-arvo
      =/  =entry:atom:ra  !<(entry:atom:ra vase)
      =/  feed  (~(get by feed-state) (slav %t link.pole))
      ?~  feed
        `this
      ?<  ?=(~ q.u.feed)
      ?:  -.u.q.u.feed
        `this
      ?>  ?=([%feed *] +.u.q.u.feed)
      =/  =feed:atom:ra  +.u.q.u.feed
      :-  ~
      %=  this
        feed-state  %-  ~(put by feed-state)
                    :-  (slav %t link.pole)
                    :-  now.bowl
                    %-  some
                    ^-  feed:rs
                    :-  %.n
                    ^-  feed:atom:ra
                    %=  feed
                      entries  :-(entry entries.feed)
                    ==
      ==
  ==  ::  end of pole branches
::
++  on-agent  on-agent:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
