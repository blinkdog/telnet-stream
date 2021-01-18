# telnetInputTest.coffee
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

TELNET_DO = 253
TELNET_DONT = 254
TELNET_IAC = 255
TELNET_SUB_BEGIN = 250
TELNET_SUB_END = 240
TELNET_WILL = 251
TELNET_WONT = 252

TELNET_FAKE_OPTION = 70

TELNET_GO_AHEAD = 249

should = require "should"
TelnetInput = require("../lib/telnetInput").TelnetInput

describe "TelnetInput", ->
  it "should be an instance of TelnetInput", ->
    testStream = new TelnetInput()
    testStream.should.be.an.instanceOf TelnetInput

  it "should have a defined _transform method", ->
    testStream = new TelnetInput()
    testStream.should.have.property "_transform"

  it "should pass normal text through", (done) ->
    testData = "Hello, TelnetInput!"
    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0
    testStream = new TelnetInput()
    testStream.on "end", ->
      result = finalBuffer.toString "utf8", 0, finalBufferIndex
      result.should.equal testData
      done()
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testData

  it "should emit a WILL event", (done) ->
    testBuffer = Buffer.alloc 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_WILL
    testBuffer[2] = TELNET_FAKE_OPTION

    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0

    testStream = new TelnetInput()
    testStream.on "will", (option) ->
      done() if option is TELNET_FAKE_OPTION
      done new Error option if option isnt TELNET_FAKE_OPTION
    testStream.on "end", ->
      finalBufferIndex.should.equal 0
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 3

  it "should emit a WONT event", (done) ->
    testBuffer = Buffer.alloc 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_WONT
    testBuffer[2] = TELNET_FAKE_OPTION

    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0

    testStream = new TelnetInput()
    testStream.on "wont", (option) ->
      done() if option is TELNET_FAKE_OPTION
      done new Error option if option isnt TELNET_FAKE_OPTION
    testStream.on "end", ->
      finalBufferIndex.should.equal 0
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 3

  it "should emit a DO event", (done) ->
    testBuffer = Buffer.alloc 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_DO
    testBuffer[2] = TELNET_FAKE_OPTION

    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0

    testStream = new TelnetInput()
    testStream.on "do", (option) ->
      done() if option is TELNET_FAKE_OPTION
      done new Error option if option isnt TELNET_FAKE_OPTION
    testStream.on "end", ->
      finalBufferIndex.should.equal 0
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 3

  it "should emit a DONT event", (done) ->
    testBuffer = Buffer.alloc 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_DONT
    testBuffer[2] = TELNET_FAKE_OPTION

    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0

    testStream = new TelnetInput()
    testStream.on "dont", (option) ->
      done() if option is TELNET_FAKE_OPTION
      done new Error option if option isnt TELNET_FAKE_OPTION
    testStream.on "end", ->
      finalBufferIndex.should.equal 0
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 3

  it "should emit a command event", (done) ->
    testBuffer = Buffer.alloc 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_GO_AHEAD

    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0

    testStream = new TelnetInput()
    testStream.on "command", (option) ->
      done() if option is TELNET_GO_AHEAD
      done new Error option if option isnt TELNET_GO_AHEAD
    testStream.on "end", ->
      finalBufferIndex.should.equal 0
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 2

  it "should properly escape IAC bytes", (done) ->
    testBuffer = Buffer.alloc 1024
    testBuffer[i] = TELNET_IAC for i in [0..7]

    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0

    testStream = new TelnetInput()
    testStream.on "end", ->
      finalBufferIndex.should.equal 4
      finalBuffer[i].should.equal TELNET_IAC for i in [0..3]
      done()
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 8

  it "should emit a sub event", (done) ->
    testBuffer = Buffer.alloc 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_SUB_BEGIN
    testBuffer[2] = TELNET_FAKE_OPTION
    testBuffer[3] = 1
    testBuffer[4] = 2
    testBuffer[5] = 3
    testBuffer[6] = 4
    testBuffer[7] = 5
    testBuffer[8] = TELNET_IAC
    testBuffer[9] = TELNET_SUB_END

    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0

    testStream = new TelnetInput()
    testStream.on "sub", (option, buffer) ->
      option.should.equal TELNET_FAKE_OPTION
      buffer.should.be.ok
      buffer.length.should.equal 5
      buffer[i].should.equal i+1 for i in [0..4]
      done()
    testStream.on "end", ->
      finalBufferIndex.should.equal 0
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 10

  it "should properly escape IAC bytes in a subnegotiation", (done) ->
    testBuffer = Buffer.alloc 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_SUB_BEGIN
    testBuffer[2] = TELNET_FAKE_OPTION
    testBuffer[3] = 1
    testBuffer[4] = 2
    testBuffer[5] = TELNET_IAC
    testBuffer[6] = TELNET_IAC
    testBuffer[7] = 4
    testBuffer[8] = 5
    testBuffer[9] = TELNET_IAC
    testBuffer[10] = TELNET_SUB_END

    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0

    testStream = new TelnetInput()
    testStream.on "sub", (option, buffer) ->
      option.should.equal TELNET_FAKE_OPTION
      buffer.should.be.ok
      buffer.length.should.equal 5
      buffer[0].should.equal 1
      buffer[1].should.equal 2
      buffer[2].should.equal TELNET_IAC
      buffer[3].should.equal 4
      buffer[4].should.equal 5
      done()
    testStream.on "end", ->
      finalBufferIndex.should.equal 0
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = byte for byte in chunk
    testStream.end testBuffer.slice 0, 11

  it "should emit an error for unescaped IAC in a subnegotiation", (done) ->
    errorCalled = false
    testBuffer = Buffer.alloc 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_SUB_BEGIN
    testBuffer[2] = TELNET_FAKE_OPTION
    testBuffer[3] = 1
    testBuffer[4] = 2
    testBuffer[5] = TELNET_IAC
    testBuffer[6] = 4
    testBuffer[7] = 5
    testBuffer[8] = TELNET_IAC
    testBuffer[9] = TELNET_SUB_END

    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0

    testStream = new TelnetInput()
    testStream.on "error", (err) ->
      errorCalled = true if err?
    testStream.on "sub", (option, buffer) ->
      option.should.equal TELNET_FAKE_OPTION
      buffer.should.be.ok
      buffer.length.should.equal 5
      buffer[0].should.equal 1
      buffer[1].should.equal 2
      buffer[2].should.equal TELNET_IAC
      buffer[3].should.equal 4
      buffer[4].should.equal 5
      return done() if errorCalled?
      done new Error "expected 'error' event for unescaped IAC"
    testStream.on "end", ->
      finalBufferIndex.should.equal 0
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = byte for byte in chunk
    testStream.end testBuffer.slice 0, 10

  it "should emit an error if the subnegotiation buffer overflows", (done) ->
    subBegin = Buffer.from [TELNET_IAC, TELNET_SUB_BEGIN, TELNET_FAKE_OPTION]
    data = Buffer.alloc 128
    subEnd = Buffer.from [TELNET_IAC, TELNET_SUB_END]
    testBuffer = Buffer.concat [subBegin, data, subEnd]
    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0
    testStream = new TelnetInput
      bufferSize: 64
    testStream.on "sub", (option, buffer) ->
      option.should.equal TELNET_FAKE_OPTION
      buffer.should.be.ok()
      buffer.length.should.equal 64
      for byte in buffer
        byte.should.equal 0
    testStream.on "error", ->
      done()
    testStream.on "end", ->
      finalBufferIndex.should.equal 0
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = byte for byte in chunk
    testStream.end testBuffer

  it "should discard subnegotiation errors if configured", (done) ->
    errorCalled = false
    testBuffer = Buffer.alloc 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_SUB_BEGIN
    testBuffer[2] = TELNET_FAKE_OPTION
    testBuffer[3] = 1
    testBuffer[4] = 2
    testBuffer[5] = TELNET_IAC
    testBuffer[6] = 4
    testBuffer[7] = 5
    testBuffer[8] = TELNET_IAC
    testBuffer[9] = TELNET_SUB_END

    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0

    testStream = new TelnetInput
      errorPolicy: "discardBoth"
    testStream.on "error", (err) ->
      errorCalled = true if err?
    testStream.on "sub", (option, buffer) ->
      option.should.equal TELNET_FAKE_OPTION
      buffer.should.be.ok()
      buffer.length.should.equal 3
      buffer[0].should.equal 1
      buffer[1].should.equal 2
      buffer[2].should.equal 5
      return done() if errorCalled?
      done new Error "expected 'error' event for unescaped IAC"
    testStream.on "end", ->
      finalBufferIndex.should.equal 0
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = byte for byte in chunk
    testStream.end testBuffer.slice 0, 10

  it "should discard IAC of subnegotiation errors if configured", (done) ->
    errorCalled = false
    testBuffer = Buffer.alloc 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_SUB_BEGIN
    testBuffer[2] = TELNET_FAKE_OPTION
    testBuffer[3] = 1
    testBuffer[4] = 2
    testBuffer[5] = TELNET_IAC
    testBuffer[6] = 4
    testBuffer[7] = 5
    testBuffer[8] = TELNET_IAC
    testBuffer[9] = TELNET_SUB_END

    finalBuffer = Buffer.alloc 1024
    finalBufferIndex = 0

    testStream = new TelnetInput
      errorPolicy: "keepData"
    testStream.on "error", (err) ->
      errorCalled = true if err?
    testStream.on "sub", (option, buffer) ->
      option.should.equal TELNET_FAKE_OPTION
      buffer.should.be.ok()
      buffer.length.should.equal 4
      buffer[0].should.equal 1
      buffer[1].should.equal 2
      buffer[2].should.equal 4
      buffer[3].should.equal 5
      return done() if errorCalled?
      done new Error "expected 'error' event for unescaped IAC"
    testStream.on "end", ->
      finalBufferIndex.should.equal 0
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = byte for byte in chunk
    testStream.end testBuffer.slice 0, 10

#----------------------------------------------------------------------------
# end of telnetInputTest.coffee
