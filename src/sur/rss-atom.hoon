|%
::
::  XX check none are unused here
::  XX try to fill out the rest of the raw auras
+|  %type-faces
::
::  XX should have a uuid type for ids, but double-check across RSS + Atom
+$  uri        @t
+$  url        @t
+$  name       @t
+$  email      @t
::
::  XX handle other RSS versions from before 2.0 / 2.0.1
::       one issue: do versions differ on what parts of
::       an element are and are not optional?
::       if so, might have to just specify each version
::       individually
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
      ::  XX @uds should be @ts (consistent w/ %skip-hours string literals)
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
          ::  XX @uds should be @ts (consistent w/ %skip-hours string literals)
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
::  XX remove faces from attributes
::       this is just a spec
::       for the purposes of storing RSS/Atom elmeents in Hoon,
::       these attributes should be stored in the order provided here.
::       this should not be hard for two reasons:
::       1) this library is a copy/paste job for the dev
::       2) if they really must fuck around, they can find out everything
::          they need to know in this file, which will be included in the desk
::
+$  atom-feed-element
  $%  [%id @t]
      [%title @t]
      [%updated time]
      ::
      ::  XX are email and uri optional or not?
      ::       get more clarity on that
      ::       increasingly unit-pilled;
      ::       it specifies what is and is not
      ::       optional in the type
      ::
      [%author name (unit email) (unit uri)]
      [%category @t]
      [%contributor name]
      [%generator (unit uri) version=(unit @t)]
      [%icon url] 
      [%logo url]
      [%rights @t]
      [%subtitle @t]
      $:  %link
          ::  href
          uri
          ::  ref
          (unit ?(uri %'alternate' %'enclosure' %'related' %'self' %'via'))
          ::  type
          (unit @t)
          ::  hreflang
          (unit @t)
          ::  title
          (unit @t)
          :: length
          (unit @t)
      ==
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
          ::  type
          @t
          ::  src
          (unit uri)
      ==
      $:  %link
          ::  href
          uri
          ::  ref
          (unit ?(uri %'alternate' %'enclosure' %'related' %'self' %'via'))
          ::  type
          (unit @t)
          ::  hreflang
          (unit @t)
          ::  title
          (unit @t)
          :: length
          (unit @t)
      ==
  ==
--
