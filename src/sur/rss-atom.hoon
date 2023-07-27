|%
::
::  XX try to fill out the rest of the raw auras
+|  %type-faces
::
::  XX should maybe have a uuid type for ids, but double-check across RSS + Atom
::
+$  uri    @t  ::  URI, which could be a link
+$  lang   @t  ::  BCP 47 language tag
+$  link   @t  ::  URL
+$  mime   @t  ::  MIME type
+$  name   @t  ::  John, John Doe, etc.
+$  numb   @t  ::  number
+$  mail   @t  ::  email address
+$  text   @t  ::  misc. human-readable text
+$  vers   @t  ::  semantic version number
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
      [%link link]
      [%description @t]
      ::
      ::  XX check cases like 'neil.armstrong@example.com (Neil Armstrong)' from example
      ::       i think it's fine to call this "email" and just parse the emails out of the items
      ::       so: assume it's an email, but handle if it's not
      ::
      [%author mail]
      ::  XX what is tail?
      [%category domain=(unit link) @t]
      [%comments link]
      [%enclosure =link length=numb type=@t]
      [%guid link]
      [%pub-date time]
      ::  XX what is tail?
      [%source link @t]
  ==
::
+$  rss-channel-element
  $%  [%title @t]
      [%link link]
      [%description @t]
      [%language lang]
      [%pub-date time]
      [%last-build-date time]
      [%docs link]
      [%generator @t]
      [%managing-editor mail]
      [%web-master mail]
      [%copyright @t]
      ::  XX tail is $numb?
      [%category (unit link) @t]
      [%ttl numb]
      ::  XX find PICS rating example
      ::  [%rating !!]
      [%text-input title=@t description=@t =name link=link]
      [%skip-hours (set ?(%'0' %'1' %'2' %'3' %'4' %'5' %'6' %'7' %'8' %'9' %'10' %'11' %'12' %'13' %'14' %'15' %'16' %'17' %'18' %'19' %'20' %'21' %'22' %'23'))]
      [%skip-days (set ?(%'Monday' %'Tuesday' %'Wednesday' %'Thursday' %'Friday' %'Saturday' %'Sunday'))]
      $:  %cloud
          domain=link
          ::  XX numb?
          port=@t
          path=@t
          register-procedure=@t
          protocol=@t
      ==
      $:  %image
          link
          title=@t
          link=link
          width=(unit numb)
          height=(unit numb)
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
::  XX label attributes in comments (like %cateogry and %generator)
+$  atom-feed-element
  $%  [%id uri]
      [%title text]
      [%updated time]
      [%author name (unit mail) (unit uri)]
      ::  term, scheme, label
      [%category text (unit uri) (unit text)]
      [%contributor name]
      ::  uri, version
      [%generator (unit uri) (unit vers)]
      [%icon link] 
      [%logo link]
      [%rights text]
      [%subtitle text]
      $:  %link
          ::  href
          uri
          ::  ref
          (unit ?(uri %'alternate' %'enclosure' %'related' %'self' %'via'))
          ::  type
          (unit mime)
          ::  hreflang
          (unit lang)
          ::  title
          (unit text)
          ::  length
          (unit numb)
      ==
  ==
::
::  XX label attributes in comments (like %category and %source)
+$  atom-entry-element
  ::  XX what format is urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a?
  ::       that should be a @t type face at the top of this file
  ::       it's a URN, a subset of URI; is %id always a URN or can it be any URI?
  $%  [%id uri]
      [%title text]
      [%updated time]
      [%author name]
      [%summary text]
      [%contributor name]
      [%published time]
      [%rights text]
      ::  id, title, updated
      ::  XX what's optional?
      ::  XX is id a link or uri?
      [%source link text time]
      ::  term, scheme, label
      [%category text (unit uri) (unit text)]
      ::
      ::  XX w3 missing info on this, find out what's optional
      ::
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
          (unit mime)
          ::  hreflang
          (unit lang)
          ::  title
          (unit text)
          :: length
          (unit numb)
      ==
  ==
--
