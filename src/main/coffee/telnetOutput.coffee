# telnetOutput.coffee
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

{Transform} = require "stream"

class TelnetOutput extends Transform
  constructor: (options) ->
    super options

  _transform: (chunk, encoding, done) ->
    @push @_duplicateIAC chunk
    done()

  _duplicateIAC: (buffer) ->
    xlateIndex = 0
    xlateBuf = Buffer.alloc buffer.length * 2
    for byte in buffer
      xlateBuf[xlateIndex] = byte
      xlateIndex++
      if byte is TELNET_IAC
        xlateBuf[xlateIndex] = byte
        xlateIndex++
    return xlateBuf.slice 0, xlateIndex

  _writeOption: (command, option) ->
    cmdBuf = Buffer.alloc 3
    cmdBuf[0] = TELNET_IAC
    cmdBuf[1] = command
    cmdBuf[2] = option
    @push cmdBuf

  writeCommand: (command) ->
    cmdBuf = Buffer.alloc 2
    cmdBuf[0] = TELNET_IAC
    cmdBuf[1] = command
    @push cmdBuf

  writeDo: (option) ->
    @_writeOption TELNET_DO, option

  writeDont: (option) ->
    @_writeOption TELNET_DONT, option

  writeSub: (option, buffer) ->
    negBuf = @_duplicateIAC buffer
    subBegin = Buffer.alloc 3
    subBegin[0] = TELNET_IAC
    subBegin[1] = TELNET_SUB_BEGIN
    subBegin[2] = option
    subEnd = Buffer.alloc 2
    subEnd[0] = TELNET_IAC
    subEnd[1] = TELNET_SUB_END
    subBuf = Buffer.concat [subBegin, negBuf, subEnd], negBuf.length+5
    @push subBuf

  writeWill: (option) ->
    @_writeOption TELNET_WILL, option

  writeWont: (option) ->
    @_writeOption TELNET_WONT, option

exports.TelnetOutput = TelnetOutput

#----------------------------------------------------------------------------
# end of telnetOutput.coffee
