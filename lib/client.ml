open Eio.Std

(* Prefix all trace output with "client: " *)
let traceln fmt = traceln ("client: " ^^ fmt)

module Read = Eio.Buf_read
module Write = Eio.Buf_write

(* Connect to [addr] on [net], send a message and then read the reply. Uses eio capability recommended style to pass in
   [clock] [stdin] [stdout] *)
let run ~clock ~stdin ~stdout ~net ~addr =
  traceln "Connecting to server at %a..." Eio.Net.Sockaddr.pp addr;
  try
    Switch.run @@ fun sw ->
    let flow = Eio.Net.connect ~sw net addr in
    Agent.start_agent clock stdin stdout flow
  with End_of_file -> traceln "Server disconnected"
