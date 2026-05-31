/-  ra=rss-atom
=,  format
|_  channel=channel:rss:ra
++  grab
  |%
  ++  noun  channel:rss:ra
  --
++  grow
  |%
  ++  noun  channel
  ++  json
    |^
    %-  pairs:enjs
    :~  ['title' s+(get-title channel)]
        ['elements' a+(turn elems.channel elem-to-json)]
        ['items' a+(turn ~(tap in items.channel) item-to-json)]
    ==
    ::
    ++  get-title
      |=  =channel:rss:ra
      ^-  @t
      =/  t  (murn elems.channel |=(e=channel-element:rss:ra ?.(?=([%title *] e) ~ `p.e)))
      ?~  t  ''  i.t
    ::
    ++  unit-cord
      |=  u=(unit @t)
      ^-  ^json
      ?~  u  s+''  s+u.u
    ::
    ++  elem-to-json
      |=  e=channel-element:rss:ra
      ^-  ^json
      ?-  -.e
        %title            (pairs:enjs ~[['type' s+'title'] ['value' s+p.e]])
        %link             (pairs:enjs ~[['type' s+'link'] ['value' s+p.e]])
        %description      (pairs:enjs ~[['type' s+'description'] ['value' s+p.e]])
        %language         (pairs:enjs ~[['type' s+'language'] ['value' s+p.e]])
        %pub-date         (pairs:enjs ~[['type' s+'pub-date'] ['value' (sect:enjs p.e)]])
        %last-build-date  (pairs:enjs ~[['type' s+'last-build-date'] ['value' (sect:enjs p.e)]])
        %docs             (pairs:enjs ~[['type' s+'docs'] ['value' s+p.e]])
        %generator        (pairs:enjs ~[['type' s+'generator'] ['value' s+p.e]])
        %managing-editor  (pairs:enjs ~[['type' s+'managing-editor'] ['value' s+p.e]])
        %web-master       (pairs:enjs ~[['type' s+'web-master'] ['value' s+p.e]])
        %copyright        (pairs:enjs ~[['type' s+'copyright'] ['value' s+p.e]])
        %rating           (pairs:enjs ~[['type' s+'rating'] ['value' s+p.e]])
        %ttl              (pairs:enjs ~[['type' s+'ttl'] ['value' n+(scot %ud p.e)]])
        %category
          %-  pairs:enjs
          :~  ['type' s+'category']
              ['domain' (unit-cord p.e)]
              ['value' s+q.e]
          ==
        %image
          %-  pairs:enjs
          :~  ['type' s+'image']
              ['url' s+p.e]
              ['title' s+q.e]
              ['link' s+r.e]
          ==
        %text-input
          %-  pairs:enjs
          :~  ['type' s+'text-input']
              ['title' s+p.e]
              ['description' s+q.e]
              ['name' s+r.e]
              ['link' s+s.e]
          ==
        %cloud
          %-  pairs:enjs
          :~  ['type' s+'cloud']
              ['domain' s+p.e]
              ['port' n+(scot %ud q.e)]
              ['path' s+r.e]
              ['register-procedure' s+s.e]
              ['protocol' s+t.e]
          ==
        %skip-days   (pairs:enjs ~[['type' s+'skip-days'] ['value' a+(turn p.e |=(d=@t ^-(^json s+d)))]])
        %skip-hours  (pairs:enjs ~[['type' s+'skip-hours'] ['value' a+(turn p.e |=(h=@ud ^-(^json n+(scot %ud h))))]])
      ==
    ::
    ++  item-to-json
      |=  =item:rss:ra
      ^-  ^json
      a+(turn p.item item-elem-to-json)
    ::
    ++  item-elem-to-json
      |=  e=item-element:rss:ra
      ^-  ^json
      ?-  -.e
        %title        (pairs:enjs ~[['type' s+'title'] ['value' s+p.e]])
        %link         (pairs:enjs ~[['type' s+'link'] ['value' s+p.e]])
        %description  (pairs:enjs ~[['type' s+'description'] ['value' s+p.e]])
        %author       (pairs:enjs ~[['type' s+'author'] ['value' s+p.e]])
        %comments     (pairs:enjs ~[['type' s+'comments'] ['value' s+p.e]])
        %pub-date     (pairs:enjs ~[['type' s+'pub-date'] ['value' (sect:enjs p.e)]])
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
