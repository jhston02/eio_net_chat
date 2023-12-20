let () =
  Alcotest.run "Eio_net_chat" (Message_test.get_tests ())
