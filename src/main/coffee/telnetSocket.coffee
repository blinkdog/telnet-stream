# telnetSocket.coffee
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

{Socket} = require "net"
{TelnetInput, TelnetOutput} = require "./telnetStream"

class TelnetSocket
  constructor: (@_socket, opt) ->
    if not (@_socket instanceof Socket)
      throw new Error "required: net.Socket"
    options = opt || {}
    @_in = new TelnetInput options
    @_out = new TelnetOutput options
    @_socket.pipe @_in
    @_out.pipe @_socket

  address: ->
    @_socket.address.apply @_socket, arguments

  connect: ->
    @_socket.connect.apply @_socket, arguments

  destroy: ->
    @_socket.destroy.apply @_socket, arguments

  end: ->
    @_socket.end.apply @_socket, arguments

  on: (name, callback) ->
    switch name
      when "command", "data", "do", "dont", "sub", "will", "wont"
        return @_in.on name, callback
      else
        return @_socket.on name, callback

  pause: ->
    @_socket.pause.apply @_socket, arguments

  ref: ->
    @_socket.ref.apply @_socket, arguments

  resume: ->
    @_socket.resume.apply @_socket, arguments

  setEncoding: ->
    @_socket.setEncoding.apply @_socket, arguments

  setKeepAlive: ->
    @_socket.setKeepAlive.apply @_socket, arguments

  setNoDelay: ->
    @_socket.setNoDelay.apply @_socket, arguments

  setTimeout: ->
    @_socket.setTimeout.apply @_socket, arguments

  unref: ->
    @_socket.unref.apply @_socket, arguments

  write: ->
    @_out.write.apply @_out, arguments

  writeCommand: (command) ->
    @_out.writeCommand command

  writeDo: (option) ->
    @_out.writeDo option

  writeDont: (option) ->
    @_out.writeDont option

  writeSub: (option, buffer) ->
    @_out.writeSub option, buffer

  writeWill: (option) ->
    @_out.writeWill option

  writeWont: (option) ->
    @_out.writeWont option

exports.TelnetSocket = TelnetSocket

#----------------------------------------------------------------------------
# end of telnetSocket.coffee
