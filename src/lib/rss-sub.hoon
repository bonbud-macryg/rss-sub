/-  rs=rss-sub, ra=rss-atom
/+  default-agent, dbug, verb
::
|%
++  agent
  ^-  $-(agent:gall agent:gall)
  |^  agent
  +$  state-0
    $:  %0
        =feeds:rs
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
      =^  cards  inner  on-init:og
      [cards this]
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
      =/  act  !<(rss-sub-action:rs vase)
      ?-    -.act
          %del-feed
        =/  new-feeds  (~(del by feeds) link.act)
        :_  this(feeds new-feeds)
        ~[[%give %fact ~[/x/feeds] feed-urls+!>(~(tap in ~(key by new-feeds)))]]
      ::
          %refresh-now
        [(make-refresh-cards:help link.act q.byk.bowl feeds) this]
      ::
          %add-feed
        ?~  (de-purl:html link.act)
          ~|  "{<q.byk.bowl>}: invalid URL {<link.act>}"
          !!
        :_  this
        :~  :*  %pass  /rss-sub/update/(scot %t link.act)
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
        =/  [last=updated:rs cached=(unit feed:rs)]  u.entry
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
        ::  parse full feed and index all items/entries
        [%rss-sub %index =link:ra ~]
          ?>  ?=([%khan %arow *] sign-arvo)
          ?.  ?=(%& -.p.sign-arvo)
            ~&  >>>  "{<q.byk.bowl>}: failed to parse rss channel or atom feed at {<(@t (slav %t link.pole))>}"
            `this
          ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
          =/  [%khan %arow %.y %noun =vase]  sign-arvo
          =/  res  !<([?(%rss %atom) feed=* items=(list manx)] vase)
          ?-  -.res
              %rss
            =/  new-feeds
              %-  ~(put by feeds)
              :-  (slav %t link.pole)
              :-  now.bowl
              %-  some
              ^-  feed:rs
              :-  %.y
              ^-  channel:rss:ra
              :*  %channel
                  ~
                  ((list channel-element:rss:ra) feed.res)
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
            =/  new-feeds
              %-  ~(put by feeds)
              :-  (slav %t link.pole)
              :-  now.bowl
              %-  some
              ^-  feed:rs
              :-  %.n
              ^-  feed:atom:ra
              [%feed ~ ((list feed-element:atom:ra) feed.res) ~]
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
        ::  update: parse rss/atom and dispatch to item/entry checker
        [%rss-sub %update link=@ta ~]
          =/  =link:ra  (@t (slav %t link.pole))
          ?>  ?=([%khan %arow *] sign-arvo)
          ?.  ?=(%& -.p.sign-arvo)
            `this
          ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
          =/  [%khan %arow %.y %noun =vase]  sign-arvo
          =/  res  !<([?(%rss %atom) feed=* items=(list manx)] vase)
          ?~  items.res
            `this
          ?-  -.res
              %rss
            :_  this
            :~  :*  %pass      /rss-sub/check/latest/item/[link.pole]
                    %arvo      %k
                    %fard      q.byk.bowl
                    %rss-item  [%noun !>(i.items.res)]
                ==
            ==
          ::
              %atom
            :_  this
            :~  :*  %pass        /rss-sub/check/latest/entry/[link.pole]
                    %arvo        %k
                    %fard        q.byk.bowl
                    %atom-entry  [%noun !>(i.items.res)]
                ==
            ==
          ==
        ::
        ::  check latest rss item %pub-date
        [%rss-sub %check %latest %item link=@ta ~]
          =/  =link:ra  (@t (slav %t link.pole))
          ?>  ?=([%khan %arow *] sign-arvo)
          ?.  ?=(%& -.p.sign-arvo)
            `this
          ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
          =/  [%khan %arow %.y %noun =vase]  sign-arvo
          =/  =item:rss:ra  !<(item:rss:ra vase)
          =/  prev-updated
            =/  old  (~(get by feeds) link)
            ?~  old  *@da
            p.u.old
          =/  check-updated  (rss-item-published:help item)
          ?~  check-updated
            `this
          ?.  (gth u.check-updated prev-updated)
            `this
          :_  this
          :~  :*  %pass      /rss-sub/index/[link.pole]
                  %arvo      %k
                  %fard      q.byk.bowl
                  %rss-atom  [%noun !>([u.check-updated link])]
              ==
          ==
        ::
        ::  check latest atom entry %published / %updated
        [%rss-sub %check %latest %entry link=@ta ~]
          =/  =link:ra  (@t (slav %t link.pole))
          ?>  ?=([%khan %arow *] sign-arvo)
          ?.  ?=(%& -.p.sign-arvo)
            `this
          ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
          =/  [%khan %arow %.y %noun =vase]  sign-arvo
          =/  =entry:atom:ra  !<(entry:atom:ra vase)
          =/  prev-updated
            =/  old  (~(get by feeds) link)
            ?~  old  *@da
            p.u.old
          =/  check-updated  (atom-entry-published:help entry)
          ?~  check-updated
            `this
          ?.  (gth u.check-updated prev-updated)
            `this
          :_  this
          :~  :*  %pass      /rss-sub/index/[link.pole]
                  %arvo      %k
                  %fard      q.byk.bowl
                  %rss-atom  [%noun !>([u.check-updated link])]
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
          =/  item-updated  (rss-item-published:help item)
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
                   :-  ?~(item-updated p.u.cached ?:((gth u.item-updated p.u.cached) u.item-updated p.u.cached))
                   %-  some
                   ^-  feed:rs
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
          ~&  >  "{<q.byk.bowl>}: parsed atom entry from url {<(@t (slav %t link.pole))>}"
          ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
          =/  [%khan %arow %.y %noun =vase]  sign-arvo
          =/  =entry:atom:ra  !<(entry:atom:ra vase)
          =/  entry-updated  (atom-entry-published:help entry)
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
                   :-  ?~(entry-updated p.u.cached ?:((gth u.entry-updated p.u.cached) u.entry-updated p.u.cached))
                   %-  some
                   ^-  feed:rs
                   :-  %.n
                   ^-  feed:atom:ra
                   %=  af
                     entries  (~(put in entries.af) entry)
          ==       ==
      ==
    ::
    ++  on-agent  on-agent:def
    ++  on-leave  on-leave:def
    ++  on-fail   on-fail:def
    --
  ::
  ++  help
  |%
  ++  rss-item-published
    |=  =item:rss:ra
    ^-  (unit @da)
    |-
    ?~  p.item
      ~
    ?:  ?=([%pub-date *] i.p.item)
      `p.i.p.item
    $(p.item t.p.item)
  ::
  ++  atom-entry-published
    |=  =entry:atom:ra
    ^-  (unit @da)
    |-
    ?~  p.entry
      ~
    ?:  ?=([%published *] i.p.entry)
      `p.i.p.entry
    ?:  ?=([%updated *] i.p.entry)
      `p.i.p.entry
    $(p.entry t.p.entry)
  ::
  ++  make-refresh-cards
    |=  [link=(unit link:ra) =desk =feeds:rs]
    ^-  (list card:agent:gall)
    ?~  link
      ::  refresh all links
      %+  turn
        ~(tap in ~(key by feeds))
      |=  =link:ra
      %:  make-refresh-card
          link
          p:(~(got by feeds) link)
          desk
      ==
    ::  refresh given link
    ?.  (~(has by feeds) u.link)
      ~
    :~  %:  make-refresh-card
            u.link
            p:(~(got by feeds) u.link)
            desk
        ==
    ==
  ::
  ++  make-refresh-card
    |=  [=link:ra =updated:rs =desk]
    ^-  card:agent:gall
    :*  %pass
        /rss-sub/update/(scot %t link)
        %arvo
        %k
        %fard
        desk
        %rss-atom
        %noun
        !>([updated link])
    ==
  ::
  ::  XX convert rss time to @da
  ::
  ::  XX convert atom time to @da
  ::
  --
  --
--
