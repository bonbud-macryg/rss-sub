/-  rs=rss-sub
/+  default-agent, rss-sub
|%
+$  card  card:agent:gall
--
%-  agent:rss-sub
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %.n) bowl)
::
++  on-save   on-save:def
++  on-load   on-load:def
++  on-poke   on-poke:def
++  on-watch  on-watch:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
++  on-init
  ^-  (quip card _this)
  :_  this
  :~  :*  %pass   /update/feeds
          %agent  [our.bowl dap.bowl]
          %watch  /rss-sub/feeds
  ==  ==
::
++  on-agent
  |=  [=(pole knot) =sign:agent:gall]
  ^-  (quip card _this)
  ?+    pole  (on-agent:def pole sign)
      [%update %feeds ~]
    ?+    -.sign  (on-agent:def pole sign)
        %watch-ack
      ?~  p.sign
        %-  (slog :_(~ [%leaf "{<dap.bowl>}: waiting on /update/feeds"]))
        `this
      %-  (slog :_(~ [%leaf "{<dap.bowl>}: failed subscription on /update/feeds"]))
      `this
    ::
        %fact
      ?+    p.cage.sign  (on-agent:def pole sign)
          %rss-sub-update
        =/  upd  !<(rss-sub-update:rs q.cage.sign)
        ?-    -.upd
            %feed-added
          %-  (slog :_(~ [%leaf "{<dap.bowl>}: added feed {<link.upd>}"]))
          :_  this
          :~  :*  %pass   /update/feed/(scot %t link.upd)
                  %agent  [our.bowl dap.bowl]
                  %watch  /rss-sub/feed/(scot %t link.upd)
          ==  ==
        ::
            %feed-deleted
          %-  (slog :_(~ [%leaf "{<dap.bowl>}: deleted feed {<link.upd>}"]))
          `this
        ==
      ==
    ==
  ::
      [%update %feed link=@ta ~]
    ?+    -.sign  (on-agent:def pole sign)
        %watch-ack
      ?~  p.sign
        %-  (slog :_(~ [%leaf "{<dap.bowl>}: subscribed on /update/feed/{<(@t link.pole)>}"]))
        `this
      %-  (slog :_(~ [%leaf "{<dap.bowl>}: failed subscription on /update/feed/{<(@t link.pole)>}:"]))
      `this
    ::
        %fact
      ?+    p.cage.sign  (on-agent:def pole sign)
          %rss-item
        %-  (slog :_(~ [%leaf "{<dap.bowl>}: got item for {<(@t link.pole)>}"]))
        `this
      ::
          %atom-entry
        %-  (slog :_(~ [%leaf "{<dap.bowl>}: got entry for {<(@t link.pole)>}"]))
        `this
      ==
    ==
  ==
--
