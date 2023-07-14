/-  *rss
|%
+$  rss-refresh  @dr
+$  rss-state    (map url rss-channel)
::
+$  sub-action
  $%  [%add-rss-feed =url]
      [%del-rss-feed =url]
      [%rss-refresh url=(unit @t)]
      [%set-rss-refresh refresh=@dr]
  ==
--
