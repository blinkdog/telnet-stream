# telnetInput.coffee
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

SUBNEG_BUFFER_SIZE = 8192

#----------------------------------------------------------------------
#      SE                  240    End of subnegotiation parameters.
#      NOP                 241    No operation.
#      Data Mark           242    The data stream portion of a Synch.
#                                 This should always be accompanied
#                                 by a TCP Urgent notification.
#      Break               243    NVT character BRK.
#      Interrupt Process   244    The function IP.
#      Abort output        245    The function AO.
#      Are You There       246    The function AYT.
#      Erase character     247    The function EC.
#      Erase Line          248    The function EL.
#      Go ahead            249    The GA signal.
#      SB                  250    Indicates that what follows is
#                                 subnegotiation of the indicated
#                                 option.
#      WILL (option code)  251    Indicates the desire to begin
#                                 performing, or confirmation that
#                                 you are now performing, the
#                                 indicated option.
#      WON'T (option code) 252    Indicates the refusal to perform,
#                                 or continue performing, the
#                                 indicated option.
#      DO (option code)    253    Indicates the request that the
#                                 other party perform, or
#                                 confirmation that you are expecting
#                                 the other party to perform, the
#                                 indicated option.
#      DON'T (option code) 254    Indicates the demand that the
#                                 other party stop performing,
#                                 or confirmation that you are no
#                                 longer expecting the other party
#                                 to perform, the indicated option.
#      IAC                 255    Data Byte 255.
#----------------------------------------------------------------------

TELNET_COMMAND = 'TELNET_COMMAND'
TELNET_DATA = 'TELNET_DATA'
TELNET_OPTION = 'TELNET_OPTION'
TELNET_SUBNEG = 'TELNET_SUBNEG'
TELNET_SUBNEG_COMMAND = 'TELNET_SUBNEG_COMMAND'

TELNET_DO = 253
TELNET_DONT = 254
TELNET_IAC = 255
TELNET_SUB_BEGIN = 250
TELNET_SUB_END = 240
TELNET_WILL = 251
TELNET_WONT = 252

Transform = require('stream').Transform
util = require 'util'

TelnetInput = (options) ->
  return new TelnetInput options if (this instanceof TelnetInput) is false

  Transform.call this, options
  @state = TELNET_DATA
  @subBuf = new Buffer SUBNEG_BUFFER_SIZE

  @_transform = (chunk, encoding, done) ->
    @dataBuf = new Buffer chunk.length
    @dataBufIndex = 0
    @handle chunk[i] for i in [0..chunk.length-1]
    @push @dataBuf.slice 0, @dataBufIndex if @dataBufIndex > 0
    done()

  @handle = (chunkData) ->
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
            @emit 'command', chunkData

      when TELNET_OPTION
        switch @command
          when TELNET_DO
            @state = TELNET_DATA
            @emit 'do', chunkData
          when TELNET_DONT
            @state = TELNET_DATA
            @emit 'dont', chunkData
          when TELNET_WILL
            @state = TELNET_DATA
            @emit 'will', chunkData
          when TELNET_WONT
            @state = TELNET_DATA
            @emit 'wont', chunkData
          when TELNET_SUB_BEGIN
            @state = TELNET_SUBNEG
            @option = chunkData
            @subBufIndex = 0

      when TELNET_SUBNEG
        switch chunkData
          when TELNET_IAC
            @state = TELNET_SUBNEG_COMMAND
          else
            @subBuf[@subBufIndex] = chunkData
            @subBufIndex++

      when TELNET_SUBNEG_COMMAND
        switch chunkData
          when TELNET_IAC
            @state = TELNET_SUBNEG
            @subBuf[@subBufIndex] = TELNET_IAC
            @subBufIndex++
          when TELNET_SUB_END
            @state = TELNET_DATA
            @emit 'sub', @option, @subBuf.slice 0, @subBufIndex
          else
            @state = TELNET_SUBNEG

  return this

util.inherits TelnetInput, Transform

exports.TelnetInput = TelnetInput

#----------------------------------------------------------------------------
# end of telnetInput.coffee
