/-  ra=rss-atom
|%
+$  updated  @da                                       ::  last update
+$  feed     (each channel:rss:ra feed:atom:ra)        ::  RSS/Atom
+$  feeds    (map link:ra (pair updated (unit feed)))  ::  URLs and feeds
::
+$  rss-sub-action
  $%  [%add-feed =link:ra]
      [%del-feed =link:ra]
      [%refresh-now link=(unit link:ra)]
  ==
--
