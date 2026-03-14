::
:: read an atom entry and return a typed atom-entry
::
/-  spider, ra=rss-atom
/+  *strandio
=,  strand=strand:spider
^-  thread:spider
=>  |%
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
    --
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::
=/  entry  !<(manx arg)
::
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
=/  elems=(list entry-element:atom:ra)
  %+  murn
    c.entry
  |=  child=manx
  ^-  (unit entry-element:atom:ra)
  =*  tag  n.g.child
  ?:  =(%$ tag)  ~
  ?+  tag  ~
    %id         `[%id (get-text child)]
    %title      `[%title (get-text child)]
    %summary    `[%summary (get-text child)]
    %rights     `[%rights (get-text child)]
    %contributor  `[%contributor (get-text child)]
    ::
    %updated
      `[%updated (need (parse-iso8601 (get-text child)))]
    ::
    %published
      `[%published (need (parse-iso8601 (get-text child)))]
    ::
    %author
      =/  name-node=(unit manx)
        =/  matches  (skim c.child |=(m=manx =(n.g.m %name)))
        ?~  matches  ~
        `i.matches
      ?~  name-node  ~
      `[%author (get-text u.name-node)]
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
    %content
      =/  typ=(unit tape)   (get-attr child 'type')
      =/  src=(unit tape)   (get-attr child 'src')
      =/  text=(unit @t)
        ?~  c.child  ~
        `(get-text child)
      `[%content (bind typ crip) (bind src crip) text]
    ::
  ==
::
%-  pure:m
!>  ^-  entry:atom:ra
[%entry elems]
