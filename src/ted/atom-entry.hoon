::
:: read an atom entry and return a typed atom-entry
::
/-  spider, ra=rss-atom
/+  *strandio
=,  strand=strand:spider
^-  thread:spider
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
      ::  XX parse atom date to @da
      `[%updated ~2000.1.1]
    ::
    %published
      ::  XX parse atom date to @da
      `[%published ~2000.1.1]
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
