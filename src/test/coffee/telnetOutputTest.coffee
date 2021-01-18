# telnetOutputTest.coffee
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
TelnetOutput = require("../lib/telnetOutput").TelnetOutput

describe "TelnetOutput", ->
  it "should be an instance of TelnetOutput", ->
    testStream = new TelnetOutput()
    testStream.should.be.an.instanceOf TelnetOutput

  it "should have a defined _transform method", ->
    testStream = new TelnetOutput()
    testStream.should.have.property "_transform"

  it "should not duplicate anything not IAC", (done) ->
    testData = Buffer.alloc 255
    testData[i] = i for i in [0..254]
    finalBuffer = Buffer.alloc 255
    finalBufferIndex = 0
    testStream = new TelnetOutput()
    testStream.on "end", ->
      finalBuffer[i].should.equal testData[i] for i in [0..254]
      done()
    testStream.on "data", (chunk) ->
      chunkIndex = 0
      while chunkIndex < chunk.length
        finalBuffer[finalBufferIndex] = chunk[chunkIndex]
        finalBufferIndex++
        chunkIndex++
    testStream.end testData

  it "should duplicate every IAC", (done) ->
    testData = Buffer.alloc 10
    testData[i] = TELNET_IAC for i in [0..9]
    finalBuffer = Buffer.alloc 20
    finalBufferIndex = 0
    testStream = new TelnetOutput()
    testStream.on "end", ->
      finalBuffer[i].should.equal TELNET_IAC for i in [0..19]
      done()
    testStream.on "data", (chunk) ->
      chunkIndex = 0
      while chunkIndex < chunk.length
        finalBuffer[finalBufferIndex] = chunk[chunkIndex]
        finalBufferIndex++
        chunkIndex++
    testStream.end testData

  it "should have defined telnet methods", ->
    testStream = new TelnetOutput()
    testStream.should.have.properties ["writeCommand",
      "writeDo", "writeDont", "writeSub", "writeWill", "writeWont"]

  it "should have writeCommand pass the command byte", (done) ->
    finalBuffer = Buffer.alloc 20
    finalBufferIndex = 0
    testStream = new TelnetOutput()
    testStream.on "end", ->
      finalBuffer[0].should.equal TELNET_IAC
      finalBuffer[1].should.equal TELNET_GO_AHEAD
      done()
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.writeCommand TELNET_GO_AHEAD
    testStream.end()

  it "should have writeDo emit IAC DO option", (done) ->
    finalBuffer = Buffer.alloc 20
    finalBufferIndex = 0
    testStream = new TelnetOutput()
    testStream.on "end", ->
      finalBuffer[0].should.equal TELNET_IAC
      finalBuffer[1].should.equal TELNET_DO
      finalBuffer[2].should.equal TELNET_FAKE_OPTION
      done()
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.writeDo TELNET_FAKE_OPTION
    testStream.end()

  it "should have writeDont emit IAC DONT option", (done) ->
    finalBuffer = Buffer.alloc 20
    finalBufferIndex = 0
    testStream = new TelnetOutput()
    testStream.on "end", ->
      finalBuffer[0].should.equal TELNET_IAC
      finalBuffer[1].should.equal TELNET_DONT
      finalBuffer[2].should.equal TELNET_FAKE_OPTION
      done()
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.writeDont TELNET_FAKE_OPTION
    testStream.end()

  it "should have writeWill emit IAC WILL option", (done) ->
    finalBuffer = Buffer.alloc 20
    finalBufferIndex = 0
    testStream = new TelnetOutput()
    testStream.on "end", ->
      finalBuffer[0].should.equal TELNET_IAC
      finalBuffer[1].should.equal TELNET_WILL
      finalBuffer[2].should.equal TELNET_FAKE_OPTION
      done()
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.writeWill TELNET_FAKE_OPTION
    testStream.end()

  it "should have writeWont emit IAC WONT option", (done) ->
    finalBuffer = Buffer.alloc 20
    finalBufferIndex = 0
    testStream = new TelnetOutput()
    testStream.on "end", ->
      finalBuffer[0].should.equal TELNET_IAC
      finalBuffer[1].should.equal TELNET_WONT
      finalBuffer[2].should.equal TELNET_FAKE_OPTION
      done()
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.writeWont TELNET_FAKE_OPTION
    testStream.end()

  it "should have writeSub emit a proper subnegotiation", (done) ->
    finalBuffer = Buffer.alloc 20
    finalBufferIndex = 0
    testStream = new TelnetOutput()
    testStream.on "end", ->
      finalBuffer[0].should.equal TELNET_IAC
      finalBuffer[1].should.equal TELNET_SUB_BEGIN
      finalBuffer[2].should.equal TELNET_FAKE_OPTION
      finalBuffer[3].should.equal 1
      finalBuffer[4].should.equal 2
      finalBuffer[5].should.equal 3
      finalBuffer[6].should.equal 4
      finalBuffer[7].should.equal 5
      finalBuffer[8].should.equal TELNET_IAC
      finalBuffer[9].should.equal TELNET_SUB_END
      done()
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    fakeBuffer = Buffer.alloc 5
    fakeBuffer[i] = (i+1) for i in [0..4]
    testStream.writeSub TELNET_FAKE_OPTION, fakeBuffer
    testStream.end()

  it "should have writeSub escape IACs in subnegotiations", (done) ->
    finalBuffer = Buffer.alloc 20
    finalBufferIndex = 0
    testStream = new TelnetOutput()
    testStream.on "end", ->
      finalBuffer[ 0].should.equal TELNET_IAC
      finalBuffer[ 1].should.equal TELNET_SUB_BEGIN
      finalBuffer[ 2].should.equal TELNET_FAKE_OPTION

      finalBuffer[ 3].should.equal TELNET_IAC
      finalBuffer[ 4].should.equal TELNET_IAC

      finalBuffer[ 5].should.equal TELNET_IAC
      finalBuffer[ 6].should.equal TELNET_IAC

      finalBuffer[ 7].should.equal TELNET_IAC
      finalBuffer[ 8].should.equal TELNET_IAC

      finalBuffer[ 9].should.equal TELNET_IAC
      finalBuffer[10].should.equal TELNET_IAC

      finalBuffer[11].should.equal TELNET_IAC
      finalBuffer[12].should.equal TELNET_IAC

      finalBuffer[13].should.equal TELNET_IAC
      finalBuffer[14].should.equal TELNET_SUB_END
      done()
    testStream.on "data", (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    fakeBuffer = Buffer.alloc 5
    fakeBuffer[i] = TELNET_IAC for i in [0..4]
    testStream.writeSub TELNET_FAKE_OPTION, fakeBuffer
    testStream.end()

#----------------------------------------------------------------------------
# end of telnetOutputTest.coffee
