open Cmdliner
open Eio_net_chat

let run ~net ~clock ~stdin ~stdout handler addr =
  handler ~clock ~stdin ~stdout ~net ~addr

let main handler addr =
  Eio_main.run @@ fun env ->
  run ~net:(Eio.Stdenv.net env) ~clock:(Eio.Stdenv.clock env)
    ~stdin:(Eio.Stdenv.stdin env) ~stdout:(Eio.Stdenv.stdout env) handler addr

let run_server port =
  `Tcp (Eio.Net.Ipaddr.V4.loopback, port) |> main Server.run

let run_client addr port =
  let raw = Ipaddr.V4.of_string_exn addr |> Ipaddr.V4.to_octets in
  `Tcp (Eio.Net.Ipaddr.of_raw raw, port) |> main Client.run

let port =
  let doc = "Start/connect at port" in
  Arg.(value & opt int 8081 & info [ "p"; "port" ] ~docv:"port" ~doc)

let ip =
  let doc = "Connect to server at ip address" in
  Arg.(value & opt string "127.0.0.1" & info [ "i"; "ip" ] ~docv:"port" ~doc)

let server_t = Term.(const run_server $ port)
let client_t = Term.(const run_client $ ip $ port)
let man = [ `S Manpage.s_bugs; `P "Email bug reports to <bugs@example.org>." ]

let main_cmd =
  let man = man in
  let server_info =
    Cmd.info "server" ~version:"%%VERSION%%" ~doc:"Start server at port" ~man
  in
  let server = Cmd.v server_info server_t in
  let client_info =
    Cmd.info "client" ~version:"%%VERSION%%"
      ~doc:"Start client connecting to server at ip:port" ~man
  in
  let client = Cmd.v client_info client_t in
  let main_doc = "Simple client server chat app" in
  let main_info = Cmd.info "start" ~version:"%%VERSION%%" ~doc:main_doc ~man in
  Cmd.group main_info [ server; client ]

let main () =
  let _ = Cmd.eval main_cmd in
  ()

let () = main ()
