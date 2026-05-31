::
:: read an rss item and return a typed rss-item
::
/-  spider, *rss-atom
/+  *strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=>  |%
    ++  get-text
      |=  node=manx
      ^-  @t
      (crip v:(head a.g:(head c.node)))
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
    --
::
=/  item  !<(manx arg)
::
::  extract text content of an element's first text child
::  manx text nodes: [g=[n=%$ a=~[[n=%$ v="..."]]] c=~]
::
::
::  look up an attribute value on a manx node by name
::
=/  get-attr
  |=  [node=manx name=@tas]
  ^-  (unit tape)
  %-  ~(get by (malt (turn a.g.node |=(a=[n=mane v=tape] [n.a v.a]))))
  name
::
::  parse each child element into a typed item-element
::  murn skips unrecognized or malformed tags
::
=/  elems=(list item-element:rss)
  %+  murn
    c.item
  |=  child=manx
  ^-  (unit item-element:rss)
  =*  tag  n.g.child
  ::
  ::  skip text nodes
  ?:  =(%$ tag)  ~
  ::
  ?+  tag  ~
    ::
    %title        `[%title (get-text child)]
    %link         `[%link (get-text child)]
    %description  `[%description (get-text child)]
    %author       `[%author (get-text child)]
    %comments     `[%comments (get-text child)]
    ::
    %category
      =/  domain=(unit @t)
        %+  biff
          (get-attr child 'domain')
        |=(t=tape `(crip t))
      `[%category domain (get-text child)]
    ::
    %enclosure
      ::  all values are attributes: url, length, type
      =/  url-tape   (get-attr child 'url')
      =/  len-tape   (get-attr child 'length')
      =/  type-tape  (get-attr child 'type')
      ?~  url-tape   ~
      ?~  len-tape   ~
      ?~  type-tape  ~
      =/  url=@t   (crip u.url-tape)
      =/  len=@ud  (rash (crip u.len-tape) dem)
      =/  typ=@t   (crip u.type-tape)
      `[%enclosure url len typ]
    ::
    %guid
      =/  is-permalink=(unit @t)
        %+  biff
          (get-attr child 'isPermaLink')
        |=(t=tape `(crip t))
      `[%guid is-permalink (get-text child)]
    ::
    %'pubDate'
      `[%pub-date (need (parse-rfc2822 (get-text child)))]
    ::
    %source
      =/  url=(unit @t)
        %+  biff
          (get-attr child 'url')
        |=(t=tape `(crip t))
      ?~  url  ~
      `[%source u.url (get-text child)]
    ::
  ==
::
%-  pure:m
!>  ^-  item:rss
[%item elems]
