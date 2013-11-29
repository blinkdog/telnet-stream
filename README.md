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
    var TelnetInput = require('telnet-stream').TelnetInput
    var TelnetOutput = require('telnet-stream').TelnetOutput

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

    // TODO: Finish documentation

#### Events

##### command
##### do
##### dont
##### sub
##### will
##### wont

### TelnetOutput

    // TODO: Finish documentation

#### IAC escape

#### Methods

##### writeCommand
##### writeDo
##### writeDont
##### writeSub
##### writeWill
##### writeWont

### Example: Negotiate About Window Size (NAWS)

// TODO: Finish documentation
Some text explaining the case for NAWS.

    // TODO: Some example code demonstrating NAWS support

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
