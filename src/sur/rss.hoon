|%
::
::  XX check none are unused here
::  XX try to fill out the rest of the raw auras
+|  %type-faces
::
+$  uri        @t
+$  url        @t
+$  name       @t
+$  email      @t
+$  timestamp  @da
::
::  RSS 2.X
+|  %rss-types
::
+$  rss-channel
  $~  [`(set rss-channel-element)`~ `(set rss-item)`~]
  $:  elems=(set rss-channel-element)
      items=(set rss-item)
  ==
::
+$  rss-item
  [%item (set rss-item-element)]
::
+$  rss-item-element
  $%  [%title @t]
      [%link url]
      [%description @t]
      [%author email]
      [%category domain=(unit url) @t]
      [%comments url]
      [%enclosure url length=@t type=@t]
      [%guid url]
      [%pub-date timestamp]
      [%source url @t]
  ==
::
+$  rss-channel-element
  $%  [%title @t]
      [%link url]
      [%description @t]
      [%language @t]
      [%pub-date timestamp]
      [%last-build-date timestamp]
      [%docs url]
      [%generator @t]
      [%managing-editor email]
      [%web-master email]
      [%copyright @t]
      [%category domain=(unit url) @t]
      [%ttl @ud]
      ::  XX find PICS rating example
      ::  [%rating !!]
      [%text-input title=@t description=@t name=@t link=url]
      [%skip-hours (set @ud)]
      [%skip-days (set ?(%'Monday' %'Tuesday' %'Wednesday' %'Thursday' %'Friday' %'Saturday' %'Sunday'))]
      $:  %cloud
          domain=url
          port=@t
          path=@t
          register-procedure=@t
          protocol=@t
      ==
      $:  %image
          =url
          title=@t
          link=url
          width=(unit @ud)
          height=(unit @ud)
          description=(unit @t)
      ==
  ==
--
