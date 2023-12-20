open Eio_net_chat

let message_test = Alcotest.testable Message.pp Message.equal

let round_trip_send =
  QCheck2.Test.make ~count:1000 ~name:"random strings round_trip"
    (QCheck2.Gen.string) (fun msg -> 
  Eio_main.run @@ fun _env ->
  let message = Message.Send msg in
  let flow = Eio_mock.Flow.make "test" in 
  Message.Eio.serialize message flow;
  let a = Eio.Buf_read.parse_exn ~max_size:100000 Message.Eio.deserialize flow in
  (a |> Option.get) = message  
  )

let round_trip_ack () =    
  Eio_main.run @@ fun _env ->
  let message = Message.Ack in
  let flow = Eio_mock.Flow.make "test" in 
  let buffer = Buffer.create 1 in
  let sync_flow = Eio.Flow.buffer_sink buffer in
  Message.Eio.serialize message sync_flow;
  Eio_mock.Flow.on_read flow [`Return (Buffer.contents buffer)] ;
  let a = Eio.Buf_read.parse_exn ~max_size:100000 Message.Eio.deserialize flow in  
  Alcotest.(check (option message_test))
    "Ack round tripped" a (Some message)


let round_trip_disconnect () =    
  Eio_main.run @@ fun _env ->
  let message = Message.Disconnect in
  let flow = Eio_mock.Flow.make "test" in 
  let buffer = Buffer.create 1 in
  let sync_flow = Eio.Flow.buffer_sink buffer in
  Message.Eio.serialize message sync_flow;
  Eio_mock.Flow.on_read flow [`Return (Buffer.contents buffer)] ;
  let a = Eio.Buf_read.parse_exn ~max_size:1 Message.Eio.deserialize flow in  
  Alcotest.(check (option message_test))
    "Disconnect round tripped" a (Some message)


let round_trip_tests =
  let open Alcotest in
  ( "Round trip",
    [
      test_case "disconnect" `Quick
        round_trip_disconnect;
      test_case "ack" `Quick
        round_trip_ack;
      test_case "send" `Quick
        round_trip_ack
    ] )

let get_tests () = [ round_trip_tests]
