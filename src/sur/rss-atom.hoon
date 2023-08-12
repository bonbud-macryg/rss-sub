::
::  Specification for storing RSS/Atom data in Hoon.
::
::  XX explanatory notes
::       XX  tag value rules / example
::             if one item, it's the tag value
::             otherwise, tag value is specified
::             <example>
::             attributes in comments are strictly faces corresponding to attribute
::
=>
|%
::
+|  %data-types
::
::  XX should maybe have a uuid type for ids, but double-check across RSS + Atom
::  XX check RFCs to define what properties these types MUST have
::
::  URI, which could be a link
+$  uri
  $|  @t
  |=  a=@t
  ^-  ?
  %.y
::
::  BCP 47 language tag
::  XX note diff. standards in RSS vs. Atom if necessary
+$  lang
  $|  @t
  |=  a=@t
  ^-  ?
  %.y
::
::  URL
::  XX is de-purl:html thorough enough?
+$  link
  $|  @t
  |=  a=@t
  ^-  ?
  ?~  (de-purl:html a)
    %.n
  %.y
::
::  MIME type
+$  mime
  $|  @t
  |=  a=@t
  ^-  ?
  %.y
::
::  John, John Doe, etc.
+$  name  @t
::
::  number
+$  numb  @ud
::
::  email address
+$  mail
  $|  @t
  |=  a=@t
  ^-  ?
  %.y
::
::  misc. human-readable text
+$  text  @t
::
::  semantic version number
+$  vers
  $|  @t
  |=  a=@t
  ^-  ?
  %.y
::
::  one of 24 hours (0 to 23)
+$  hour
  $|  @ud
  |=  a=@ud
  ^-  ?
  (lte a 23)
::
::  day of the week
+$  day
  $|  @t
  |=  a=@t
  ^-  ?
  =/  b
    (cuss (trip a))
  ?|  =(b "monday")
      =(b "tuesday")
      =(b "wednesday")
      =(b "thursday")
      =(b "friday")
      =(b "saturday")
      =(b "sunday")
  ==
--
::
|%
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
  ::  XX bucbar
  $:  %channel
      ::  XX narrow down type
      headers=(list *)
      elems=(list rss-channel-element)
      items=(list rss-item)
  ==
::
+$  rss-item
  ::  XX bucbar
  [%item (list rss-item-element)]
::
+$  rss-item-element
  $%  [%title text]
      [%link link]
      [%description text]
      ::
      ::  XX check cases like 'neil.armstrong@example.com (Neil Armstrong)' from example
      ::       i think it's fine to call this "email" and just parse the emails out of the items
      ::       so: assume it's an email, but handle if it's not
      ::       or: this could be [%author ?(mail text)]
      ::
      [%author mail]
      ::  domain, tag value
      [%category (unit link) text]
      [%comments link]
      ::  link, length, type
      [%enclosure link numb mime]
      [%guid link]
      [%pub-date time]
      ::  url, tag value
      [%source link text]
  ==
::
+$  rss-channel-element
  $%  [%title text]
      [%link link]
      [%description text]
      ::  XX RFC1766 lang code; same as atom?
      ::       also accepts ISO 639 language codes
      [%language lang]
      [%pub-date time]
      ::  XX could use this to skip stale channels?
      ::       this is the time the content last changed
      ::       if lte $last-update, skip it
      [%last-build-date time]
      [%docs link]
      [%generator text]
      ::  XX is foo@bar.com (John Doe) the convention?
      ::       if so, this should be text
      [%managing-editor mail]
      ::  XX is foo@bar.com (John Doe) the convention?
      ::       if so, this should be text
      [%web-master mail]
      [%copyright text]
      ::
      ::  XX should tag value always be the first element in the Hoon tuple?
      ::       the last? should be consistent either way
      ::
      ::  XX  should it be clear in comments what tuple element is the tag value?
      ::
      ::  domain, tag value
      [%category (unit link) text]
      [%ttl numb]
      ::
      :: PICS rating
      :: these are deprecated in practice; ignore
      [%rating text]
      $:  %text-input
          ::  title
          text
          ::  description
          text
          ::  name
          text
          ::  link
          link
      ==
      $:  %cloud
          ::  domain
          link
          ::  port
          numb
          ::  path
          link
          ::  register-procedure
          text
          ::  protocol
          text
      ==
      $:  %image
          ::  url
          link
          ::  title
          text
          ::  link
          link
          ::  width
          ::  XX max. width 144; validate/enforce in thread
          ::       (or, use a bucbar)
          (unit numb)
          ::  height
          ::  XX max. height 400; validate/enforce in thread
          ::       (or, use a bucbar)
          (unit numb)
          ::  description
          (unit text)
      ==
      [%skip-days (list day)]
      [%skip-hours (list hour)]
  ==
::
::  Atom 1.0
+|  %atom-types
::
+$  atom-feed
  ::  XX bucbar
  ::  XX what about these?
  ::       <?xml version="1.0" encoding="utf-8"?>
  ::       <feed xmlns="http://www.w3.org/2005/Atom">
  $:  %feed
      ::  XX narrow down type
      headers=(list *)
      elems=(list atom-feed-element)
      entries=(list atom-entry)
  ==
::
+$  atom-entry
  ::  XX bucbar
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
          ::  XX should this be validated with bucbar?
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
  ::  XX is %id always a URN or can it be any URI?
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
      ::  XX check what is required under what circumstances
      ::       e.g. i know if a src attribute is present, the
      ::       tag value of the <content> element must be empty.
      $:  %content
          ::  type
          ::  XX fine for a rough draft, but check against the actual RFC
          ::       it's a bit more complicated than this
          ::  XX should this be validated with bucbar?
          (unit ?(mime %'text' %'html' %'xhtml'))
          ::  src
          (unit uri)
          ::  tag value
          (unit text)
      ==
      $:  %link
          ::  href
          uri
          ::  ref
          ::  XX should this be validated with bucbar?
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
