/-  ra=rss-atom
/$  item-to-json   %rss-item  %json
/$  entry-to-json  %atom-entry  %json
|_  it=(each (set item:rss:ra) (set entry:atom:ra))
++  grab
  |%
  ++  noun  (each (set item:rss:ra) (set entry:atom:ra))
  --
++  grow
  |%
  ++  noun  it
  ++  json
    ?-  -.it
      %&  [%a (turn ~(tap in p.it) item-to-json)]
      %|  [%a (turn ~(tap in p.it) entry-to-json)]
    ==
  --
++  grad  %noun
--
