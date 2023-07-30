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
|%
::
+|  %type-faces
::
::  XX should maybe have a uuid type for ids, but double-check across RSS + Atom
::
+$  uri    @t  ::  URI, which could be a link
::  XX note diff. standards in RSS vs. Atom if necessary
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
  $:  %channel
      [%headers (list *)]
      [%elems (list rss-channel-element)]
      [%items (list rss-item)]
  ==
::
+$  rss-item
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
          (unit numb)
          ::  height
          ::  XX max. height 400; validate/enforce in thread
          (unit numb)
          ::  description
          (unit text)
      ==
      [%skip-days (list ?(%'Monday' %'Tuesday' %'Wednesday' %'Thursday' %'Friday' %'Saturday' %'Sunday'))]
      [%skip-hours (list ?(%'0' %'1' %'2' %'3' %'4' %'5' %'6' %'7' %'8' %'9' %'10' %'11' %'12' %'13' %'14' %'15' %'16' %'17' %'18' %'19' %'20' %'21' %'22' %'23'))]
  ==
::
::  Atom 1.0
+|  %atom-types
::
+$  atom-feed
  ::  XX what about these?
  ::       <?xml version="1.0" encoding="utf-8"?>
  ::       <feed xmlns="http://www.w3.org/2005/Atom">
  $:  %feed
      [%headers (list *)]
      [%elems (list atom-feed-element)]
      [%entries (list atom-entry)]
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
      ::  XX check what is required under what circumstances
      ::       e.g. If a src attribute is present, the
      ::       content of the <content> element must be empty.
      $:  %content
          ::  type
          ::  XX fine for a rough draft, but check against the actual RFC
          ::       it's a bit more complicated than this
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
