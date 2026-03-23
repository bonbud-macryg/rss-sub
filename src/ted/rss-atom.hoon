::
::  parse an rss channel / atom feed and
::  create threads to parse new items / entries
::
/-  spider, ra=rss-atom
/+  io=strandio, rs=rss-sub
=,  strand=strand:spider
=,  strand-fail:strand-fail:strand
^-  thread:spider
=>  |%
    ::  +parse-rfc2822: parse RFC 2822 date string to @da
    ::
    ::    format: "Mon, 01 Jan 2024 00:00:00 GMT"
    ::    or: "01 Jan 2024 00:00:00 GMT"
    ::    simplified: extracts day, month, year, hour, min, sec
    ::
    ++  parse-rfc2822
      |=  dat=@t
      ^-  (unit @da)
      =/  t=tape  (trip dat)
      ::  skip day-of-week if present (e.g. "Mon, ")
      =/  t=tape
        =/  comma  (find "," t)
        ?~  comma  t
        (slag +(+(u.comma)) t)
      ::  trim leading whitespace
      =.  t
        |-
        ?~  t  t
        ?:  =(' ' i.t)
          $(t t.t)
        t
      ::  parse: DD Mon YYYY HH:MM:SS
      =/  parsed
        %+  rust  t
        ;~  sfix
          ;~  plug
            digits
            ;~(pfix ace mon-to-num)
            ;~(pfix ace digits)
            ;~(pfix ace digits)
            ;~(pfix col digits)
            ;~(pfix col digits)
          ==
          (star next)
        ==
      ?~  parsed  ~
      =/  [dy=@ud mn=@ud yr=@ud hr=@ud mi=@ud sc=@ud]
        u.parsed
      `(year [[%.y yr] mn [dy hr mi sc ~]])
    ::
    ::
    ::  +parse-iso8601: parse ISO 8601 date string to @da
    ::
    ::    format: "2026-03-04T18:00:48+00:00"
    ::    parses YYYY-MM-DDTHH:MM:SS, ignores timezone suffix (treats as UTC)
    ::
    ++  parse-iso8601
      |=  dat=@t
      ^-  (unit @da)
      ?:  =('' dat)  ~
      =/  t=tape  (trip dat)
      =/  parsed
        %+  rust  t
        ;~  sfix
          ;~  plug
            digits                       ::  year
            ;~(pfix hep digits)          ::  month
            ;~(pfix hep digits)          ::  day
            ;~(pfix (jest 'T') digits)   ::  hour
            ;~(pfix col digits)          ::  minute
            ;~(pfix col digits)          ::  second
          ==
          (star next)                    ::  ignore timezone
        ==
      ?~  parsed  ~
      =/  [yr=@ud mn=@ud dy=@ud hr=@ud mi=@ud sc=@ud]
        u.parsed
      `(year [[%.y yr] mn [dy hr mi sc ~]])
    ::
    ::  +digits: parse one or more decimal digits, allowing leading zeros
    ::
    ::    dim:ag rejects leading zeros (e.g. "03" fails).
    ::    this parser accepts them, needed for zero-padded date fields.
    ::
    ++  digits
      %+  cook
        |=  a=(list @)
      %+  roll  a
      |=([i=@ a=@] (add (mul a 10) i))
      (plus sid:ab)
    ::
    ::
    ::  +mon-to-num: parse 3-letter month name to number
    ::
    ++  mon-to-num
      ;~  pose
        (cold 1 (jest 'Jan'))
        (cold 2 (jest 'Feb'))
        (cold 3 (jest 'Mar'))
        (cold 4 (jest 'Apr'))
        (cold 5 (jest 'May'))
        (cold 6 (jest 'Jun'))
        (cold 7 (jest 'Jul'))
        (cold 8 (jest 'Aug'))
        (cold 9 (jest 'Sep'))
        (cold 10 (jest 'Oct'))
        (cold 11 (jest 'Nov'))
        (cold 12 (jest 'Dec'))
      ==
    ::
    ++  sanitize
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
          ?:  =(':' i.t)  ['_' $(t t.t)]
          [i.t $(t t.t)]
        ?:  =(3 s)
          ?:  =('>' i.t)   [i.t $(t t.t, s 0)]
          ?:  =('"' i.t)   [i.t $(t t.t, s 4)]
          ?:  =('\'' i.t)  [i.t $(t t.t, s 5)]
          ?:  =('-' i.t)   ['_' $(t t.t)]
          ?:  ?|  =(' ' i.t)  =(10 i.t)  ==
            =/  rest=tape  t.t
            |-  ^-  tape
            ?~  rest  [' ' ~]
            ?:  ?|  =(' ' i.rest)  =(10 i.rest)  ==  $(rest t.rest)
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
      (crip (fix-hyphens (strip-ns-attrs no-pis)))
    ::
    ::  +strip-ns-attrs: remove xmlns: and xml: attributes from tag bodies
    ::
    ::    de-xml:html's +name parser rejects colons, so attributes like
    ::    xmlns:dc="..." or xml:lang="en" on the root element cause parse
    ::    failure.  strips only these two prefixes before handing off.
    ::
    ++  strip-ns-attrs
      |=  in=tape
      ^-  tape
      ::  state: 0=text 1=tag-name 2=tag-body 3=dquote 4=squote
      =/  s=@ud  0
      |-
      ?~  in  ~
      ?:  =(0 s)
        ?.  =('<' i.in)  [i.in $(in t.in)]
        [i.in $(in t.in, s 1)]
      ?:  =(1 s)
        ?:  =('>' i.in)   [i.in $(in t.in, s 0)]
        ?:  =(' ' i.in)   [i.in $(in t.in, s 2)]
        [i.in $(in t.in)]
      ?:  =(2 s)
        ?:  =('>' i.in)   [i.in $(in t.in, s 0)]
        ?:  =('"' i.in)   [i.in $(in t.in, s 3)]
        ?:  =('\'' i.in)  [i.in $(in t.in, s 4)]
        ?:  (starts-with in "xmlns:")  $(in (skip-ns-attr in))
        ?:  (starts-with in "xml:")    $(in (skip-ns-attr in))
        [i.in $(in t.in)]
      ?:  =(3 s)
        ?:  =('"' i.in)   [i.in $(in t.in, s 2)]
        [i.in $(in t.in)]
      ?:  =(4 s)
        ?:  =('\'' i.in)  [i.in $(in t.in, s 2)]
        [i.in $(in t.in)]
      [i.in $(in t.in)]
    ::
    ::  +starts-with: check if hay begins with needle, char by char
    ::
    ++  starts-with
      |=  [hay=tape needle=tape]
      ^-  ?
      ?~  needle  %.y
      ?~  hay     %.n
      ?.  =(i.hay i.needle)  %.n
      $(hay t.hay, needle t.needle)
    ::
    ::  +skip-ns-attr: consume name=value, return tape after closing quote
    ::
    ++  skip-ns-attr
      |=  in=tape
      ^-  tape
      ::  advance past =
      =/  t=tape
        |-  ^-  tape
        ?~  in  ~
        ?:  =('=' i.in)  t.in
        $(in t.in)
      ::  skip the quoted value
      ?~  t  ~
      ?:  =('"' i.t)
        =/  rest=tape  t.t
        |-  ^-  tape
        ?~  rest  ~
        ?:  =('"' i.rest)  t.rest
        $(rest t.rest)
      ?:  =('\'' i.t)
        =/  rest=tape  t.t
        |-  ^-  tape
        ?~  rest  ~
        ?:  =('\'' i.rest)  t.rest
        $(rest t.rest)
      t
    --
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
=/  xml
  %-  de-xml:html
  %-  sanitize
  `@t`q.data.u.full-file.client-response.q.response
::
?~  xml
  ~&  >>>  %ted-rss-atom
  ~&  >>>  %failed-to-parse-xml
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
    %+  murn
      %+  skip
        c.i.-.document
      |=  =manx
      ^-  ?
      ?|  =(n.g.manx %item)
          =(n.g.manx %items)
      ==
    |=  =manx
    ^-  (unit channel-element:rss:ra)
    =*  tag  n.g.manx
    =*  val  (crip v:(head a.g:(head c.manx)))
    ?+  tag  ~
    ::
      %docs         `[tag val]
      %link         `[tag val]
      %title        `[tag val]
      %rating       `[tag val]
      %language     `[tag val]
      %copyright    `[tag val]
      %generator    `[tag val]
      %description  `[tag val]
    ::
        %'pubDate'
      `[%pub-date (need (parse-rfc2822 val))]
    ::
        %'lastBuildDate'
      `[%last-build-date (need (parse-rfc2822 val))]
    ::
        %'managingEditor'  ~
        %'webMaster'       ~
        %category          ~
        %ttl               ~
        %'textInput'       ~
        %cloud             ~
        %image             ~
        %'skipDays'        ~
        %'skipHours'       ~
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
      `[%updated (need (parse-iso8601 (get-text child)))]
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
