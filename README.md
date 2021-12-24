# telnet-stream
Transform streams that emit TELNET negotiations as events

## Motivation
Although venerable, the [TELNET](https://en.wikipedia.org/wiki/Telnet)
protocol is still in use by some services and expected by some clients.
If you need to connect to something that "speaks TELNET", this module
offers some simple objects for that purpose.

## Example 0: A Simple Solution
If you need to connect to something that speaks TELNET, but you don't
care about options or negotiations, then simply use TelnetSocket to
decorate a regular socket. It will filter out all the "TELNET stuff"
and pass the remaining data on to you.

    // get references to the required stuff
    var TelnetSocket, net, socket, tSocket;

    net = require("net");

    ({TelnetSocket} = require("telnet-stream"));

    // create a Socket connection
    socket = net.createConnection(3000, "godwars2.org");

    // decorate the Socket connection as a TelnetSocket
    tSocket = new TelnetSocket(socket);

    // if the socket closes, terminate the program
    tSocket.on("close", function() {
      return process.exit();
    });

    // if we get any data, display it to stdout
    tSocket.on("data", function(buffer) {
      return process.stdout.write(buffer.toString("utf8"));
    });

    // if the user types anything, send it to the socket
    process.stdin.on("data", function(buffer) {
      return tSocket.write(buffer.toString("utf8"));
    });

## Usage
Maybe you have more complex needs. Perhaps you need certain options
to be turned on or off, or have important information to pull from
a subnegotiation. This is pretty easy to do with TelnetSocket.

### TelnetSocket input
TelnetSocket is a decorator for a [net.Socket](https://nodejs.org/api/net.html)
object. Incoming TELNET commands, options, and negotiations are emitted as
events. Non-TELNET data is passed through without changes.

#### Event: 'command'
When the remote system issues a TELNET command that is not option
negotiation, TelnetSocket will emit a 'command' event.

    var tSocket = new TelnetSocket(socket);
    tSocket.on('command', function(command) {
        // Received: IAC <command> - See RFC 854
    });

#### Event: 'do'
When the remote system wants to request that the local system
perform some function or obey some protocol, TelnetSocket will
emit a 'do' event:

    var tSocket = new TelnetSocket(socket);
    tSocket.on('do', function(option) {
        // Received: IAC DO <option> - See RFC 854
    });

#### Event: 'dont'
When the remote system wants to request that the local system
NOT perform some function or NOT obey some protocol, TelnetSocket
will emit a 'dont' event:

    var tSocket = new TelnetSocket(socket);
    tSocket.on('dont', function(option) {
        // Received: IAC DONT <option> - See RFC 854
    });

#### Event: 'sub'
After negotiating an option, either the local or remote system
may engage in a more complex subnegotiation. For example, the
server and client may agree to use encryption, and then use
subnegotiation to agree on the parameters of that encryption.

    var tSocket = new TelnetSocket(socket);
    tSocket.on('sub', function(option, buffer) {
        // Received: IAC SB <option> <buffer> IAC SE - See RFC 855
    });

#### Event: 'will'
When the remote system wants to offer that it will perform some
function or obey some protocol for the local system, TelnetSocket
will emit a 'will' event:

    var tSocket = new TelnetSocket(socket);
    tSocket.on('will', function(option) {
        // Received: IAC WILL <option> - See RFC 854
    });

#### Event: 'wont'
When the remote system wants to refuse to perform some function
or obey some protocol for the local system, TelnetSocket will
emit a 'wont' event:

    var tSocket = new TelnetSocket(socket);
    tSocket.on('wont', function(option) {
        // Received: IAC WONT <option> - See RFC 854
    });

### TelnetSocket output
TelnetSocket is a decorator for a [net.Socket](https://nodejs.org/api/net.html)
object. Outgoing data is properly escaped where it might be confused
for a TELNET command. There are also support functions to allow sending
TELNET commands, options, and negotiations as well.

#### IAC escape
TELNET commands start with the Interpret as Command (IAC) byte.
In order to send a literal IAC byte (one that is intended as data,
not as a TELNET command), it must be sent as IAC IAC. TelnetSocket
takes care of this transformation automatically.

#### writeCommand(command)
* command - The command byte to send

Call this method to send a TELNET command to the remote system.

    var NOP = 241; // No operation. -- See RFC 854
    var tSocket = new TelnetSocket(socket);
    // Sends: IAC NOP
    tSocket.writeCommand(NOP);

#### writeDo(option)
* option - The option byte to request of the remote system

Call this method to send a TELNET DO option negotiation to the remote
system. A DO request is sent when the local system wants the remote
system to perform some function or obey some protocol.

    var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
    var tSocket = new TelnetSocket(socket);
    // Sends: IAC DO NAWS
    tSocket.writeDo(NAWS);

#### writeDont(option)
* option - The option byte to request of the remote system

Call this method to send a TELNET DONT option negotiation to the remote
system. A DONT request is sent when the local system wants the remote
system to NOT perform some function or NOT obey some protocol.

    var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
    var tSocket = new TelnetSocket(socket);
    // Sends: IAC DONT NAWS
    tSocket.writeDont(NAWS);

#### writeSub(option, buffer)
* option - The option byte; identifies what the subnegotiation is about
* buffer - The buffer containing the subnegotiation data to send

Call this method to send a TELNET subnegotiation to the remote system.
After the local and remote system have negotiated and agreed to use
an option, then subnegotiation information can be sent.

See Example #2: Negotiate About Window Size (NAWS) below.

#### writeWill(option)
* option - The option byte to offer to the remote system

Call this method to send a TELNET WILL option negotiation to the remote
system. A WILL offer is sent when the local system wants to inform the
remote system that it will perform some function or obey some protocol.

    var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
    var tSocket = new TelnetSocket(socket);
    // Sends: IAC WILL NAWS
    tSocket.writeWill(NAWS);

#### writeWont(option)
* option - The option byte to refuse to the remote system

Call this method to send a TELNET WONT option negotiation to the remote
system. A WONT refusal is sent when the remote system has requested that
the local system perform some function or obey some protocol, and the
local system is refusing to do so.

    var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
    var tSocket = new TelnetSocket(socket);
    // Sends: IAC WONT NAWS
    tSocket.writeWont(NAWS);

### Example 1: Options Actively Refused
The simple example above provided a simple TELNET client.
However, all TELNET commands were filtered and ignored.
A service might think one was using a very dumb client,
because it refuses to acknowledge TELNET negotiations.

This example does the same thing, but actively refuses
all TELNET options. If the remote service offers something,
we decline to take advantage of it. If the remote service
requests that we do something, we refuse to do it.

    // get references to the required stuff
    var TelnetSocket, net, socket, tSocket;

    net = require("net");

    ({TelnetSocket} = require("telnet-stream"));

    // create a Socket connection
    socket = net.createConnection(3000, "godwars2.org");

    // decorate the Socket connection as a TelnetSocket
    tSocket = new TelnetSocket(socket);

    // if the socket closes, terminate the program
    tSocket.on("close", function() {
      return process.exit();
    });

    // if we get any data, display it to stdout
    tSocket.on("data", function(buffer) {
      return process.stdout.write(buffer.toString("utf8"));
    });

    // tell remote we WONT do anything we're asked to DO
    tSocket.on("do", function(option) {
      return tSocket.writeWont(option);
    });

    // tell the remote DONT do whatever they WILL offer
    tSocket.on("will", function(option) {
      return tSocket.writeDont(option);
    });

    // if the user types anything, send it to the socket
    process.stdin.on("data", function(buffer) {
      return tSocket.write(buffer.toString("utf8"));
    });

This code is mostly the same as Example 0 except that we respond
to incoming 'do' and 'will' events sent by the remote side.

Note that incoming 'dont' and 'wont' events are ignored.
This is OK because they are the expected state. TELNET
negotiations involve changes to the current state. As a
rule, we don't acknowledge things that we already expect.

### Example 2: Negotiate About Window Size (NAWS)
There is a TELNET option called "Negotiate About Window Size" (NAWS)
that allows the server to learn the dimensions of the client's output
window. This is useful is some cases, as the server can wrap text
output at an appropriate boundary, implement a text windowing system,
or other things that depend on client metrics.

#### Server Side
This code implements a simple TELNET server that listens for
NAWS subnegotiations and reports the client's window size
to the console.

    // some variables that we'll use
    var NAWS, TelnetSocket, net, server;

    // Negotiate About Window Size -- See RFC 1073
    NAWS = 31;

    // get references to the required stuff
    net = require("net");

    ({TelnetSocket} = require("telnet-stream"));

    // create a service to listen for incoming connections
    server = net.createServer(function(socket) {
      var tSocket;
      // wrap the socket as a TelnetSocket
      tSocket = new TelnetSocket(socket);
      // if we get any data, display it to the console
      tSocket.on("data", function(buffer) {
        return process.stdout.write(buffer.toString("utf8"));
      });
      // if they send us a subnegotiation
      tSocket.on("sub", function(option, buffer) {
        var height, width;
        // if they are telling us their window size
        if (option === NAWS) {
          // display it to the console
          width = buffer.readInt16BE(0);
          height = buffer.readInt16BE(2);
          return process.stdout.write(`Client window: ${width}x${height}\n`);
        }
      });
      // tell the client to send window size subnegotiations
      return tSocket.writeDo(NAWS);
    });

    // start our server listening on port 3000
    server.listen(3000);

#### Client Side
This code implements a simple TELNET client that sends NAWS
subnegotiations when the output window is resized. Note that
it only sends NAWS subnegotiations after it has confirmed
that the server supports and wants to hear about them.

    // some variables that we'll use
    var NAWS, TelnetSocket, net, sendWindowSize, serverNawsOk, socket, tSocket;

    // Negotiate About Window Size -- See RFC 1073
    NAWS = 31;

    // get references to the required stuff
    net = require("net");

    ({TelnetSocket} = require("telnet-stream"));

    // create a Socket connection
    socket = net.createConnection(3000);

    // decorate the Socket connection as a TelnetSocket
    tSocket = new TelnetSocket(socket);

    // flag to indicate if its OK to send window size subnegotiations to the server
    serverNawsOk = false;

    // function: send window size to the server
    sendWindowSize = function() {
      var nawsBuffer;
      // create a buffer
      nawsBuffer = Buffer.alloc(4);
      // fill the buffer up with our window dimensions
      nawsBuffer.writeInt16BE(process.stdout.columns, 0);
      nawsBuffer.writeInt16BE(process.stdout.rows, 2);
      // send that buffer as a subnegotiation to the server
      return tSocket.writeSub(NAWS, nawsBuffer);
    };

    // if the socket closes, terminate the program
    tSocket.on("close", function() {
      return process.exit();
    });

    // if we get any data, display it to stdout
    tSocket.on("data", function(buffer) {
      return process.stdout.write(buffer.toString("utf8"));
    });

    // if the server sends us a DO negotiation
    tSocket.on("do", function(option) {
      // if that negotiation is about window size
      if (option === NAWS) {
        // set the flag indicating that the server has
        // told us it's OK to send our window size
        serverNawsOk = true;
        // tell the server that we WILL send window size
        tSocket.writeWill(NAWS);
        // send our current window size to the server
        return sendWindowSize();
      }
    });

    // if the user types anything, send it to the socket
    process.stdin.on("data", function(buffer) {
      return tSocket.write(buffer.toString("utf8"));
    });

    // if the terminal window is resized
    process.stdout.on("resize", function() {
      // if we're OK to send our window size to the server
      if (serverNawsOk) {
        // send the new window size to the server
        return sendWindowSize();
      }
    });

Run this program and it should immediately send the current
size of the terminal window to the server. After that, you
can resize your terminal window in order to make the client
program to send the new window size to the server.

## Advanced Use Cases
This section covers advanced use-cases. If you need to use the
TELNET protocol outside of a Socket context, or if you need to
modify some aspects of the protocol handling, this is the
section for you.

### TelnetSocket options
The TelnetSocket constructor takes an optional `options` parameter:

`new TelnetSocket(socket, [options])`
* `socket` - Required: net.Socket to be decorated as a TELNET socket
* `options` - Optional: Options configuration
  * `bufferSize` - The size of the subnegotiation buffer
  * `errorPolicy` - How to handle subnegotiation command errors

#### bufferSize
After a TELNET option is negotiated between local and remote,
either side may send subnegotiation data to the other. The
TELNET protocol itself specifies no limit to this data.

Practical considerations dictate placing a reasonable limit
on the amount of data buffered. Most services should NOT buffer
an unlimited amount of data. Malicious clients may be able to
cause a Denial of Service attack by forcing the server to
allocate too much memory in response their requests.

By default, TelnetSocket will buffer to up 8192 (8K = 8 * 1024)
bytes of subnegotiation data. After this, it will emit an `error`
event to indicate an overflow in the subnegotiation buffer. These
additional bytes will be discarded.

In order to modify the size of the buffer, one can specify an
options object with the `bufferSize` option:

    // this TelnetSocket can handle 16K subnegotiations!
    var tSocket = new TelnetSocket(socket, { bufferSize: 16384 });

The default of 8K should be sufficient for most use-cases.

#### errorPolicy
During a subnegotiation, there are two valid sequences that begin with
IAC. One is to escape another IAC intended as a literal data byte:

    IAC IAC     // this is a literal IAC [Hex 0xFF, Dec 255] byte

The other is to end the ongoing subnegotiation:

    IAC SE      // this signals the end of the subnegotiation

No other sequence is specified in the RFC. No mention is made of
the state of the protocol after receiving an unknown sequence.

If an unknown sequence is detected; IAC followed by something
that isn't IAC or SE, then an `error` event will be emitted.
The `errorPolicy` option can set a policy for what will happen
to the two erroneous bytes.

##### "keepBoth"
By default, it is assumed that a faulty sequence starting with
IAC is a failure to properly escape a data IAC byte as IAC IAC.
TelnetSocket will keep both bytes (the IAC and the following
data byte) and continue the subnegotiation.

##### "keepData"
If you want TelnetSocket to keep the data byte (the byte
following the IAC), but discard the IAC, the error policy
`keepData` will do this. The data byte will be added to the
subnegotiation and the subnegotiation will continue.

    // filter out erroneous IAC bytes
    var tSocket = new TelnetSocket(socket, { errorPolicy: "keepData" });

##### "discardBoth"
If you want TelnetSocket to discard both the IAC and the
data byte that follows it, the error policy "discardBoth"
will do this. The subnegotiation will continue, containing
neither of the two erroneous bytes.

    // filter out erroneous IAC <data> bytes
    var tSocket = new TelnetSocket(socket, { errorPolicy: "discardBoth" });

### Network Virtual Terminal (NVT)
In addition to TELNET negotiation, RFC 854 specifies a Network Virtual
Terminal (NVT). Among other things in the NVT specification,
a Carriage Return (CR) [Hex 0x0C, Dec 13] byte must be followed by
either a Line Feed (LF) [Hex 0x0A, Dec 10] byte or a Null (NUL) [Hex 0x00,
Dec 0] byte. It says "the CR character must be avoided in other contexts".

Furthermore, it goes on to specify: "Even though it may be known in some
situations that characters are not being sent to an actual printer,
nonetheless, for the sake of consistency, the protocol requires that a NUL
be inserted following a CR not followed by a LF in the data stream."

telnet-stream DOES NOT respect this part of the specification. The
character following a CR in the data stream is never modified in any
way. If you want or need this behavior, please open an issue on GitHub.
The author would be very curious to discover a use-case where this
behavior is both expected and necessary.

### TelnetInput and TelnetOutput
TelnetSocket is built on lower level Transform streams. These
transform streams do the real work of managing the TELNET protocol,
where TelnetSocket is simply a convenience wrapper over a Socket.

If you need TELNET handling outside of a Socket context; for example
filtering TELNET codes from a raw log, you may be interested in these
transform stream components.

Because TelnetInput and TelnetOutput are Node.js Transform streams,
they support all the same operations that regular streams do. See the
[Node.js Stream API](http://nodejs.org/api/stream.html) for more details.

#### TelnetInput
TelnetInput is a Transform stream for the input side of TELNET.
TELNET commands, options, and negotiations are emitted as events.
Non-TELNET data is passed transparently as input data.

See: Event handlers ('command', 'do', 'dont', 'sub', 'will', 'wont')

Like TelnetSocket, the TelnetInput constructor takes an optional
`options` object supporting options `bufferSize` and `errorPolicy`.

`new TelnetInput([options])`
* `options` - Optional: Options configuration
  * `bufferSize` - The size of the subnegotiation buffer
  * `errorPolicy` - How to handle subnegotiation command errors

#### TelnetOutput
TelnetOutput is a Transform stream for the output side of TELNET.
Data written to TelnetOutput is properly escaped to ensure that it
isn't interpreted as a TELNET command. It also has methods for sending
TELNET option negotiations and subnegotiations.

See: Helper functions (`writeCommand`, `writeDo`, `writeDont`,
`writeSub`, `writeWill`, `writeWont`)

#### Example 0 rewritten with transform streams
This code is equivalent to Example 0, but instead of using TelnetSocket
to decorate the provided Socket, the readable and writable sides
are handled individually by Transform stream objects.

    var net = require('net');
    var TelnetInput = require('telnet-stream').TelnetInput;
    var TelnetOutput = require('telnet-stream').TelnetOutput;

    var socket = net.createConnection(3000, 'godwars2.org', function() {
        var telnetInput = new TelnetInput();
        var telnetOutput = new TelnetOutput();

        socket.pipe(telnetInput).pipe(process.stdout);
        process.stdin.pipe(telnetOutput).pipe(socket);
    });

## Development
In order to make modifications to telnet-stream, you'll need to
establish a development environment:

    git clone https://github.com/blinkdog/telnet-stream.git
    cd telnet-stream
    npm install
    node_modules/.bin/cake rebuild

The source files are located in `src/main/coffee`.  
The test source files are located in `src/test/coffee`.

You can see a coverage report by invoking the `coverage` target:

    node_modules/.bin/cake coverage

## Acknowledgments
* TypeScript defintions were kindly provided by contributor
  [Voakie](https://github.com/Voakie)

## License
telnet-stream  
Copyright 2013-2021 Patrick Meade.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
