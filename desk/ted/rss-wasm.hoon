::  One-shot UrWasm binding for the RSS parser ABI.
/-  spider, ra=rss-atom
/+  wasm=wasm-lia
/*  rss-parser  %wasm  /wasm/rss-parser/wasm
=,  strand=strand:spider
=>  |%
    +$  wasm-result  [kind=@ud payload=octs]
    ++  read-u32
      |=  [pos=@ data=@]
      ^-  [value=@ pos=@]
      [(cut 3 [pos 4] data) (add pos 4)]
    ++  read-text
      |=  [pos=@ data=@]
      ^-  [value=@t pos=@]
      =/  [length=@ pos=@]  (read-u32 pos data)
      [`@t`(cut 3 [pos length] data) (add pos length)]
    ++  parse-rfc2822
      |=  dat=@t
      ^-  (unit @da)
      =/  t=tape  (trip dat)
      =/  t=tape
        =/  comma  (find "," t)
        ?~  comma  t
        (slag +(+(u.comma)) t)
      =.  t
        |-
        ?~  t  t
        ?:  =(' ' i.t)  $(t t.t)
        t
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
      =/  [dy=@ud mn=@ud yr=@ud hr=@ud mi=@ud sc=@ud]  u.parsed
      `(year [[%.y yr] mn [dy hr mi sc ~]])
    ++  parse-iso8601
      |=  dat=@t
      ^-  (unit @da)
      ?:  =('' dat)  ~
      =/  t=tape  (trip dat)
      =/  parsed
        %+  rust  t
        ;~  sfix
          ;~  plug
            digits
            ;~(pfix hep digits)
            ;~(pfix hep digits)
            ;~(pfix ;~(pose (jest 'T') ace) digits)
            ;~(pfix col digits)
            ;~(pfix col digits)
          ==
          (star next)
        ==
      ?~  parsed  ~
      =/  [yr=@ud mn=@ud dy=@ud hr=@ud mi=@ud sc=@ud]  u.parsed
      `(year [[%.y yr] mn [dy hr mi sc ~]])
    ++  parse-date
      |=  dat=@t
      ^-  (unit @da)
      =/  iso  (parse-iso8601 dat)
      ?^  iso  iso
      (parse-rfc2822 dat)
    ++  digits
      %+  cook
        |=  a=(list @)
      %+  roll  a
      |=([i=@ a=@] (add (mul a 10) i))
      (plus sid:ab)
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
    ++  text-unit
      |=  value=@t
      ^-  (unit @t)
      ?:  =('' value)  ~
      `value
    ++  numb-unit
      |=  value=@t
      ^-  (unit numb:ra)
      ?:  =('' value)  ~
      `(rash value dem)
    ++  atom-ref-unit
      |=  value=@t
      ^-  (unit ref:atom:ra)
      ?:  =('' value)  ~
      ?:  =('alternate' value)  `%alternate
      ?:  =('enclosure' value)  `%enclosure
      ?:  =('related' value)  `%related
      ?:  =('self' value)  `%self
      ?:  =('via' value)  `%via
      `value
    ++  read-values
      |=  [count=@ pos=@ data=@]
      ^-  (unit [(list @t) @])
      ?:  =(0 count)
        `[~ pos]
      ?:  (gth (add pos 4) (met 3 data))
        ~
      =/  [value=@t pos=@]  (read-text pos data)
      =/  tail=(unit [(list @t) @])
        $(count (sub count 1), pos pos)
      ?~  tail
        ~
      =/  [values=(list @t) end=@]  u.tail
      `[[value values] end]
    ++  skip-values
      |=  [count=@ pos=@ data=@]
      ^-  (unit @)
      ?:  =(0 count)
        `pos
      ?:  (gth (add pos 4) (met 3 data))
        ~
      =/  length=@  (cut 3 [pos 4] data)
      =/  next=@  (add (add pos 4) length)
      ?:  (gth next (met 3 data))
        ~
      $(count (sub count 1), pos next)
    ++  skip-records
      |=  [pos=@ data=@]
      ^-  (unit @)
      ?:  =(pos (met 3 data))
        `pos
      ?:  (gth (add pos 4) (met 3 data))
        ~
      =/  count=@  (cut 3 [(add pos 2) 1] data)
      =/  next=(unit @)  (skip-values count (add pos 8) data)
      ?~  next
        ~
      $(pos u.next)
    ++  rss-channel-records
      |=  [pos=@ data=@]
      ^-  (unit [(list channel-element:rss:ra) @])
      ?:  =(pos (met 3 data))
        `[~ pos]
      ?:  (gth (add pos 8) (met 3 data))
        ~
      =/  scope=@  (cut 3 [pos 1] data)
      =/  tag=@  (cut 3 [(add pos 1) 1] data)
      =/  count=@  (cut 3 [(add pos 2) 1] data)
      ?:  !=(1 scope)
        `[~ pos]
      =/  start=@  (add pos 8)
      =/  next=(unit @)  (skip-values count start data)
      ?~  next
        ~
      =/  tail=(unit [(list channel-element:rss:ra) @])
        $(pos u.next)
      ?~  tail
        ~
      =/  [elems=(list channel-element:rss:ra) end=@]  u.tail
      ?:  !=(1 scope)
        `[elems end]
      =/  values-tagged=(unit [(list @t) @])  (read-values count start data)
      ?~  values-tagged
        ~
      =/  [values=(list @t) _=@]  u.values-tagged
      ?~  values
        `[elems end]
      =/  value=@t  i.values
      =/  elem=(unit channel-element:rss:ra)
        ?:  =(3 tag)  `[%description value]
        ?:  =(4 tag)  `[%language value]
        ?:  =(5 tag)
          =/  date=(unit @da)  (parse-rfc2822 value)
          ?~  date  ~
          `[%pub-date u.date]
        ?:  =(6 tag)
          =/  date=(unit @da)  (parse-rfc2822 value)
          ?~  date  ~
          `[%last-build-date u.date]
        ?:  =(7 tag)  `[%docs value]
        ?:  =(8 tag)  `[%generator value]
        ?:  =(9 tag)  `[%managing-editor value]
        ?:  =(10 tag)  `[%web-master value]
        ?:  =(11 tag)  `[%copyright value]
        ?:  =(12 tag)
          ?~  t.values  ~
          `[%category (text-unit value) i.t.values]
        ?:  =(13 tag)  `[%ttl (rash value dem)]
        ?:  =(14 tag)  `[%rating value]
        ~
      ?~  elem
        `[elems end]
      =/  elem-list=(list channel-element:rss:ra)
        :~  u.elem
        ==
      `[(weld elem-list elems) end]
    ++  atom-feed-records
      |=  [pos=@ data=@]
      ^-  (unit [(list feed-element:atom:ra) @])
      ?:  =(pos (met 3 data))
        `[~ pos]
      ?:  (gth (add pos 8) (met 3 data))
        ~
      =/  scope=@  (cut 3 [pos 1] data)
      =/  tag=@  (cut 3 [(add pos 1) 1] data)
      =/  count=@  (cut 3 [(add pos 2) 1] data)
      ?:  !=(3 scope)
        `[~ pos]
      =/  start=@  (add pos 8)
      =/  next=(unit @)  (skip-values count start data)
      ?~  next
        ~
      =/  tail=(unit [(list feed-element:atom:ra) @])
        $(pos u.next)
      ?~  tail
        ~
      =/  [elems=(list feed-element:atom:ra) end=@]  u.tail
      =/  values-tagged=(unit [(list @t) @])  (read-values count start data)
      ?~  values-tagged
        ~
      =/  [values=(list @t) _=@]  u.values-tagged
      ?~  values
        `[elems end]
      =/  value=@t  i.values
      =/  elem=(unit feed-element:atom:ra)
        ?:  =(1 tag)  `[%id value]
        ?:  =(3 tag)
          =/  date=(unit @da)  (parse-iso8601 value)
          ?~  date  ~
          `[%updated u.date]
        ?:  =(4 tag)  `[%author value ~ ~]
        ?:  =(5 tag)
          ?~  t.values  ~
          =/  scheme=@t  i.t.values
          =/  rest=(list @t)  t.t.values
          ?~  rest  ~
          `[%category value (text-unit scheme) (text-unit i.rest)]
        ?:  =(6 tag)  `[%contributor value]
        ?:  =(8 tag)  `[%icon value]
        ?:  =(9 tag)  `[%logo value]
        ?:  =(10 tag)  `[%rights value]
        ?:  =(11 tag)  `[%subtitle value]
        ?:  =(12 tag)
          ?~  t.values  ~
          =/  rel=@t  i.t.values
          =/  rest=(list @t)  t.t.values
          ?~  rest  ~
          =/  typ=@t  i.rest
          =/  rest=(list @t)  t.rest
          ?~  rest  ~
          =/  lang=@t  i.rest
          =/  rest=(list @t)  t.rest
          ?~  rest  ~
          =/  title=@t  i.rest
          =/  rest=(list @t)  t.rest
          ?~  rest  ~
          `[%link value (atom-ref-unit rel) (text-unit typ) (text-unit lang) (text-unit title) (numb-unit i.rest)]
        ~
      ?~  elem
        `[elems end]
      =/  elem-list=(list feed-element:atom:ra)
        :~  u.elem
        ==
      `[(weld elem-list elems) end]
    ++  rss-item-records
      |=  [pos=@ data=@]
      ^-  (unit [(list [owner=@ tag=@ values=(list @t)]) @])
      ?:  =(pos (met 3 data))
        `[~ pos]
      ?:  (gth (add pos 8) (met 3 data))
        ~
      =/  scope=@  (cut 3 [pos 1] data)
      =/  tag=@  (cut 3 [(add pos 1) 1] data)
      =/  count=@  (cut 3 [(add pos 2) 1] data)
      =/  owner=@  (cut 3 [(add pos 4) 4] data)
      =/  start=@  (add pos 8)
      =/  next=(unit @)  (skip-values count start data)
      ?~  next
        ~
      =/  tail=(unit [(list [owner=@ tag=@ values=(list @t)]) @])
        $(pos u.next)
      ?~  tail
        ~
      =/  [records=(list [owner=@ tag=@ values=(list @t)]) end=@]  u.tail
      ?:  !=(2 scope)
        `[records end]
      =/  values-tagged=(unit [(list @t) @])  (read-values count start data)
      ?~  values-tagged
        ~
      =/  [values=(list @t) _=@]  u.values-tagged
      `[[[owner tag values] records] end]
    ++  rss-item-extras
      |=  [records=(list [owner=@ tag=@ values=(list @t)]) owner=@]
      ^-  (list item-element:rss:ra)
      ?~  records
        ~
      =/  [record-owner=@ tag=@ values=(list @t)]  i.records
      =/  tail=(list item-element:rss:ra)  $(records t.records)
      ?~  values
        tail
      =/  value=@t  i.values
      ?:  =(owner record-owner)
        ?:  =(4 tag)
          [[%author value] tail]
        ?:  =(5 tag)
          ?~  t.values  tail
          [[%category (text-unit value) i.t.values] tail]
        ?:  =(6 tag)
          [[%comments value] tail]
        ?:  =(7 tag)
          ?~  t.values  tail
          =/  length=@t  i.t.values
          =/  rest=(list @t)  t.t.values
          ?~  rest  tail
          [[%enclosure value (rash length dem) i.rest] tail]
        ?:  =(8 tag)
          ?~  t.values  tail
          [[%guid (text-unit value) i.t.values] tail]
        ?:  =(9 tag)
          =/  date=(unit @da)  (parse-rfc2822 value)
          ?~  date  tail
          [[%pub-date u.date] tail]
        ?:  =(10 tag)
          ?~  t.values  tail
          ?:  =('' value)
            tail
          [[%source value i.t.values] tail]
        tail
      tail
    ++  add-rss-item-records
      |=  [items=(list item:rss:ra) records=(list [owner=@ tag=@ values=(list @t)]) owner=@]
      ^-  (list item:rss:ra)
      ?~  items
        ~
      =/  [%item elems=(list item-element:rss:ra)]  i.items
      =/  extras=(list item-element:rss:ra)  (rss-item-extras records owner)
      =/  tail=(list item:rss:ra)  $(items t.items, owner (add owner 1))
      [[%item (weld elems extras)] tail]
    ++  atom-entry-records
      |=  [pos=@ data=@]
      ^-  (unit [(list [owner=@ tag=@ values=(list @t)]) @])
      ?:  =(pos (met 3 data))
        `[~ pos]
      ?:  (gth (add pos 8) (met 3 data))
        ~
      =/  scope=@  (cut 3 [pos 1] data)
      =/  tag=@  (cut 3 [(add pos 1) 1] data)
      =/  count=@  (cut 3 [(add pos 2) 1] data)
      =/  owner=@  (cut 3 [(add pos 4) 4] data)
      =/  start=@  (add pos 8)
      =/  next=(unit @)  (skip-values count start data)
      ?~  next
        ~
      ?:  !=(4 scope)
        `[~ pos]
      =/  values-tagged=(unit [(list @t) @])  (read-values count start data)
      ?~  values-tagged
        ~
      =/  [values=(list @t) _=@]  u.values-tagged
      =/  tail=(unit [(list [owner=@ tag=@ values=(list @t)]) @])
        $(pos u.next)
      ?~  tail
        `[[[owner tag values] ~] u.next]
      =/  [records=(list [owner=@ tag=@ values=(list @t)]) end=@]  u.tail
      `[[[owner tag values] records] end]
    ++  atom-entry-extras
      |=  [records=(list [owner=@ tag=@ values=(list @t)]) owner=@]
      ^-  (list entry-element:atom:ra)
      ?~  records
        ~
      =/  [record-owner=@ tag=@ values=(list @t)]  i.records
      =/  tail=(list entry-element:atom:ra)  $(records t.records)
      ?~  values
        tail
      =/  value=@t  i.values
      ?:  =(owner record-owner)
        ?:  =(3 tag)
          =/  date=(unit @da)  (parse-date value)
          ?~  date  tail
          [[%updated u.date] tail]
        ?:  =(4 tag)
          [[%author value] tail]
        ?:  =(5 tag)
          ?~  t.values  tail
          =/  scheme=@t  i.t.values
          =/  rest=(list @t)  t.t.values
          ?~  rest  tail
          [[%category value (text-unit scheme) (text-unit i.rest)] tail]
        ?:  =(6 tag)
          [[%contributor value] tail]
        ?:  =(7 tag)
          =/  date=(unit @da)  (parse-date value)
          ?~  date  tail
          [[%published u.date] tail]
        ?:  =(8 tag)
          [[%rights value] tail]
        ?:  =(11 tag)
          ?~  t.values  tail
          =/  src=@t  i.t.values
          =/  rest=(list @t)  t.t.values
          ?~  rest  tail
          [[%content (text-unit value) (text-unit src) (text-unit i.rest)] tail]
        ?:  =(12 tag)
          ?~  t.values  tail
          =/  rel=@t  i.t.values
          =/  rest=(list @t)  t.t.values
          ?~  rest  tail
          =/  typ=@t  i.rest
          =/  rest=(list @t)  t.rest
          ?~  rest  tail
          =/  lang=@t  i.rest
          =/  rest=(list @t)  t.rest
          ?~  rest  tail
          =/  title=@t  i.rest
          =/  rest=(list @t)  t.rest
          ?~  rest  tail
          [[%link value (atom-ref-unit rel) (text-unit typ) (text-unit lang) (text-unit title) (numb-unit i.rest)] tail]
        tail
      tail
    ++  add-atom-entry-records
      |=  [entries=(list entry:atom:ra) records=(list [owner=@ tag=@ values=(list @t)]) owner=@]
      ^-  (list entry:atom:ra)
      ?~  entries
        ~
      =/  [%entry elems=(list entry-element:atom:ra)]  i.entries
      =/  extras=(list entry-element:atom:ra)  (atom-entry-extras records owner)
      =/  tail=(list entry:atom:ra)  $(entries t.entries, owner (add owner 1))
      [[%entry (weld elems extras)] tail]
    ++  rss-items
      |=  [count=@ pos=@ data=@]
      ^-  [(list item:rss:ra) pos=@]
      ?:  =(0 count)
        [~ pos]
      =/  [title=@t pos=@]  (read-text pos data)
      =/  [link=@t pos=@]  (read-text pos data)
      =/  [description=@t pos=@]  (read-text pos data)
      =/  [guid=@t pos=@]  (read-text pos data)
      =/  elems=(list item-element:rss:ra)
        :~  [%title title]
            [%link link]
            [%description description]
            [%guid ~ guid]
        ==
      =/  [tail=(list item:rss:ra) pos=@]
        $(count (sub count 1), pos pos)
      [[[%item elems] tail] pos]
    ++  atom-entries
      |=  [count=@ pos=@ data=@]
      ^-  [(list entry:atom:ra) pos=@]
      ?:  =(0 count)
        [~ pos]
      =/  [title=@t pos=@]  (read-text pos data)
      =/  [link=@t pos=@]  (read-text pos data)
      =/  [summary=@t pos=@]  (read-text pos data)
      =/  [id=@t pos=@]  (read-text pos data)
      =/  elems=(list entry-element:atom:ra)
        :~  [%title title]
            [%id id]
            [%link link ~ ~ ~ ~ ~]
            [%summary summary]
        ==
      =/  [tail=(list entry:atom:ra) pos=@]
        $(count (sub count 1), pos pos)
      [[[%entry elems] tail] pos]
    ++  decode
      |=  [kind=@ payload=octs]
      ^-  (unit result)
      =/  [title=@t pos=@]  (read-text 0 q.payload)
      =/  [link=@t pos=@]  (read-text pos q.payload)
      =/  [count=@ pos=@]  (read-u32 pos q.payload)
      ?:  =(1 kind)
        =/  [items=(list item:rss:ra) pos=@]  (rss-items count pos q.payload)
        =/  tagged=(unit [(list channel-element:rss:ra) @])  (rss-channel-records pos q.payload)
        ?~  tagged  ~
        =/  [tagged-elems=(list channel-element:rss:ra) tagged-end=@]  u.tagged
        =/  item-records=(unit [(list [owner=@ tag=@ values=(list @t)]) @])  (rss-item-records tagged-end q.payload)
        ?~  item-records  ~
        =/  [item-record-list=(list [owner=@ tag=@ values=(list @t)]) item-record-end=@]  u.item-records
        ?.  =(p.payload item-record-end)  ~
        =/  items-with-records=(list item:rss:ra)
          (add-rss-item-records items item-record-list 0)
        =/  channel=(list channel-element:rss:ra)
          :~  [%title title]
              [%link link]
          ==
        `[%rss link (weld channel tagged-elems) items-with-records]
      ?:  =(2 kind)
        =/  [entries=(list entry:atom:ra) pos=@]  (atom-entries count pos q.payload)
        =/  tagged=(unit [(list feed-element:atom:ra) @])  (atom-feed-records pos q.payload)
        ?~  tagged  ~
        =/  [tagged-elems=(list feed-element:atom:ra) tagged-end=@]  u.tagged
        =/  entry-records=(unit [(list [owner=@ tag=@ values=(list @t)]) @])  (atom-entry-records tagged-end q.payload)
        ?~  entry-records  ~
        =/  [entry-record-list=(list [owner=@ tag=@ values=(list @t)]) _=@]  u.entry-records
        =/  entries-with-records=(list entry:atom:ra)
          (add-atom-entry-records entries entry-record-list 0)
        =/  feed=(list feed-element:atom:ra)
          :~  [%title title]
              [%link link ~ ~ ~ ~ ~]
          ==
        `[%atom link (weld feed tagged-elems) entries-with-records]
      ~
    +$  result
      $%  [%rss =link:ra channel=(list channel-element:rss:ra) items=(list item:rss:ra)]
          [%atom =link:ra feed=(list feed-element:atom:ra) entries=(list entry:atom:ra)]
      ==
    --
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  [source=link:ra body=@t known=(list link:ra)]  !<([link:ra @t (list link:ra)] arg)
=/  body-len=@  (met 3 body)
=/  known-len=@
  %+  roll  known
  |=  [url=@t len=@]
  :(add len 4 (met 3 url))
=.  known-len  (add 4 known-len)
=/  known-blob=@
  %+  can  3
  :-  [4 (lent known)]
  %-  zing
  %+  turn  known
  |=  url=@t
  ^-  (list [@ @])
  ~[[4 (met 3 url)] [(met 3 url) url]]
=/  parsed=(unit wasm-result)
  %-  yield-need:wasm  =<  -
  %^  (run-once:wasm (unit wasm-result) vase)  [rss-parser *vase^~]  %$
  =/  m  (script:lia-sur:wasm (unit wasm-result) vase)
  =/  arr  (arrows:wasm vase)
  =,  arr
  ;<  in=@      try:m  (call-1 '__wbindgen_malloc' body-len 1 ~)
  ?>  (gth in 0)
  ;<  *         try:m  (memwrite in body-len body)
  ;<  kin=@     try:m  (call-1 '__wbindgen_malloc' known-len 4 ~)
  ?>  (gth kin 0)
  ;<  *         try:m  (memwrite kin known-len known-blob)
  ;<  out=@     try:m  (call-1 'parse_feed' in body-len kin known-len ~)
  ;<  output-length=@  try:m  (call-1 'parse_feed_len' ~)
  ?>  (gte output-length 16)
  ;<  header=octs  try:m  (memread out 16)
  ?>  =(16 p.header)
  ?>  =('RSSW' (cut 3 [0 4] q.header))
  ?>  =(1 (cut 3 [4 1] q.header))
  ?>  =(0 (cut 3 [5 1] q.header))
  ?>  =(body-len (cut 3 [8 4] q.header))
  =/  payload-length=@  (cut 3 [12 4] q.header)
  ?>  =(output-length (add 16 payload-length))
  ;<  payload=octs  try:m  (memread (add out 16) payload-length)
  (return:m (some `wasm-result`[(cut 3 [6 1] q.header) payload]))
?~  parsed  ~|(%wasm-run-returned-null !!)
=/  decoded=(unit result)  (decode kind.u.parsed payload.u.parsed)
?~  decoded  ~|(%decode-returned-null !!)
=/  res=result  u.decoded
(pure:m !>(res(link source)))
