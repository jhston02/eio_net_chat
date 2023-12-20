
# OCaml Chat Application

This application is an OCaml-based chat application leveraging the `eio` library, which supports multicore processing. The application is divided into two main components: a server and a client. Users can start the server and connect with the client to engage in a chat session.

## Features

- **Eio Library**: Utilizes the new `eio` library in OCaml for multicore support.
- **Client-Server Architecture**: Separate executable for server and client.
- **Configurable Ports**: Optional customization of server and client ports.
- **IP Address Specification**: Clients can specify the server's IP address for connection.

## Getting Started

### Prerequisites

Ensure you have OCaml and the `eio` library installed on your system. You can install them using OPAM:

### How to run
To start the server, use the following command:
./main.exe server -p [port-number]

To start the client use the following command:
./main.exe client -p [port-number] -i [server-ip-address]

## Architecture
The Agent module is designed to take advantage of the new Eio Fibers. The agent starts up 3 fibers (on top of whatever the underlying net server does).
These fibers communicate by passing messages through streams. The flow works such that each is responsible for one aspect of the system. One fiber reads off the write stream and 
writes to the socket, fiber 2 reads off the socket and will respond to the message by putting and ack on the write stream or sending the ack to the stdio fiber, and the final fiber handles the stdio
and timing. 


Inline-style: 
![alt text](https://github.com/jhston02/eio_net_chat/blob/main/docs/example.gif "Example")