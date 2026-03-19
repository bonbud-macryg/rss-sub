/-  ra=rss-atom
=,  format
|_  =feed:atom:ra
++  grab
  |%
  ++  noun  feed:atom:ra
  --
++  grow
  |%
  ++  noun  feed
  ++  json
    |^
    %-  pairs:enjs
    :~  ['title' s+(get-title feed)]
        ['elements' a+(turn elems.feed elem-to-json)]
        ['entries' a+(turn ~(tap in entries.feed) entry-to-json)]
    ==
    ::
    ++  get-title
      |=  =feed:atom:ra
      ^-  @t
      =/  t  (murn elems.feed |=(e=feed-element:atom:ra ?.(?=([%title *] e) ~ `p.e)))
      ?~  t  ''  i.t
    ::
    ++  unit-cord
      |=  u=(unit @t)
      ^-  ^json
      ?~  u  s+''  s+u.u
    ::
    ++  elem-to-json
      |=  e=feed-element:atom:ra
      ^-  ^json
      ?-  -.e
        %id           (pairs:enjs ~[['type' s+'id'] ['value' s+p.e]])
        %title        (pairs:enjs ~[['type' s+'title'] ['value' s+p.e]])
        %updated      (pairs:enjs ~[['type' s+'updated'] ['value' (sect:enjs p.e)]])
        %rights       (pairs:enjs ~[['type' s+'rights'] ['value' s+p.e]])
        %subtitle     (pairs:enjs ~[['type' s+'subtitle'] ['value' s+p.e]])
        %icon         (pairs:enjs ~[['type' s+'icon'] ['value' s+p.e]])
        %logo         (pairs:enjs ~[['type' s+'logo'] ['value' s+p.e]])
        %contributor  (pairs:enjs ~[['type' s+'contributor'] ['value' s+p.e]])
        %author
          %-  pairs:enjs
          :~  ['type' s+'author']
              ['name' s+p.e]
              ['email' (unit-cord q.e)]
              ['uri' (unit-cord r.e)]
          ==
        %category
          %-  pairs:enjs
          :~  ['type' s+'category']
              ['term' s+p.e]
              ['scheme' (unit-cord q.e)]
              ['label' (unit-cord r.e)]
          ==
        %generator
          %-  pairs:enjs
          :~  ['type' s+'generator']
              ['uri' (unit-cord p.e)]
              ['version' (unit-cord q.e)]
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
    ::
    ++  entry-to-json
      |=  =entry:atom:ra
      ^-  ^json
      a+(turn p.entry entry-elem-to-json)
    ::
    ++  entry-elem-to-json
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
