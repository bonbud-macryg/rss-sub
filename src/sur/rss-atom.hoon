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
::
::  XX handle other RSS versions from before 2.0 / 2.0.1
::
::  RSS 2.X
+|  %rss-types
::
+$  rss-channel
  $:  elems=(list rss-channel-element)
      items=(list rss-item)
  ==
::
+$  rss-item
  [%item (list rss-item-element)]
::
+$  rss-item-element
  $%  [%title @t]
      [%link url]
      [%description @t]
      ::  XX check cases like 'neil.armstrong@example.com (Neil Armstrong)' from example
      [%author email]
      [%category domain=(unit url) @t]
      [%comments url]
      [%enclosure =url length=@t type=@t]
      [%guid url]
      [%pub-date time]
      [%source url @t]
  ==
::
+$  rss-channel-element
  $%  [%title @t]
      [%link url]
      [%description @t]
      [%language @t]
      [%pub-date time]
      [%last-build-date time]
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
      [%skip-hours (set ?(%'0' %'1' %'2' %'3' %'4' %'5' %'6' %'7' %'8' %'9' %'10' %'11' %'12' %'13' %'14' %'15' %'16' %'17' %'18' %'19' %'20' %'21' %'22' %'23'))]
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
::
::  Atom 1.0
+|  %atom-types
::
+$  atom-feed
  ::  XX what about these?
  ::       <?xml version="1.0" encoding="utf-8"?>
  ::       <feed xmlns="http://www.w3.org/2005/Atom">
  $:  elems=(list atom-feed-element)
      entries=(list atom-entry)
  ==
::
+$  atom-entry
  [%entry (list atom-entry-element)]
::
+$  atom-feed-element
  $%  [%id @t]
      [%title @t]
      [%updated time]
      [%link rel=url href=url]
      [%author =name =email =uri]
      [%category @t]
      [%contributor =name]
      [%generator =uri version=@t]
      [%icon =url] 
      [%logo =url]
      [%rights @t]
      [%subtitle @t]
  ==
::
+$  atom-entry-element
  ::  XX what format is urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a?
  ::       that should be a @t type face at the top of this file
  $%  [%id @t]
      [%title @t]
      [%updated time]
      [%author name]
      [%summary @t]
      [%contributor name]
      [%published time]
      [%rights @t]
      [%source id=url title=@t updated=time]
      [%category term=@t scheme=(unit uri) label=(unit @t)]
      $:  %content
          type=@t
          src=(unit uri)
      ==
      $:  %link
          href=uri
          rel=(unit ?(uri %'alternate' %'enclosure' %'related' %'self' %'via'))
          type=@t
          hreflang=@t
          title=@t
          length=@t
      ==
  ==
--
