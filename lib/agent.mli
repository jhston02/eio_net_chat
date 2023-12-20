open Eio.Net

val start_agent :
  _ Eio.Time.clock ->
  _ Eio.Flow.source ->
  _ Eio.Flow.sink ->
  'a stream_socket ->
  unit
(** [start_agent] creates and starts an agent listening on [socket]. It follows Eio recommendation on capability based passing
    and passes in environmental things like [timer], [stdin] and [stdout] *)
