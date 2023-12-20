type t = Send of string | Ack | Disconnect
[@@deriving eq, show]


module Eio : sig
  (** Serialization module for Eio which takes advantage of their tightly coupled parser *)

  val serialize : t -> _ Eio.Flow.sink -> unit
  val deserialize : t option Eio.Buf_read.parser
end = struct
  module Write = Eio.Buf_write

  let serialize msg t =
    Write.with_flow t (fun w ->
        match msg with
        | Ack -> Write.char w 'A'
        | Send msg ->
            Write.char w 'S';
            Write.LE.uint32 w (Int32.of_int @@ String.length msg);
            Write.string w msg
        | Disconnect -> Write.char w 'D')

  let deserialize_msg =
    let open Eio.Buf_read.Syntax in
    let* length = Eio.Buf_read.LE.uint32 in
    let+ msg = Eio.Buf_read.take (Int32.to_int length) in
    Some (Send msg)

  let deserialize =
    let open Eio.Buf_read.Syntax in
    let* char = Eio.Buf_read.any_char in
    match char with
    | 'S' -> deserialize_msg
    | 'A' -> Eio.Buf_read.return (Some Ack)
    | 'D' -> Eio.Buf_read.return (Some Disconnect)
    | _ -> Eio.Buf_read.return None
end
