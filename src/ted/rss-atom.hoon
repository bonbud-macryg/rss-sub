::
::  parse an rss channel / atom feed and
::  create threads to parse new items / entries
::
/-  spider, ra=rss-atom
/+  io=strandio, rs=rss-sub
=,  strand=strand:spider
=,  strand-fail:strand-fail:strand
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  time-and-link  !<([=time =link:ra] arg)
;<    now=@da
    bind:m
  get-time:io
::
::  check if updated time is valid
?.  (lte time.time-and-link now)
  ::  XX all error messaging should be better
  ::       should include source desk, other dynamic info
  (strand-fail %bad-updated-time ~)
::
::  make iris card for http request
::  XX ugly lark notation on feed
=/  =request:http     [%'GET' link.time-and-link ~ ~]
=/  =task:iris        [%request request *outbound-config:iris]
=/  =card:agent:gall  [%pass /http-req %arvo %i task]
::
::  send card and validate response
;<    ~
    bind:m
  (send-raw-card:io card)
;<    response=(pair wire sign-arvo)
    bind:m
  take-sign-arvo:io
?.  ?=([%iris %http-response %finished *] q.response)
  (strand-fail %failed-http-request ~)
=,  response-header.client-response.q.response
?~  full-file.client-response.q.response
  ?.  ?|  =(301 status-code)
          =(307 status-code)
      ==
    (strand-fail %empty-response ~)
  %=  $
    arg  !>  ^-  (pair time @t)
         :-  time.time-and-link
         %-  %~  got  by
           (malt headers)
         'location'
  ==
?:  (gte status-code 500)
  (strand-fail %internal-server-error ~)
?:  (gte status-code 400)
  (strand-fail %bad-request ~)
::
=/  sanitize
  |=  xml=@t
  ^-  @t
  =/  in=tape  (trip xml)
  =/  clean=tape
    %+  murn  in
    |=  c=@
    ^-  (unit @)
    ?:  (gth c 127)  ~
    ?:  =(`@`13 c)   ~
    ?:  =(`@`9 c)    `' '
    `c
  =/  no-pis=tape
    =/  strip-pis
      |=  t=tape
      ^-  tape
      |-
      ?~  t  ~
      ?.  =('<' i.t)  [i.t $(t t.t)]
      ?~  t.t  [i.t ~]
      ?.  =('?' i.t.t)  [i.t $(t t.t)]
      =/  skip-end
        |=  s=tape
        ^-  tape
        |-
        ?~  s  ~
        ?.  =('?' i.s)  $(s t.s)
        ?~  t.s  ~
        ?.  =('>' i.t.s)  $(s t.s)
        t.t.s
      $(t (skip-end t.t.t))
    (strip-pis clean)
  =/  fix-hyphens
    |=  t=tape
    ^-  tape
    =/  s=@ud  0
    |-
    ?~  t  ~
    ?:  =(0 s)
      ?.  =('<' i.t)  [i.t $(t t.t)]
      ?:  ?&  ?=(^ t.t)  =('!' i.t.t)
              ?=(^ t.t.t)  =('[' i.t.t.t)
          ==
        [i.t $(t t.t, s 1)]
      ?:  ?&  ?=(^ t.t)  =('!' i.t.t)
              ?=(^ t.t.t)  =('-' i.t.t.t)
          ==
        [i.t $(t t.t, s 6)]
      ?:  ?&  ?=(^ t.t)  =('!' i.t.t)  ==
        [i.t $(t t.t)]
      [i.t $(t t.t, s 2)]
    ?:  =(1 s)
      ?:  ?&  =(']' i.t)
              ?=(^ t.t)  =(']' i.t.t)
              ?=(^ t.t.t)  =('>' i.t.t.t)
          ==
        [']' [']' ['>' $(t t.t.t.t, s 0)]]]
      [i.t $(t t.t)]
    ?:  =(2 s)
      ?:  =('>' i.t)  [i.t $(t t.t, s 0)]
      ?:  =(' ' i.t)  [i.t $(t t.t, s 3)]
      ?:  =('-' i.t)  ['_' $(t t.t)]
      [i.t $(t t.t)]
    ?:  =(3 s)
      ?:  =('>' i.t)   [i.t $(t t.t, s 0)]
      ?:  =('"' i.t)   [i.t $(t t.t, s 4)]
      ?:  =('\'' i.t)  [i.t $(t t.t, s 5)]
      ?:  =('-' i.t)   ['_' $(t t.t)]
      ?:  =(' ' i.t)
        =/  rest=tape  t.t
        |-  ^-  tape
        ?~  rest  [' ' ~]
        ?:  =(' ' i.rest)  $(rest t.rest)
        ?:  =('>' i.rest)  ['>' ^$(t t.rest, s 0)]
        [' ' ^$(t rest, s 3)]
      [i.t $(t t.t)]
    ?:  =(4 s)
      ?:  =('"' i.t)   [i.t $(t t.t, s 3)]
      [i.t $(t t.t)]
    ?:  =(5 s)
      ?:  =('\'' i.t)  [i.t $(t t.t, s 3)]
      [i.t $(t t.t)]
    ?:  =(6 s)
      ?:  ?&  =('-' i.t)
              ?=(^ t.t)  =('-' i.t.t)
              ?=(^ t.t.t)  =('>' i.t.t.t)
          ==
        ['-' ['-' ['>' $(t t.t.t.t, s 0)]]]
      [i.t $(t t.t)]
    [i.t $(t t.t)]
  (crip (fix-hyphens no-pis))
