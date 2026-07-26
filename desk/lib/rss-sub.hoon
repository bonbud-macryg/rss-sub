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
  +$  result
    $%  [%rss =link:ra channel=(list channel-element:rss:ra) items=(list item:rss:ra)]
        [%atom =link:ra feed=(list feed-element:atom:ra) entries=(list entry:atom:ra)]
    ==
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
        :~  :*  %give  %fact  ~[/rss-sub/feeds]
                %rss-sub-update  !>([%feed-deleted link.act])
            ==
        ==
      ::
          %refresh-now
        =/  links=(list link:ra)
          ?~  link.act
            ~(tap in ~(key by feeds))
          ?.  (~(has by feeds) u.link.act)
            ~
          ~[u.link.act]
        ?~  links
          `this
        :_  this
        :~  :*  %pass  /rss-sub/refresh-feeds
                %arvo  %k
                %fard  q.byk.bowl
                %fetch-feeds  [%noun !>([links feeds])]
            ==
        ==
      ::
          %add-feeds
        ?.  (valid-links:help links.act)
          ~|  "{<q.byk.bowl>}: invalid URL in %add-feeds"
          !!
        ?~  links.act
          `this
        :_  this
        :~  :*  %pass  /rss-sub/add-feeds
                %arvo  %k
                %fard  q.byk.bowl
                %fetch-feeds  [%noun !>([links.act feeds])]
            ==
        ==
      ==
    ::
    ++  on-watch
      |=  =path
      ^-  (quip card _this)
      ?+    path  =^  cards  inner  (on-watch:og path)
                  [cards this]
          [%rss-sub %feeds ~]
        :_  this
        %+  turn
          ^-  (list link:ra)
          ~(tap in ~(key by feeds))
        |=  =link:ra
        ^-  card
        :*  %give  %fact  ~
            %rss-sub-update  !>([%feed-added link])
        ==
      ::
          [%rss-sub %feed link=@ta ~]
        [(feed-facts:help (slav %t i.t.t.path) feeds) this]
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
        ::  add a batch of feeds from one fetch-feeds thread call
        [%rss-sub %add-feeds ~]
          ?>  ?=([%khan %arow *] sign-arvo)
          ?.  ?=(%& -.p.sign-arvo)
            ~&  >>>  "{<q.byk.bowl>}: failed to fetch added feeds"
            `this
          ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
          =/  [%khan %arow %.y %noun =vase]  sign-arvo
          =/  results  !<((list result) vase)
          =/  new-feeds  (add-results:help results now.bowl feeds)
          [(feed-added-facts:help results) this(feeds new-feeds)]
        ::
        ::  refresh cached feeds in one fetch-feeds thread call
        [%rss-sub %refresh-feeds ~]
          ?>  ?=([%khan %arow *] sign-arvo)
          ?.  ?=(%& -.p.sign-arvo)
            ~&  >>>  "{<q.byk.bowl>}: failed to refresh feeds"
            `this
          ?>  ?=([%khan %arow %.y %noun *] sign-arvo)
          =/  [%khan %arow %.y %noun =vase]  sign-arvo
          =/  results  !<((list result) vase)
          =/  new-feeds  (add-results:help results now.bowl feeds)
          [(result-facts:help results) this(feeds new-feeds)]
      ==
    ::
    ++  on-agent
      |=  [=(pole knot) =sign:agent:gall]
      ^-  (quip card _this)
      =^  cards  inner  (on-agent:og pole sign)
      [cards this]
    ++  on-leave  on-leave:def
    ++  on-fail   on-fail:def
    --
  ::
  ++  help
    |%
    ++  valid-links
      |=  links=(list link:ra)
      ^-  ?
      |-
      ?~  links
        %.y
      ?~  (de-purl:html i.links)
        %.n
      $(links t.links)
    ::
    ++  add-results
      |=  [results=(list result) now=@da cur=feeds:rs]
      ^-  feeds:rs
      |-
      ?~  results
        cur
      %=  $
        results  t.results
        cur      (add-result i.results now cur)
      ==
    ::
    ::  merge a parsed result into the cached feeds: the parser only
    ::  returns unknown items, so union them into any same-kind cache
    ++  add-result
      |=  [res=result now=@da cur=feeds:rs]
      ^-  feeds:rs
      =/  old  (~(get by cur) link.res)
      ?-    -.res
          %rss
        =/  items=(set item:rss:ra)
          =/  new  (~(gas in *(set item:rss:ra)) items.res)
          ?~  old  new
          ?~  q.u.old  new
          ?.  ?=(%& -.u.q.u.old)  new
          (~(uni in items.p.u.q.u.old) new)
        %-  ~(put by cur)
        :-  link.res
        :-  now
        %-  some
        ^-  feed:rs
        :-  %.y
        ^-  channel:rss:ra
        [%channel ~ channel.res items]
      ::
          %atom
        =/  entries=(set entry:atom:ra)
          =/  new  (~(gas in *(set entry:atom:ra)) entries.res)
          ?~  old  new
          ?~  q.u.old  new
          ?:  ?=(%& -.u.q.u.old)  new
          (~(uni in entries.p.u.q.u.old) new)
        %-  ~(put by cur)
        :-  link.res
        :-  now
        %-  some
        ^-  feed:rs
        :-  %.n
        ^-  feed:atom:ra
        [%feed ~ feed.res entries]
      ==
    ::
    ++  feed-added-facts
      |=  results=(list result)
      ^-  (list card:agent:gall)
      |-
      ?~  results
        ~
      :-  :*  %give  %fact  ~[/rss-sub/feeds]
              %rss-sub-update  !>([%feed-added link.i.results])
          ==
      $(results t.results)
    ::
    ++  feed-facts
      |=  [=link:ra =feeds:rs]
      ^-  (list card:agent:gall)
      =/  entry  (~(get by feeds) link)
      ?~  entry  ~
      ?~  q.u.entry  ~
      ?:  -.u.q.u.entry
        ?>  ?=([%channel *] +.u.q.u.entry)
        =/  =channel:rss:ra  +.u.q.u.entry
        %+  turn
          ~(tap in items.channel)
        |=  =item:rss:ra
        :*  %give  %fact  ~
            %rss-item  !>(item)
        ==
      ?>  ?=([%feed *] +.u.q.u.entry)
      =/  =feed:atom:ra  +.u.q.u.entry
      %+  turn
        ~(tap in entries.feed)
      |=  =entry:atom:ra
      :*  %give  %fact  ~
          %atom-entry  !>(entry)
      ==
    ::
    ++  result-facts
      |=  results=(list result)
      ^-  (list card:agent:gall)
      %+  roll  results
      |=  [res=result cards=(list card:agent:gall)]
      %+  weld
        (result-facts-one res)
      cards
    ::
    ++  result-facts-one
      |=  res=result
      ^-  (list card:agent:gall)
      ?-    -.res
          %rss
        %+  turn  items.res
        |=  =item:rss:ra
        :*  %give  %fact  ~[/rss-sub/feed/(scot %t link.res)]
            %rss-item  !>(item)
        ==
      ::
          %atom
        %+  turn  entries.res
        |=  =entry:atom:ra
        :*  %give  %fact  ~[/rss-sub/feed/(scot %t link.res)]
            %atom-entry  !>(entry)
        ==
      ==
    --
  --
--
