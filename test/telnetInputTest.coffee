# telnetInputTest.coffee
# Copyright 2013 Patrick Meade. All rights reserved.
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

should = require 'should'
TelnetInput = require('../lib/telnetInput').TelnetInput

describe 'TelnetInput', ->
  it 'should be an instance of TelnetInput', ->
    testStream = new TelnetInput()
    testStream.should.be.an.instanceOf TelnetInput

  it 'should have a defined _transform method', ->
    testStream = new TelnetInput()
    testStream.should.have.property '_transform'

  it 'should pass normal text through', (done) ->
    testData = 'Hello, TelnetInput!'
    finalBuffer = new Buffer 1024
    finalBufferIndex = 0
    testStream = new TelnetInput()
    testStream.on 'end', ->
      result = finalBuffer.toString 'utf8', 0, finalBufferIndex
      result.should.equal testData
      done()
    testStream.on 'data', (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testData

  it 'should emit a WILL event', (done) ->
    testBuffer = new Buffer 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_WILL
    testBuffer[2] = TELNET_FAKE_OPTION
    
    finalBuffer = new Buffer 1024
    finalBufferIndex = 0
    
    testStream = new TelnetInput()
    testStream.on 'will', (option) ->
      done() if option is TELNET_FAKE_OPTION
      done new Error option if option isnt TELNET_FAKE_OPTION
    testStream.on 'end', ->
      finalBufferIndex.should.equal 0
    testStream.on 'data', (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 3

  it 'should emit a WONT event', (done) ->
    testBuffer = new Buffer 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_WONT
    testBuffer[2] = TELNET_FAKE_OPTION
    
    finalBuffer = new Buffer 1024
    finalBufferIndex = 0
    
    testStream = new TelnetInput()
    testStream.on 'wont', (option) ->
      done() if option is TELNET_FAKE_OPTION
      done new Error option if option isnt TELNET_FAKE_OPTION
    testStream.on 'end', ->
      finalBufferIndex.should.equal 0
    testStream.on 'data', (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 3

  it 'should emit a DO event', (done) ->
    testBuffer = new Buffer 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_DO
    testBuffer[2] = TELNET_FAKE_OPTION
    
    finalBuffer = new Buffer 1024
    finalBufferIndex = 0
    
    testStream = new TelnetInput()
    testStream.on 'do', (option) ->
      done() if option is TELNET_FAKE_OPTION
      done new Error option if option isnt TELNET_FAKE_OPTION
    testStream.on 'end', ->
      finalBufferIndex.should.equal 0
    testStream.on 'data', (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 3

  it 'should emit a DONT event', (done) ->
    testBuffer = new Buffer 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_DONT
    testBuffer[2] = TELNET_FAKE_OPTION
    
    finalBuffer = new Buffer 1024
    finalBufferIndex = 0
    
    testStream = new TelnetInput()
    testStream.on 'dont', (option) ->
      done() if option is TELNET_FAKE_OPTION
      done new Error option if option isnt TELNET_FAKE_OPTION
    testStream.on 'end', ->
      finalBufferIndex.should.equal 0
    testStream.on 'data', (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 3

  it 'should emit a command event', (done) ->
    testBuffer = new Buffer 1024
    testBuffer[0] = TELNET_IAC
    testBuffer[1] = TELNET_GO_AHEAD
    
    finalBuffer = new Buffer 1024
    finalBufferIndex = 0
    
    testStream = new TelnetInput()
    testStream.on 'command', (option) ->
      done() if option is TELNET_GO_AHEAD
      done new Error option if option isnt TELNET_GO_AHEAD
    testStream.on 'end', ->
      finalBufferIndex.should.equal 0
    testStream.on 'data', (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 2

  it 'should properly escape IAC bytes', (done) ->
    testBuffer = new Buffer 1024
    testBuffer[i] = TELNET_IAC for i in [0..7]
    
    finalBuffer = new Buffer 1024
    finalBufferIndex = 0
    
    testStream = new TelnetInput()
    testStream.on 'end', ->
      finalBufferIndex.should.equal 4
      finalBuffer[i].should.equal TELNET_IAC for i in [0..3]
      done()
    testStream.on 'data', (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 8

  it 'should emit a sub event', (done) ->
    testBuffer = new Buffer 1024
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
    
    finalBuffer = new Buffer 1024
    finalBufferIndex = 0
    
    testStream = new TelnetInput()
    testStream.on 'sub', (option, buffer) ->
      option.should.equal TELNET_FAKE_OPTION
      buffer.should.be.ok
      buffer.length.should.equal 5
      buffer[i].should.equal i+1 for i in [0..4]
      done()
    testStream.on 'end', ->
      finalBufferIndex.should.equal 0
    testStream.on 'data', (chunk) ->
      finalBuffer[finalBufferIndex++] = chunk[i] for i in [0..chunk.length-1]
    testStream.end testBuffer.slice 0, 10

#----------------------------------------------------------------------------
# end of telnetInputTest.coffee
