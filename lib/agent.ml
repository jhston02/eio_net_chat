open Eio.Std
module Write = Eio.Buf_write
module Read = Eio.Buf_read
module Stream = Eio.Stream
module Clock = Eio.Time

let write_line flow msg =
  Write.with_flow flow (fun w -> Write.string w (msg ^ "\n"))

let handle_command write_stream stdout ack_stream = function
  | Message.Send msg ->
      write_line stdout (Ocolor_format.asprintf "@{<green> %s @}" msg);
      Stream.add write_stream Message.Ack
  | Message.Ack -> Stream.add ack_stream true
  | Message.Disconnect -> raise End_of_file

(* Read fiber which removes msgs from the socket, deserializes them and then takes an action *)
let handle_read r_flow stdout write_stream ack_stream =
  let buf = Read.of_flow r_flow ~max_size:4000 in
  let handle_command = handle_command write_stream stdout ack_stream in
  let rec handle_message buf =
    match Read.format_errors Message.Eio.deserialize buf with
    | Error (`Msg _) -> raise End_of_file
    | Ok cmd ->
        cmd |> Option.iter handle_command;
        handle_message buf
  in
  handle_message buf

(* Write fiber listening on write channel/stream for things to write *)
let handle_write w_flow stream =
  let rec handle_message () =
    let cmd = Stream.take stream in
    Message.Eio.serialize cmd w_flow;
    handle_message ()
  in
  handle_message ()

(* Handle stdin and timing ack responses *)
let handle_std_client clock stdin stdout write_stream ack_stream =
  let buf = Read.of_flow stdin ~initial_size:100 ~max_size:1_000_000 in
  while true do
    let line = Read.line buf in
    let start_time = Clock.now clock in
    Stream.add write_stream (Message.Send line);
    (* We should probably put a timeout on this ack check, failure to ack would be bad *)
    let _ = Stream.take ack_stream in
    let r = Clock.now clock -. start_time in
    write_line stdout
      (Ocolor_format.asprintf "@{<blue> \t  Round trip took %f @}" r)
  done

let start_agent clock stdin stdout flow =
  (* Start a fiber foreach IO type, reader, write, stdin/stdout
     Fibers communicate through streams each of which handles a particular type of IO *)
  Switch.run (fun sw ->
      let write_stream = Stream.create 100 in
      (* would love to use a promise but not sure how to bake that all in *)
      let ack_stream = Stream.create 0 in
      Fiber.fork ~sw (fun () -> handle_read flow stdout write_stream ack_stream);
      Fiber.fork ~sw (fun () -> handle_write flow write_stream);
      Fiber.fork ~sw (fun () ->
          handle_std_client clock stdin stdout write_stream ack_stream))
