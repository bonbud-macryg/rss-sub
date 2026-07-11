::
::  Fetch and process a batch of feed URLs concurrently.
::
::  Each child strand sends one Iris request on a unique wire, starts parser
::  threads on unique Khan wires, and +app-cons combines the strands so all
::  request cards are emitted before waiting for responses.
::
/-  spider, ra=rss-atom, rs=rss-sub
/+  io=strandio
=,  strand=strand:spider
=,  strand-fail:strand-fail:strand
::
^-  thread:spider
=>  |%
    +$  result
      $%  [%rss =link:ra channel=(list channel-element:rss:ra) items=(list item:rss:ra)]
          [%atom =link:ra feed=(list feed-element:atom:ra) entries=(list entry:atom:ra)]
      ==
    ::
    ++  send-request-wire
      |=  [=request:http =wire]
      =/  m  (strand ,~)
      ^-  form:m
      =/  =task:iris  [%request request *outbound-config:iris]
      =/  =card:agent:gall  [%pass [%request wire] %arvo %i task]
      (send-raw-card:io card)
    ::
    ++  take-maybe-response-wire
      |=  =wire
      =/  m  (strand ,(unit client-response:iris))
      ^-  form:m
      |=  tin=strand-input:strand
      ?+    in.tin  `[%skip ~]
          ~
        `[%wait ~]
      ::
          [~ %sign [%request *] %iris %http-response %cancel *]
        ?.  =(wire t.wire.u.in.tin)  `[%skip ~]
        `[%done ~]
      ::
          [~ %sign [%request *] %iris %http-response %finished *]
        ?.  =(wire t.wire.u.in.tin)  `[%skip ~]
        `[%done `client-response.sign-arvo.u.in.tin]
      ==
    ::
    ++  fetch-feed
      |=  =link:ra
      =/  m  (strand ,(unit [link:ra body=@t]))
      ^-  form:m
      =/  =wire  /fetch-feed/(scot %uv (sham link))
      =/  =request:http  [%'GET' link ~ ~]
      ;<  ~  bind:m
        (send-request-wire request wire)
      ;<  response=(unit client-response:iris)  bind:m
        (take-maybe-response-wire wire)
      ?~  response
        %-  pure:m
        ~
      =/  =client-response:iris  u.response
      ?>  ?=(%finished -.client-response)
      =,  response-header.client-response
      ?~  full-file.client-response
        ?.  ?|  =(301 status-code)
                =(307 status-code)
            ==
          %-  pure:m
          ~
        %=  $
          link
        %-  %~  got  by
          (malt headers)
        'location'
        ==
      ?:  (gte status-code 500)
        %-  pure:m
        ~
      ?:  (gte status-code 400)
        %-  pure:m
        ~
      (pure:m `[link `@t`q.data.u.full-file.client-response])
    ::
    ++  send-thread-wire
      |=  [file=term args=vase =wire]
      =/  m  (strand ,~)
      ^-  form:m
      ;<  bowl=bowl:spider  bind:m  get-bowl:io
      =/  =task:khan  [%fard byk.bowl(r da+now.bowl) file [%noun args]]
      =/  =card:agent:gall  [%pass wire %arvo %k task]
      (send-raw-card:io card)
    ::
    ++  take-thread-wire
      |=  =wire
      =/  m  (strand ,(unit vase))
      ^-  form:m
      |=  tin=strand-input:strand
      ?+    in.tin  `[%skip ~]
          ~
        `[%wait ~]
      ::
          [~ %sign * %khan %arow %.n *]
        ?.  =(wire wire.u.in.tin)  `[%skip ~]
        `[%done ~]
      ::
          [~ %sign * %khan %arow %.y %noun *]
        ?.  =(wire wire.u.in.tin)  `[%skip ~]
        =/  [%khan %arow %.y %noun =vase]  sign-arvo.u.in.tin
        `[%done `vase]
      ==
    ::
    ++  run-thread-wire
      |=  [file=term args=vase =wire]
      =/  m  (strand ,(unit vase))
      ^-  form:m
      ;<  ~  bind:m
        (send-thread-wire file args wire)
      ;<  res=(unit vase)  bind:m
        (take-thread-wire wire)
      (pure:m res)
    ::
    ++  parse-rss-item
      |=  [=link:ra =manx]
      =/  m  (strand ,(unit item:rss:ra))
      ^-  form:m
      =/  =wire  /parse-rss-item/(scot %uv (sham [link manx]))
      ;<  res=(unit vase)  bind:m
        (run-thread-wire %rss-item !>(manx) wire)
      ?~  res
        %-  pure:m
        ~
      =/  item=item:rss:ra  !<(item:rss:ra u.res)
      (pure:m `item)
    ::
    ++  parse-atom-entry
      |=  [=link:ra =manx]
      =/  m  (strand ,(unit entry:atom:ra))
      ^-  form:m
      =/  =wire  /parse-atom-entry/(scot %uv (sham [link manx]))
      ;<  res=(unit vase)  bind:m
        (run-thread-wire %atom-entry !>(manx) wire)
      ?~  res
        %-  pure:m
        ~
      =/  entry=entry:atom:ra  !<(entry:atom:ra u.res)
      (pure:m `entry)
    ::
    ++  parse-feed
      |=  [=link:ra body=@t]
      =/  m  (strand ,(unit result))
      ^-  form:m
      =/  =wire  /parse-feed/(scot %uv (sham link))
      ;<  res=(unit vase)  bind:m
        (run-thread-wire %rss-wasm !>([link body]) wire)
      ?~  res
        %-  pure:m
        ~
      =/  parsed=result  !<(result u.res)
      (pure:m `parsed)
    ::
    ++  process-feed
      |=  =link:ra
      =/  m  (strand ,(unit result))
      ^-  form:m
      ;<  fetched=(unit [link:ra body=@t])  bind:m
        (fetch-feed link)
      ?~  fetched
        %-  pure:m
        ~
      =/  [=link:ra body=@t]  u.fetched
      (parse-feed link body)
    ::
    ++  app-cons
      |*  [hed=(strand-form-raw:rand *) tel=(strand-form-raw:rand *)]
      |=  tin=strand-input:rand
      =*  this  .
      =/  h  (hed tin)
      =/  t  (tel tin)
      :-  (weld cards.h cards.t)
      ?:  ?=(%fail -.next.h)  next.h
      ?:  ?=(%fail -.next.t)  next.t
      ?:  &(?=(%done -.next.h) ?=(%done -.next.t))
        [%done value.next.h value.next.t]
      =^  change-hed  hed
        =-  [!=(hed -) -]
        ?:  ?=(%done -.next.h)  =>(v=value.next.h |~(* `done+v))
        ?:  ?=(%cont -.next.h)  self.next.h
        hed
      =^  change-tel  tel
        =-  [!=(tel -) -]
        ?:  ?=(%done -.next.t)  =>(v=value.next.t |~(* `done+v))
        ?:  ?=(%cont -.next.t)  self.next.t
        tel
      ?:  |(change-hed change-tel)  [%cont this]
      ?:  |(?=(%wait -.next.h) ?=(%wait -.next.t))  [%wait ~]
      [%skip ~]
    ++  arg-links
      |=  arg=vase
      ^-  (list link:ra)
      (raw-links !<(* arg))
    ++  raw-links
      |=  raw=*
      ^-  (list link:ra)
      ?:  =(`*`~ raw)
        ~
      ?:  ?=([%~ %~] raw)
        ~
      ?:  ?=([%~ @t *] raw)
        =/  [%~ link=@t tail=*]  raw
        [link $(raw tail)]
      ?:  ?=([@t *] raw)
        =/  [link=@t tail=*]  raw
        [link $(raw tail)]
      ~
    --
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  links=(list link:ra)  (arg-links arg)
;<  result-units=(list (unit result))  bind:m
  %+  roll  links
  |=  [link=link:ra acc=(strand-form-raw:rand (list (unit result)))]
  ^-  (strand-form-raw:rand (list (unit result)))
  (app-cons (process-feed link) acc)
=/  results=(list result)
  %+  murn  result-units
  |=  res=(unit result)
  ^-  (unit result)
  ?~  res  ~
  `u.res
%-  pure:m
!>(results)
