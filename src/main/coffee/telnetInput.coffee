# telnetInput.coffee
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

DEFAULT_SUBNEGOTIATION_BUFFER_SIZE = 8192
DEFAULT_SUBNEGOTIATION_ERROR_POLICY = "keepBoth"

TELNET_COMMAND = "TELNET_COMMAND"
TELNET_DATA = "TELNET_DATA"
TELNET_OPTION = "TELNET_OPTION"
TELNET_SUBNEG = "TELNET_SUBNEG"
TELNET_SUBNEG_COMMAND = "TELNET_SUBNEG_COMMAND"

TELNET_DO = 253
TELNET_DONT = 254
TELNET_IAC = 255
TELNET_SUB_BEGIN = 250
TELNET_SUB_END = 240
TELNET_WILL = 251
TELNET_WONT = 252

{Transform} = require "stream"

class TelnetInput extends Transform
  constructor: (opt) ->
    options = opt || {}
    super options
    @state = TELNET_DATA
    @subBufSize = options.bufferSize || DEFAULT_SUBNEGOTIATION_BUFFER_SIZE
    @subBuf = Buffer.alloc @subBufSize
    @errorPolicy = options.errorPolicy || DEFAULT_SUBNEGOTIATION_ERROR_POLICY

  _transform: (chunk, encoding, callback) ->
    @dataBuf = Buffer.alloc chunk.length*2
    @dataBufIndex = 0
    @_handle byte for byte in chunk
    @push @dataBuf.slice 0, @dataBufIndex if @dataBufIndex > 0
    callback()

  _handle: (chunkData) ->
    switch @state
      when TELNET_DATA
        switch chunkData
          when TELNET_IAC
            @state = TELNET_COMMAND
          else
            @dataBuf[@dataBufIndex] = chunkData
            @dataBufIndex++

      when TELNET_COMMAND
        switch chunkData
          when TELNET_IAC
            @state = TELNET_DATA
            @dataBuf[@dataBufIndex] = TELNET_IAC
            @dataBufIndex++
          when TELNET_DO, TELNET_DONT, TELNET_WILL, TELNET_WONT, TELNET_SUB_BEGIN
            @state = TELNET_OPTION
            @command = chunkData
          else
            @state = TELNET_DATA
            @emit "command", chunkData

      when TELNET_OPTION
        switch @command
          when TELNET_DO
            @state = TELNET_DATA
            @emit "do", chunkData
          when TELNET_DONT
            @state = TELNET_DATA
            @emit "dont", chunkData
          when TELNET_WILL
            @state = TELNET_DATA
            @emit "will", chunkData
          when TELNET_WONT
            @state = TELNET_DATA
            @emit "wont", chunkData
          when TELNET_SUB_BEGIN
            @state = TELNET_SUBNEG
            @option = chunkData
            @subBufIndex = 0
            @subOverflowEmit = false

      when TELNET_SUBNEG
        switch chunkData
          when TELNET_IAC
            @state = TELNET_SUBNEG_COMMAND
          else
            @_handleSub chunkData

      when TELNET_SUBNEG_COMMAND
        switch chunkData
          when TELNET_IAC
            @state = TELNET_SUBNEG
            @_handleSub TELNET_IAC
          when TELNET_SUB_END
            @state = TELNET_DATA
            @emit "sub", @option, @subBuf.slice 0, @subBufIndex
          else
            @state = TELNET_SUBNEG
            @emit "error", new Error "expected IAC or SE"
            switch @errorPolicy
              when "discardBoth"
                return
              when "keepData"
                return @_handleSub chunkData
              else
                # "keepBoth"
                @_handleSub TELNET_IAC
                @_handleSub chunkData

  _handleSub: (subByte) ->
    if @subBufIndex >= @subBufSize
      if not @subOverflowEmit
        @subOverflowEmit = true
        @emit "error", new Error "subnegotiation buffer overflow"
      return
    @subBuf[@subBufIndex] = subByte
    @subBufIndex++

exports.TelnetInput = TelnetInput

#----------------------------------------------------------------------------
# end of telnetInput.coffee
