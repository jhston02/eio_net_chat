open Eio.Std
module Write = Eio.Buf_write
module Read = Eio.Buf_read
module Stream = Eio.Stream
module Clock = Eio.Time

let trace_ln fmt = traceln ("Server: " ^^ fmt)

let wrapper clock stdin stdout socket _ =
  Agent.start_agent clock stdin stdout socket

(* Accept incoming client connections on [socket].
   We can handle multiple clients at the same time.
   Note we should probably set a mutex and throw if more than one client connects
   Never returns (but can be cancelled). *)
let run ~clock ~stdin ~stdout ~net ~addr =
  Switch.run @@ fun sw ->
  let socket = Eio.Net.listen net ~sw ~reuse_addr:true ~backlog:5 addr in
  Fiber.fork ~sw (fun () ->
      Eio.Net.run_server socket
        (wrapper clock stdin stdout)
        ~on_error:(fun _ -> trace_ln "Client disconnected")
        ~max_connections:1000)
