/-  ra=rss-atom
/+  default-agent, dbug, verb
::
::  XX mark warmers for noun and json
::
|%
++  agent
  ^-  $-(agent:gall agent:gall)
  |^  agent
  ::
  +$  updated  @da                                       ::  last update
  +$  refresh  (unit @dr)                                ::  refresh timer
  +$  feed     (each channel:rss:ra feed:atom:ra)        ::  RSS/Atom
  +$  feeds    (map link:ra (pair updated (unit feed)))  ::  URLs and feeds
  ::
  +$  rss-sub-action
    $%  [%add-feed =link:ra]
        [%del-feed =link:ra]
        [%set-refresh =refresh]
        [%refresh-now link=(unit link:ra)]
    ==
  ::
  +$  state-0
    $:  %0
        =feeds
        =refresh
    ==
  ::
  +$  card  card:agent:gall
  ::
  ++  agent
    |=  inner=agent:gall
    =|  state-0
    =*  state  -
    %+  verb  |
    %-  agent:dbug
    ^-  agent:gall
    |_  =bowl:gall
    +*  this  .
        og    ~(. inner bowl)
        def   ~(. (default-agent this %|) bowl)
    ::
    ++  on-init
      ^-  (quip card _this)
      ::  XX don't do anything here, have agent poke this in
      ::      e.g. invent:gossip pattern
      =^  cards  inner  on-init:og
      :_  %=  this
            refresh  `~m15
          ==
      (snoc cards [%pass /rss-sub/timer %arvo %b %wait (add ~m15 now.bowl)])
    ::
    ++  on-save
      !>([[%rss-sub state] on-save:og])
    ::
    ++  on-load
      |=  ole=vase
      ^-  (quip card _this)
      ?.  ?=([[%rss-sub *] *] q.ole)
        =^  cards  inner  (on-load:og ole)
        [cards this]
      =+  !<([[%rss-sub old=state-0] ile=vase] ole)
      =.  state  old
      =^  cards  inner  (on-load:og ile)
      [cards this]
    ::
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      ?.  =(%rss-sub mark)
        =^  cards  inner  (on-poke:og mark vase)
        [cards this]
      =/  act  !<(rss-sub-action vase)
      ?-    -.act
          %del-feed
        =/  new-feeds  (~(del by feeds) link.act)
        :_  this(feeds new-feeds)
        ~[[%give %fact ~[/x/feeds] feed-urls+!>(~(tap in ~(key by new-feeds)))]]
      ::
          %set-refresh
        `this(refresh ?~(refresh.act ~ `u.refresh.act))
      ::
          %refresh-now
        [(make-refresh-cards:help link.act q.byk.bowl feeds) this]
      ::
          %add-feed
        ?~  (de-purl:html link.act)
          ~|  "{<q.byk.bowl>}: invalid URL {<link.act>}"
          !!
        :_  this
        :~  :*  %pass  /rss-sub/update/feed/(scot %t link.act)
                %arvo  %k
                %fard  q.byk.bowl
                %rss-atom  [%noun !>([now.bowl link.act])]
            ==
        ==
      ==
    ::
    ++  on-watch
      |=  =path
      ^-  (quip card _this)
      ?+  path
        =^  cards  inner  (on-watch:og path)
        [cards this]
      ::
        [%feeds ~]          `this
        [%feed =link:ra ~]  `this
      ==
    ::
    ++  on-peek
      |=  =(pole knot)
      ^-  (unit (unit cage))
      ?+  pole  (on-peek:og `path`pole)
        ::
        ::  list all subscribed feeds
        ::  .^(json %gx /=rss-sub-example=/rss-sub/urls/json)
        ::  .^((list @t) %gx /=rss-sub-example=/rss-sub/urls/noun)
          [%x %rss-sub %urls ~]
        ``feed-urls+!>(~(tap in ~(key by feeds)))
        ::
        ::  last-updated time for the given feed
        ::  .^(@da %gx /=rss-sub-example=/rss-sub/feed/last-update/<url>/noun)
        ::  .^(json %gx /=rss-sub-example=/rss-sub/feed/last-update/<url>/json)
          [%x %rss-sub %feed %last-update link=@ta ~]
        =/  url=@t  (slav %t link.pole)
        =/  entry  (~(get by feeds) url)
        ?~  entry  [~ ~]
        ``feed-last-update+!>(-:u.entry)
        ::
        ::  info for a feed
        ::  .^(json %gx /=rss-sub-example=/rss-sub/feed/<url>/json)
        ::  .^(channel:rss:ra %gx /=rss-sub-example=/rss-sub/feed/<url>/noun)
          [%x %rss-sub %feed link=@ta ~]
        =/  url=@t  (slav %t link.pole)
        =/  entry  (~(get by feeds) url)
        ?~  entry  [~ ~]
        =/  [last=updated cached=(unit feed)]  u.entry
        ?~  cached  [~ ~]
        ?:  ?=(%& -.u.cached)
          ?>  ?=([%channel *] +.u.cached)
          =/  =channel:rss:ra  +.u.cached
          ``rss-channel+!>(channel)
        ?>  ?=([%feed *] +.u.cached)
        =/  =feed:atom:ra  +.u.cached
        ``atom-feed+!>(feed)
        ::
        ::  XX add optional /<time> to path
        ::       don't search feeds which were updated before <time>
        ::       just search all feeds if <time> is ~
        ::
        ::  items in a feed
        ::  .^(json %gx /=rss-sub-example=/rss-sub/feed/items/<url>/json)
        ::  .^((each (set item:rss:ra) (set entry:atom:ra)) %gx /=rss-sub-example=/rss-sub/feed/items/<url>/noun)
          [%x %rss-sub %feed %items link=@ta ~]
        =/  url=@t  (slav %t link.pole)
        =/  entry  (~(get by feeds) url)
        ?~  entry  [~ ~]
        =/  [last=updated cached=(unit feed)]  u.entry
        ?~  cached  [~ ~]
        ?:  ?=(%& -.u.cached)
          ?>  ?=([%channel *] +.u.cached)
          =/  =channel:rss:ra  +.u.cached
          ``feed-items+!>(`(each (set item:rss:ra) (set entry:atom:ra))`[%& items.channel])
        ?>  ?=([%feed *] +.u.cached)
        =/  =feed:atom:ra  +.u.cached
        ``feed-items+!>(`(each (set item:rss:ra) (set entry:atom:ra))`[%| entries.feed])
      ==
    ::
    ++  on-arvo
      |=  [=(pole knot) =sign-arvo]
      ^-  (quip card _this)
      ?+  pole
        =^  cards  inner  (on-arvo:og pole sign-arvo)
        [cards this]
        ::
        ::  update rss-atom with new metadata and pass output
        ::  onto either -item or -entry
        [%rss-sub %update %feed =link:ra ~]
          ?>  ?=([%khan %arow *] sign-arvo)
          ?.  ?=(%& -.p.sign-arvo)
            ~&  >>>  "{<q.byk.bowl>}: failed to parse rss channel or atom feed at {<(@t (slav %t link.pole))>}"
            `this
          ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
          =/  [%khan %arow %.y %noun =vase]  sign-arvo
          ::  XX should be [rss/atom rss-channel-element/atom-feed-element marl]
          =/  res  !<([?(%rss %atom) feed=* items=(list manx)] vase)
          ?-  -.res
              %rss
            ~&  >  "{<q.byk.bowl>}: parsed rss channel {<(@t (slav %t link.pole))>}"
            =/  ch-elems  ((list channel-element:rss:ra) feed.res)
            =/  last-build=(unit @da)
              =/  scan  ch-elems
              |-  ^-  (unit @da)
              ?~  scan  ~
              ?:  ?=([%last-build-date *] i.scan)
                `p.i.scan
              $(scan t.scan)
            =/  prev-updated
              =/  entry  (~(get by feeds) (@t (slav %t link.pole)))
              ?~  entry  *@da
              p.u.entry
            ::  only process items if lastBuildDate
            ::  is absent or newer than .updated
            ?.  ?~(last-build %.y (gth u.last-build prev-updated))
              `this
            =/  new-feeds
              %-  ~(put by feeds)
              :-  (slav %t link.pole)
              :-  now.bowl
              %-  some
              ^-  feed
              :-  %.y
              ^-  channel:rss:ra
              ::  XX what goes in headers?
              :*  %channel
                  ~
                  ch-elems
                  ~
              ==
            :_  this(feeds new-feeds)
            :-  :*  %give  %fact  ~[/x/rss-sub/urls]
                    [%feed-urls !>(~(tap in ~(key by new-feeds)))]
                ==
            %+  turn
              items.res
            |=  =manx
            ^-  card
            :*  %pass  /rss-sub/update/item/[link.pole]
                %arvo  %k
                %fard  q.byk.bowl
                %rss-item  [%noun !>(manx)]
            ==
          ::
              %atom
            ~&  >  "{<q.byk.bowl>}: parsed atom feed {<(@t (slav %t link.pole))>}"
            =/  fe-elems  ((list feed-element:atom:ra) feed.res)
            =/  feed-updated=(unit @da)
              =/  scan  fe-elems
              |-  ^-  (unit @da)
              ?~  scan  ~
              ?:  ?=([%updated *] i.scan)
                `p.i.scan
              $(scan t.scan)
            =/  prev-updated
              =/  entry  (~(get by feeds) (@t (slav %t link.pole)))
              ?~  entry  *@da
              p.u.entry
            ::  only process entries if feed's updated
            ::  attr. is absent or newer than .updated
            ?.  ?~(feed-updated %.y (gth u.feed-updated prev-updated))
              `this
            =/  new-feeds
              %-  ~(put by feeds)
              :-  (slav %t link.pole)
              :-  now.bowl
              %-  some
              ^-  feed
              :-  %.n
              ^-  feed:atom:ra
              ::  XX what goes in headers?
              [%feed ~ fe-elems ~]
            :_  this(feeds new-feeds)
            :-  :*  %give  %fact  ~[/x/rss-sub/urls]
                    [%feed-urls !>(~(tap in ~(key by new-feeds)))]
                ==
            %+  turn
              items.res
            |=  =manx
            ^-  card
            :*  %pass  /rss-sub/update/atom-entry/[link.pole]
                %arvo  %k
                %fard  q.byk.bowl
                %atom-entry  [%noun !>(manx)]
            ==
          ==
        ::
        ::  update rss channel with new item
        [%rss-sub %update %item =link:ra ~]
          ?>  ?=([%khan %arow *] sign-arvo)
          ?.  ?=(%& -.p.sign-arvo)
            ~&  >>>  "{<q.byk.bowl>}: invalid rss item from url {<(@t (slav %t link.pole))>}"
            `this
          ~&  >  "{<q.byk.bowl>}: parsed rss item from url {<(@t (slav %t link.pole))>}"
          ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
          =/  [%khan %arow %.y %noun =vase]  sign-arvo
          =/  =item:rss:ra  !<(item:rss:ra vase)
          =/  cached  (~(get by feeds) (@t (slav %t link.pole)))
          ?~  cached  `this
          ?<  ?=(~ q.u.cached)
          ?>  -.u.q.u.cached
          ?>  ?=([%channel *] +.u.q.u.cached)
          =/  =channel:rss:ra  +.u.q.u.cached
          :-  :~  :*  %give  %fact  ~[/feeds /feed/[link.pole]]
                      [%rss-item !>(item)]
                  ==
              ==
          %=  this
            feeds  %-  ~(put by feeds)
                   :-  (@t (slav %t link.pole))
                   :-  now.bowl
                   %-  some
                   ^-  feed
                   :-  %.y
                   ^-  channel:rss:ra
                   %=  channel
                     items  (~(put in items.channel) item)
          ==       ==
        ::
        ::  update atom feed with new entry
        [%rss-sub %update %atom-entry =link:ra ~]
          ?>  ?=([%khan %arow *] sign-arvo)
          ?.  ?=(%& -.p.sign-arvo)
            ~&  >>>  "{<q.byk.bowl>}: invalid atom entry from url {<(@t (slav %t link.pole))>}"
            `this
          ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
          =/  [%khan %arow %.y %noun =vase]  sign-arvo
          =/  =entry:atom:ra  !<(entry:atom:ra vase)
          =/  cached  (~(get by feeds) (@t (slav %t link.pole)))
          ?~  cached  `this
          ?<  ?=(~ q.u.cached)
          ?:  -.u.q.u.cached  `this
          ?>  ?=([%feed *] +.u.q.u.cached)
          =/  af=feed:atom:ra  +.u.q.u.cached
          :-  :~  :*  %give  %fact  ~[/feeds /feed/[link.pole]]
                      [%atom-entry !>(entry)]
                  ==
              ==
          %=  this
            feeds  %-  ~(put by feeds)
                   :-  (@t (slav %t link.pole))
                   :-  now.bowl
                   %-  some
                   ^-  feed
                   :-  %.n
                   ^-  feed:atom:ra
                   %=  af
                     entries  (~(put in entries.af) entry)
          ==       ==
        ::
        ::  refresh timer; update feeds
        [%rss-sub %timer ~]
          ?>  ?=([%behn %wake *] sign-arvo)
          :_  this
          ?~  refresh
            ~
          %+  snoc
            ?~  feeds
              ~
            (make-refresh-cards:help ~ q.byk.bowl feeds)
          [%pass /rss-sub/timer %arvo %b %wait (add u.refresh now.bowl)]
      ==
    ::
    ++  on-agent  on-agent:def
    ++  on-leave  on-leave:def
    ++  on-fail   on-fail:def
    --
  ++  help
  |%
  ++  set-refresh  !!
  ::
  ++  make-refresh-cards
    |=  [link=(unit link:ra) =desk =feeds]
    ^-  (list card:agent:gall)
    ?~  link
      ::  refresh all links
      %+  turn
        ~(tap in ~(key by feeds))
      |=  =link:ra
      %:  make-refresh-card
          link
          -:(~(got by feeds) link)
          desk
      ==
    ::  refresh given link
    ?.  (~(has by feeds) u.link)
      ~
    :~  %:  make-refresh-card
            u.link
            -:(~(got by feeds) u.link)
            desk
        ==
    ==
  ::
  ++  make-refresh-card
    ::  XX foobarbat should all be link
    |=  [bat=@t =updated =desk]
    ^-  card:agent:gall
    :*  %pass
        ::  XX should devs be able to optionally specify
        ::     a return path?
        /rss-sub/update/feed/(scot %t bat)
        %arvo
        %k
        %fard
        desk
        %rss-atom
        %noun
        !>([updated bat])
    ==
  ::
  ::  XX convert rss time to @da
  ::
  ::  XX convert atom time to @da
  ::
  --
  --
--