::
=/  xml
  (de-xml:html (sanitize `@t`q.data.u.full-file.client-response.q.response))
?~  xml
  ::
  ::  XX failures to parse here could be fixed by ~migrev-dolseg's patch
  ::       test those problem feeds in %feeds and check for %parse-failed error
  ::  XX de-xml:html has known limitations with namespaced attributes
  ::       e.g. xml:lang="en-US" or xmlns:thr=... on the root element
  ::       causes parse failure; would require pre-processing to strip
  ::       namespace declarations or a patch to de-xml:html
  (strand-fail %failed-to-parse-xml ~)
::
::  XX is this test robust enough?
::     skimming for any %channel tags might be better
::
::  branch on whether feed is rss or atom
::
::  right now this is just declaring whether feed is
::  rss or atom, but eventually should 1) parse feed info
::  and send back to the agent and 2) send each item or
::  entry in the rss/atom feed to the relevant thread:
::  either -item or -entry
=/  document
  c:(need xml)
?:  =(%channel n.g:(head c:(need xml)))
  ::
  ::  rss channel
  =/  channel-tags
    %+  turn
      %+  skip
        c.i.-.document
      |=  =manx
      ^-  ?
      ?|  =(n.g.manx %item)
          =(n.g.manx %items)
      ==
    |=  =manx
    ^-  channel-element:rss:ra
    =*  tag  n.g.manx
    =*  val  (crip v:(head a.g:(head c.manx)))
    ~&  >>  %ted-rss-atom
    ~&  >>  %rss-channel
    ~&  >>  tag
    ~&  >>  val
    ?+  tag
      ::  XX error
      [%title 'foobarthisisthedefaultcase']
    ::
      %docs         [tag val]
      %link         [tag val]
      %title        [tag val]
      %rating       [tag val]
      %language     [tag val]
      %copyright    [tag val]
      %generator    [tag val]
      %description  [tag val]
    ::
        %'pubDate'
      ::  XX parse date from RSS time to @da
      [%pub-date ~2000.1.1]
    ::
        %'lastBuildDate'
      ::  XX as above
      [%last-build-date ~2000.1.1]
    ::
        %'managingEditor'
      !!
    ::
        %'webMaster'
      !!
    ::
        %category
      !!
    ::
        %ttl
      !!
    ::
        %'textInput'
      !!
    ::
        %cloud
      !!
    ::
        %image
      !!
    ::
        %'skipDays'
      !!
    ::
        %'skipHours'
      !!
    ==
  ::
  ::  items will be processed by /ted/item.hoon
  =/  item-tags
    ^-  marl
    %+  skim
      c.i.-.document
    |=  =manx
    ^-  ?
    =(n.g.manx %item)
  ::
  %-  pure:m
  !>  ^-  [%rss * marl]
  ~&  >>  %ted-rss-atom
  ~&  >>  %rss-channel
  ~&  >>  "channel tags: {<channel-tags>}"
  ::  ~&  >>  "item tags: {<item-tags>}"
  :*  %rss
      channel-tags
      item-tags
  ==
::
::  atom feed
~&  >  %atom-feed
=/  get-text
  |=  node=manx
  ^-  @t
  (crip v:(head a.g:(head c.node)))
::
=/  get-attr
  |=  [node=manx name=@tas]
  ^-  (unit tape)
  %-  ~(get by (malt (turn a.g.node |=(a=[n=mane v=tape] [n.a v.a]))))
  name
::
=/  feed-tags=(list feed-element:atom:ra)
  %+  murn
    document
  |=  child=manx
  ^-  (unit feed-element:atom:ra)
  =*  tag  n.g.child
  ?:  =(%$ tag)  ~
  ?+  tag  ~
    %id        `[%id (get-text child)]
    %title     `[%title (get-text child)]
    %subtitle  `[%subtitle (get-text child)]
    %rights    `[%rights (get-text child)]
    %icon      `[%icon (get-text child)]
    %logo      `[%logo (get-text child)]
    ::
    %updated
      ::  XX parse atom date to @da
      `[%updated ~2000.1.1]
    ::
    %author
      ::  name is in <name> child; mail and uri are optional siblings
      =/  name-node=(unit manx)
        =/  matches  (skim c.child |=(m=manx =(n.g.m %name)))
        ?~  matches  ~
        `i.matches
      ?~  name-node  ~
      `[%author (get-text u.name-node) ~ ~]
    ::
    %contributor
      =/  name-node=(unit manx)
        =/  matches  (skim c.child |=(m=manx =(n.g.m %name)))
        ?~  matches  ~
        `i.matches
      ?~  name-node  ~
      `[%contributor (get-text u.name-node)]
    ::
    %generator
      `[%generator ~ ~]
    ::
    %link
      =/  href=(unit tape)  (get-attr child 'href')
      ?~  href  ~
      `[%link (crip u.href) ~ ~ ~ ~ ~]
    ::
    %category
      =/  term=(unit tape)  (get-attr child 'term')
      ?~  term  ~
      `[%category (crip u.term) ~ ~]
    ::
  ==
::
::  entries will be parsed in /ted/atom-entry.hoon
=/  entry-tags=marl
  %+  skim
    document
  |=  child=manx
  ^-  ?
  =(n.g.child %entry)
::
%-  pure:m
!>  ^-  [%atom (list feed-element:atom:ra) marl]
:*  %atom
    feed-tags
    entry-tags
==
