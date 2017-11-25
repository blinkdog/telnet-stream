# telnetSocketTest.coffee
# Copyright 2017 Patrick Meade.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#----------------------------------------------------------------------------

TELNET_FAKE_OPTION = 70
TELNET_GO_AHEAD = 249

net = require "net"
should = require "should"
{TelnetSocket} = require "../lib/telnetStream"

describe "TelnetSocket", ->
  it "should fail if not decorating something", (done) ->
    try
      testStream = new TelnetSocket()
      done new Error "exception not thrown!"
    catch err
      done()

  it "should fail if not decorating a net.Socket", (done) ->
    try
      testStream = new TelnetSocket {}
      done new Error "exception not thrown!"
    catch err
      done()

  it "should be able to negotiate with another TelnetSocket", (done) ->
    server = net.createServer (socket) ->
      socket.unref()
      srvrSocket = new TelnetSocket socket
      srvrSocket.on "do", (option) ->
        srvrSocket.writeWont option
    server.unref()
    server.listen 40000
    socket = net.createConnection 40000
    socket.unref()
    clntSocket = new TelnetSocket socket
    clntSocket.on "wont", (option) ->
      if option is TELNET_FAKE_OPTION
        server.close ->
          done()
        clntSocket.end()
    clntSocket.writeDo TELNET_FAKE_OPTION

  it "should be able to talk with another TelnetSocket", (done) ->
    server = net.createServer (socket) ->
      socket.unref()
      srvrSocket = new TelnetSocket socket
      srvrSocket.on "data", (chunk) ->
        text = chunk.toString "utf8"
        if text is "Hello, server!\n"
          srvrSocket.write "Hello, client!\n"
    server.unref()
    server.listen 40000
    socket = net.createConnection 40000
    socket.unref()
    clntSocket = new TelnetSocket socket
    clntSocket.on "data", (chunk) ->
      text = chunk.toString "utf8"
      if text is "Hello, client!\n"
        server.close ->
          done()
        clntSocket.end()
    clntSocket.write "Hello, server!\n"

  it "should pass most calls through to Socket", (done) ->
    PASSTHROUGH_FUNCS = [
      "address"
      "connect"
      "destroy"
      "end"
      "pause"
      "ref"
      "resume"
      "setEncoding"
      "setKeepAlive"
      "setNoDelay"
      "setTimeout"
      "unref"
    ]
    count = 0
    socket = new net.Socket()
    tSocket = new TelnetSocket socket
    for name in PASSTHROUGH_FUNCS
      socket[name] = ->
        count++
        done() if count >= PASSTHROUGH_FUNCS.length
    for name in PASSTHROUGH_FUNCS
      tSocket[name]()

  it "should be able to negotiate with another TelnetSocket", (done) ->
    server = net.createServer (socket) ->
      socket.unref()
      srvrSocket = new TelnetSocket socket
      srvrSocket.on "will", (option) ->
        srvrSocket.writeDont option
    server.unref()
    server.listen 40000
    socket = net.createConnection 40000
    socket.unref()
    clntSocket = new TelnetSocket socket
    clntSocket.on "dont", (option) ->
      if option is TELNET_FAKE_OPTION
        server.close ->
          done()
        clntSocket.end()
    clntSocket.writeWill TELNET_FAKE_OPTION

  it "should be able to subnegotiate with another TelnetSocket", (done) ->
    server = net.createServer (socket) ->
      socket.unref()
      srvrSocket = new TelnetSocket socket
      srvrSocket.on "sub", (option, buffer) ->
        if option is TELNET_FAKE_OPTION
          srvrSocket.writeDont option
    server.unref()
    server.listen 40000
    socket = net.createConnection 40000
    socket.unref()
    clntSocket = new TelnetSocket socket
    clntSocket.on "dont", (option) ->
      if option is TELNET_FAKE_OPTION
        server.close ->
          done()
        clntSocket.end()
    clntSocket.writeSub TELNET_FAKE_OPTION, Buffer.alloc 4

  it "should be able to send commands to another TelnetSocket", (done) ->
    server = net.createServer (socket) ->
      socket.unref()
      srvrSocket = new TelnetSocket socket
      srvrSocket.on "sub", (option, buffer) ->
        if option is TELNET_FAKE_OPTION
          srvrSocket.writeCommand TELNET_GO_AHEAD
    server.unref()
    server.listen 40000
    socket = net.createConnection 40000
    socket.unref()
    clntSocket = new TelnetSocket socket
    clntSocket.on "command", (option) ->
      if option is TELNET_GO_AHEAD
        server.close ->
          done()
        clntSocket.end()
    clntSocket.writeSub TELNET_FAKE_OPTION, Buffer.alloc 4

  it "should be able to register for Socket events", (done) ->
    server = net.createServer (socket) ->
      socket.unref()
      srvrSocket = new TelnetSocket socket
      srvrSocket.on "will", (option) ->
        srvrSocket.writeDont option
    server.unref()
    server.listen 40000
    socket = net.createConnection 40000
    socket.unref()
    clntSocket = new TelnetSocket socket
    clntSocket.on "end", ->
      done()
    clntSocket.on "dont", (option) ->
      if option is TELNET_FAKE_OPTION
        clntSocket.end()
    clntSocket.writeWill TELNET_FAKE_OPTION

#----------------------------------------------------------------------------
# end of telnetSocketTest.coffee
