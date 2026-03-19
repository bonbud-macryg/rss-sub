/-  ra=rss-atom
=,  format
|_  =item:rss:ra
++  grab
  |%
  ++  noun  item:rss:ra
  --
++  grow
  |%
  ++  noun  item
  ++  json
    |^
    a+(turn p.item elem-to-json)
    ::
    ++  unit-cord
      |=  u=(unit @t)
      ^-  ^json
      ?~  u  s+''  s+u.u
    ::
    ++  elem-to-json
      |=  e=item-element:rss:ra
      ^-  ^json
      ?-  -.e
        %title       (pairs:enjs ~[['type' s+'title'] ['value' s+p.e]])
        %link        (pairs:enjs ~[['type' s+'link'] ['value' s+p.e]])
        %description  (pairs:enjs ~[['type' s+'description'] ['value' s+p.e]])
        %author      (pairs:enjs ~[['type' s+'author'] ['value' s+p.e]])
        %comments    (pairs:enjs ~[['type' s+'comments'] ['value' s+p.e]])
        %pub-date    (pairs:enjs ~[['type' s+'pub-date'] ['value' (sect:enjs p.e)]])
        %category
          %-  pairs:enjs
          :~  ['type' s+'category']
              ['domain' (unit-cord p.e)]
              ['value' s+q.e]
          ==
        %enclosure
          %-  pairs:enjs
          :~  ['type' s+'enclosure']
              ['url' s+p.e]
              ['length' n+(scot %ud q.e)]
              ['mime' s+r.e]
          ==
        %guid
          %-  pairs:enjs
          :~  ['type' s+'guid']
              ['is-perma-link' (unit-cord p.e)]
              ['value' s+q.e]
          ==
        %source
          %-  pairs:enjs
          :~  ['type' s+'source']
              ['url' s+p.e]
              ['value' s+q.e]
          ==
      ==
    --
  --
++  grad  %noun
--
