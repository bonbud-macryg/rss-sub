/-  ra=rss-atom
=,  format
|_  entries=(list entry:atom:ra)
++  grab
  |%
  ++  noun  (list entry:atom:ra)
  --
++  grow
  |%
  ++  noun  entries
  ++  json
    |^
    a+(turn entries entry-to-json)
    ::
    ++  unit-cord
      |=  u=(unit @t)
      ^-  ^json
      ?~  u  s+''  s+u.u
    ::
    ++  entry-to-json
      |=  =entry:atom:ra
      ^-  ^json
      a+(turn +.entry elem-to-json)
    ::
    ++  elem-to-json
      |=  e=entry-element:atom:ra
      ^-  ^json
      ?-  -.e
        %id           (pairs:enjs ~[['type' s+'id'] ['value' s+p.e]])
        %title        (pairs:enjs ~[['type' s+'title'] ['value' s+p.e]])
        %updated      (pairs:enjs ~[['type' s+'updated'] ['value' (sect:enjs p.e)]])
        %author       (pairs:enjs ~[['type' s+'author'] ['name' s+p.e]])
        %summary      (pairs:enjs ~[['type' s+'summary'] ['value' s+p.e]])
        %contributor  (pairs:enjs ~[['type' s+'contributor'] ['value' s+p.e]])
        %published    (pairs:enjs ~[['type' s+'published'] ['value' (sect:enjs p.e)]])
        %rights       (pairs:enjs ~[['type' s+'rights'] ['value' s+p.e]])
        %source
          %-  pairs:enjs
          :~  ['type' s+'source']
              ['id' s+p.e]
              ['title' s+q.e]
              ['updated' (sect:enjs r.e)]
          ==
        %category
          %-  pairs:enjs
          :~  ['type' s+'category']
              ['term' s+p.e]
              ['scheme' (unit-cord q.e)]
              ['label' (unit-cord r.e)]
          ==
        %content
          %-  pairs:enjs
          :~  ['type' s+'content']
              ['mime' (unit-cord p.e)]
              ['uri' (unit-cord q.e)]
              ['text' (unit-cord r.e)]
          ==
        %link
          %-  pairs:enjs
          :~  ['type' s+'link']
              ['href' s+p.e]
              ['rel' ?~(q.e s+'' s+u.q.e)]
              ['mime' (unit-cord r.e)]
              ['lang' (unit-cord s.e)]
              ['title' (unit-cord t.e)]
          ==
      ==
    --
  --
++  grad  %noun
--
