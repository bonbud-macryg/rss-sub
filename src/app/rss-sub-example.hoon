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
  :_  %=  this
        refresh  ~m15
        maximum  `1.000
      ==
  :~  [%pass /rss-sub/timer %arvo %b %wait (add ~m15 now.bowl)]
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
        %refresh-now
          :_  this
          ?~  feed-state
            ~|  "{<q.byk.bowl>}: no saved feeds to update"
            !!
          %^    make-refresh-cards:rs
              link.action
            q.byk.bowl
          feed-state
        ::
        %set-refresh
          :_  this(refresh refresh.action)
          :~  [%pass /rss-sub/timer %arvo %b %rest (add refresh now.bowl)]
              [%pass /rss-sub/timer %arvo %b %wait (add refresh.action now.bowl)]
          ==
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
++  on-peek
  |=  =(pole knot)
  ^-  (unit (unit cage))
  ?+  pole  (on-peek:def `path`pole)
    ::
    ::  .^((list @t) %gx /=rss-sub-example=/urls/noun)
    ::  .^(json %gx /=rss-sub-example=/urls/json)
    ::  list all subscribed feed URLs
    [%x %urls ~]
      ``feed-urls+!>(~(tap in ~(key by feed-state)))
    ::
    ::  .^((unit @ud) %gx /=rss-sub-example=/maximum/noun)
    ::  .^(json %gx /=rss-sub-example=/maximum/json)
    ::  maximum items per feed
    [%x %maximum ~]
      ``feed-maximum+!>(maximum)
    ::
    ::  .^(@da %gx /=rss-sub-example=/feed/last-update/<url>/noun)
    ::  .^(json %gx /=rss-sub-example=/feed/last-update/<url>/json)
    ::  last-updated time for the feed at the given URL
    [%x %feed %last-update =link:ra ~]
      =/  entry  (~(get by feed-state) (slav %t link.pole))
      ?~  entry  [~ ~]
      ``feed-last-update+!>(-:u.entry)
    ::
    ::  .^(channel:rss:ra %gx /=rss-sub-example=/feed/<url>/noun)
    ::  .^(json %gx /=rss-sub-example=/feed/<url>/json)
    ::  the parsed RSS channel or Atom feed at the given URL
    [%x %feed =link:ra ~]
      =/  entry  (~(get by feed-state) (slav %t link.pole))
      ?~  entry  [~ ~]
      =/  [last=updated:rs cached=(unit feed:rs)]  u.entry
      ?~  cached  [~ ~]
      ?:  ?=(%& -.u.cached)
        ?>  ?=([%channel *] +.u.cached)
        =/  =channel:rss:ra  +.u.cached
        ``rss-channel+!>(channel)
      ?>  ?=([%feed *] +.u.cached)
      =/  =feed:atom:ra  +.u.cached
      ``atom-feed+!>(feed)
    ::
    ::  .^((set item:rss:ra) %gx /=rss-sub-example=/feed/<url>/items/noun)
    ::  .^(json %gx /=rss-sub-example=/feed/<url>/items/json)
    ::  items/entries from the RSS channel or Atom feed at the given URL
    [%x %feed %items =link:ra ~]
      =/  entry  (~(get by feed-state) (slav %t link.pole))
      ?~  entry  [~ ~]
      =/  [last=updated:rs cached=(unit feed:rs)]  u.entry
      ?~  cached  [~ ~]
      ?:  ?=(%& -.u.cached)
        ?>  ?=([%channel *] +.u.cached)
        =/  =channel:rss:ra  +.u.cached
        ``rss-items+!>(items.channel)
      ?>  ?=([%feed *] +.u.cached)
      =/  =feed:atom:ra  +.u.cached
      ``atom-entries+!>(entries.feed)
  ==
::
++  on-arvo
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
                      items  (~(put in items.channel) item)
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
                      entries  (~(put in entries.feed) entry)
                    ==
      ==
    ::
    ::  refresh timer; update feeds
    [%rss-sub %timer ~]
      ?>  ?=([%behn %wake *] sign-arvo)
      :_  this
      %+  snoc
        ?~  feed-state
          ~
        (make-refresh-cards:rs ~ q.byk.bowl feed-state)
      [%pass /rss-sub/timer %arvo %b %wait (add refresh now.bowl)]
  ==  ::  end of pole branches
::
++  on-agent  on-agent:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
