# telnet-stream
Transform streams that emit TELNET negotiations as events

## Motivation

Although venerable, the [TELNET](https://en.wikipedia.org/wiki/Telnet)
protocol is still in use by some services and expected by some clients.
If you need to connect to something that "speaks TELNET", this module
offers a pair of bare-bones Transform streams for that purpose.

## Simple Solution

If you need to connect to something that speaks TELNET, but you don't
care about options or negotiations, then simply use the stream as-is.
It will filter out all the "TELNET stuff" and pass the rest on to you.

Because TelnetInput and TelnetOutput are Node.js Transform streams,
they support all the same operations that regular streams do. See the
[Node.js Stream API](http://nodejs.org/api/stream.html) for more details.

    var net = require('net');
    var TelnetInput = require('telnet-stream').TelnetInput;
    var TelnetOutput = require('telnet-stream').TelnetOutput;

    var socket = net.createConnection(3000, 'godwars2.org', function() {
        var telnetInput = new TelnetInput();
        var telnetOutput = new TelnetOutput();

        socket.pipe(telnetInput).pipe(process.stdout);
        process.stdin.pipe(telnetOutput).pipe(socket);
    });

## Usage

Maybe you have more complex needs. Perhaps you need certain options
to be turned on or off, or have important information to pull from
a subnegotiation. telnet-stream has you covered in those situations.

### TelnetInput

TelnetInput is a Transform stream for the input side of TELNET.
TELNET commands, options, and negotiations are emitted as events.
Non-TELNET data is passed transparently as input data.

#### Event: 'command'

When the remote system issues a TELNET command that is not option
negotiation, TelnetInput will emit a 'command' event.

    var telnetIn = new TelnetInput();
    telnetIn.on('command', function(command) {
        // Received: IAC <command> - See RFC 854
    });

#### Event: 'do'

When the remote system wants to request that the local system
perform some function or obey some protocol, TelnetInput will
emit a 'do' event:

    var telnetIn = new TelnetInput();
    telnetIn.on('do', function(option) {
        // Received: IAC DO <option> - See RFC 854
    });

#### Event: 'dont'

When the remote system wants to request that the local system
NOT perform some function or NOT obey some protocol, TelnetInput
will emit a 'dont' event:

    var telnetIn = new TelnetInput();
    telnetIn.on('dont', function(option) {
        // Received: IAC DONT <option> - See RFC 854
    });

#### Event: 'sub'

After negotiating an option, either the local or remote system
may engage in a more complex subnegotiation. For example, the
server and client may agree to use encryption, and then use
subnegotiation to agree on the parameters of that encryption.

    var telnetIn = new TelnetInput();
    telnetIn.on('sub', function(option, buffer) {
        // Received: IAC SB <option> <buffer> IAC SE - See RFC 855
    });

#### Event: 'will'

When the remote system wants to offer that it will perform some
function or obey some protocol for the local system, TelnetInput
will emit a 'will' event:

    var telnetIn = new TelnetInput();
    telnetIn.on('will', function(option) {
        // Received: IAC WILL <option> - See RFC 854
    });

#### Event: 'wont'

When the remote system wants to refuse to perform some function
or obey some protocol for the local system, TelnetInput will
emit a 'wont' event:

    var telnetIn = new TelnetInput();
    telnetIn.on('wont', function(option) {
        // Received: IAC WONT <option> - See RFC 854
    });

### TelnetOutput

TelnetOutput is a Transform stream for the output side of TELNET.
Data written to TelnetOutput is properly escaped to ensure that
it isn't interpreted as a TELNET command. It also has methods for
sending TELNET option negotiations and subnegotiations.

#### IAC escape

TELNET commands start with the Interpret as Command (IAC) octet.
In order to send a literal IAC octet (one that is intended as data,
not as a TELNET command), it must be sent as IAC IAC. TelnetOutput
takes care of this transformation automatically.

#### writeCommand(command)

* command - The command octet to send

Call this method to send a TELNET command to the remote system.

    var NOP = 241; // No operation. -- See RFC 854
    var telnetOut = new TelnetOutput();
    // Sends: IAC NOP
    telnetOut.writeCommand(NOP);

#### writeDo(option)

* option - The option octet to request of the remote system

Call this method to send a TELNET DO option negotiation to the remote
system. A DO request is sent when the local system wants the remote
system to perform some function or obey some protocol.

    var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
    var telnetOut = new TelnetOutput();
    // Sends: IAC DO NAWS
    telnetOut.writeDo(NAWS);

#### writeDont(option)

* option - The option octet to request of the remote system

Call this method to send a TELNET DONT option negotiation to the remote
system. A DONT request is sent when the local system wants the remote
system to NOT perform some function or NOT obey some protocol.

    var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
    var telnetOut = new TelnetOutput();
    // Sends: IAC DONT NAWS
    telnetOut.writeDont(NAWS);

#### writeSub(option, buffer)

* option - The option octet; identifies what the subnegotiation is about
* buffer - The buffer containing the subnegotiation data to send

Call this method to send a TELNET subnegotiation to the remote system.
After the local and remote system have negotiated an option, then
subnegotiation information can be sent.

See Example #2: Negotiate About Window Size (NAWS) below.

#### writeWill(option)

* option - The option octet to offer to the remote system

Call this method to send a TELNET WILL option negotiation to the remote
system. A WILL offer is sent when the local system wants to inform the
remote system that it will perform some function or obey some protocol.

    var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
    var telnetOut = new TelnetOutput();
    // Sends: IAC WILL NAWS
    telnetOut.writeWill(NAWS);

#### writeWont(option)

* option - The option octet to refuse to the remote system

Call this method to send a TELNET WONT option negotiation to the remote
system. A WONT refusal is sent when the remote system has requested that
the local system perform some function or obey some protocol, and the
local system is refusing to do so.

    var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
    var telnetOut = new TelnetOutput();
    // Sends: IAC WONT NAWS
    telnetOut.writeWont(NAWS);

### Example 1: Options Actively Refused

The simple example above provided a simple TELNET client.
However, all TELNET commands were filtered and ignored.
A service might think one was using a very dumb client,
because it refuses to acknowledge TELNET negotiations.

This example does the same thing, but actively refuses
all TELNET options. If the remote service offers something,
we decline to take advantage of it. If the remote service
requests that we do something, we refuse to do it.

    var net = require('net');
    var TelnetInput = require('telnet-stream').TelnetInput;
    var TelnetOutput = require('telnet-stream').TelnetOutput;

    var socket = net.createConnection(3000, 'godwars2.org', function() {
        var telnetInput = new TelnetInput();
        var telnetOutput = new TelnetOutput();

        telnetInput.on('do', function(option) {
            telnetOutput.writeWont(option);
        });

        telnetInput.on('will', function(option) {
            telnetOutput.writeDont(option);
        });

        socket.pipe(telnetInput).pipe(process.stdout);
        process.stdin.pipe(telnetOutput).pipe(socket);
    });

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

    var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
    var net = require('net');
    var TelnetInput = require('telnet-stream').TelnetInput;
    var TelnetOutput = require('telnet-stream').TelnetOutput;

    var serverSocket = net.createServer(function(connection) {
        var telnetInput = new TelnetInput();
        var telnetOutput = new TelnetOutput();

        telnetInput.on('sub', function(option, buffer) {
            if(option === NAWS) {
                var width = buffer.readInt16BE(0);
                var height = buffer.readInt16BE(2);
                console.log( 'Client window: ' + width + 'x' + height);
            }
        });

        connection.pipe(telnetInput).pipe(process.stdout);
        process.stdin.pipe(telnetOutput).pipe(connection);

        telnetOutput.writeDo(NAWS);
    });

    serverSocket.listen(3000);

#### Client Side

This code implements a simple TELNET client that sends NAWS
subnegotiations when the output window is resized. Note that
it only sends NAWS subnegotiations after it has confirmed
that the server supports and wants to hear about them.

    var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
    var net = require('net');
    var TelnetInput = require('telnet-stream').TelnetInput;
    var TelnetOutput = require('telnet-stream').TelnetOutput;

    var socket = net.createConnection(3000, function() {
        var telnetInput = new TelnetInput();
        var telnetOutput = new TelnetOutput();
        var serverNawsOk = false;

        var sendWindowSize = function() {
            var nawsBuffer = new Buffer(4);
            nawsBuffer.writeInt16BE(process.stdout.columns, 0);
            nawsBuffer.writeInt16BE(process.stdout.rows, 2);
            telnetOutput.writeSub(NAWS, nawsBuffer);
        };

        telnetInput.on('do', function(option) {
            if(option === NAWS) {
                serverNawsOk = true;
                telnetOutput.writeWill(NAWS);
                sendWindowSize();
            }
        });

        process.stdout.on('resize', function() {
            if(serverNawsOk) {
                sendWindowSize();
            }
        });

        socket.pipe(telnetInput).pipe(process.stdout);
        process.stdin.pipe(telnetOutput).pipe(socket);

        telnetOutput.writeWill(NAWS);
    });

## Limitations

telnet-stream is not 100% faithful to the TELNET specification.

### Subnegotiations

#### Buffer Size

The input buffer size for TELNET subnegotiations is 8192 bytes. For most
cases, this buffer should suffice. If you are running millions of
simultaneous connections, you may need to reduce it. If your subnegotiations
are HUGE then you may need to increase it.

The size of the buffer is defined at the top of telnetInput.coffee:

    SUBNEG_BUFFER_SIZE = 8192

#### Interpret As Command (IAC)

During a subnegotiation, there are two valid sequences that begin with
IAC. One is to escape another IAC intended as a literal data octet:

    IAC IAC     // this is a literal IAC [Hex 0xFF, Dec 255] octet

The other is to end the ongoing subnegotiation:

    IAC SE      // this signals the end of the subnegotiation

No other sequence is specified in the RFC. No mention is made of
the state of the protocol after receiving an unknown sequence.

telnet-stream will silently consume both the IAC and following
octet and return to consuming subnegotiation data. The final
effect is as if those two octets never existed in the stream.

This error might occur when talking to faulty TELNET implementations
that fail to properly escape IAC bytes as IAC IAC in subnegotiations.

### Network Virtual Terminal (NVT)

In addition to TELNET negotiation, RFC 854 specifies a Network Virtual
Terminal (NVT). Among other things in the NVT specification,
a Carriage Return (CR) [Hex 0x0C, Dec 13] octet must be followed by
either a Line Feed (LF) [Hex 0x0A, Dec 10] octet or a Null (NUL) [Hex 0x00,
Dec 0] octet. It says "the CR character must be avoided in other contexts".

Furthermore, it goes on to specify: "Even though it may be known in some
situations that characters are not being sent to an actual printer,
nonetheless, for the sake of consistency, the protocol requires that a NUL
be inserted following a CR not followed by a LF in the data stream."

telnet-stream DOES NOT respect this part of the specification. The character
following a CR in the data stream is not modified in any way. If you want
or need this behavior, you will need to modify telnet-stream.

## Development

In order to make modifications to telnet-stream, you'll need to
establish a development environment:

    git clone https://github.com/blinkdog/telnet-stream.git
    npm install
    cake rebuild

The source files are located in src/coffee

## License

telnet-stream is Copyright 2013 Patrick Meade.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt)
along with this program.  If not, see <http://www.gnu.org/licenses/>.
