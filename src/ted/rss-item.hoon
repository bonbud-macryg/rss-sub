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
      ::  XX parse RSS date string to @da
      `[%pub-date ~2000.1.1]
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
