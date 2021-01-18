/**
 * Type definitions for telnet-stream 1.0.5
 * Author: Voakie <contact@voakie.com>
 */

declare module "telnet-stream" {
  import { Socket, SocketConnectOpts, AddressInfo } from "net";
  import { Transform, TransformOptions } from "stream";

  export interface TelnetSocketOptions {
    bufferSize?: number;
    errorPolicy?: "keepBoth" | "keepData" | "discardBoth";
  }

  export interface TelnetInputOptions
    extends TransformOptions,
      TelnetSocketOptions {}

  /**
   * TelnetSocket is a decorator for a net.Socket object. Incoming TELNET commands, options, and negotiations are emitted as events. Non-TELNET data is passed through without changes.
   */
  export class TelnetSocket {
    constructor(socket: Socket, options?: TelnetSocketOptions);

    /**
     * When the remote system issues a TELNET command that is not option
     * negotiation, TelnetSocket will emit a 'command' event.
     *
     * ```js
     * var tSocket = new TelnetSocket(socket);
     * tSocket.on('command', function(command) {
     *   // Received: IAC <command> - See RFC 854
     * });
     * ```
     */
    on(name: "command", callback: (command: number) => void): void;
    /**
     * When the remote system wants to request that the local system
     * perform some function or obey some protocol, TelnetSocket will
     * emit a 'do' event:
     *
     * ```js
     * var tSocket = new TelnetSocket(socket);
     * tSocket.on('do', function(option) {
     *   // Received: IAC DO <option> - See RFC 854
     * });
     * ```
     */
    on(name: "do", callback: (option: number) => void): void;
    /**
     * When the remote system wants to request that the local system
     * NOT perform some function or NOT obey some protocol, TelnetSocket
     * will emit a 'dont' event:
     *
     * ```js
     * var tSocket = new TelnetSocket(socket);
     * tSocket.on('dont', function(option) {
     *   // Received: IAC DONT <option> - See RFC 854
     * });
     * ```
     */
    on(name: "dont", callback: (option: number) => void): void;
    /**
     * After negotiating an option, either the local or remote system
     * may engage in a more complex subnegotiation. For example, the
     * server and client may agree to use encryption, and then use
     * subnegotiation to agree on the parameters of that encryption.
     *
     * ```js
     * var tSocket = new TelnetSocket(socket);
     * tSocket.on('sub', function(option, buffer) {
     *   // Received: IAC SB <option> <buffer> IAC SE - See RFC 855
     * });
     * ```
     */
    on(name: "sub", callback: (option: number, buffer: Buffer) => void): void;
    /**
     * When the remote system wants to offer that it will perform some
     * function or obey some protocol for the local system, TelnetSocket
     * will emit a 'will' event:
     *
     * ```js
     * var tSocket = new TelnetSocket(socket);
     * tSocket.on('will', function(option) {
     *   // Received: IAC WILL <option> - See RFC 854
     * });
     * ```
     */
    on(name: "will", callback: (option: number) => void): void;
    /**
     * When the remote system wants to refuse to perform some function
     * or obey some protocol for the local system, TelnetSocket will
     * emit a 'wont' event:
     *
     * ```js
     * var tSocket = new TelnetSocket(socket);
     * tSocket.on('wont', function(option) {
     *   // Received: IAC WONT <option> - See RFC 854
     * });
     * ```
     */
    on(name: "wont", callback: (option: number) => void): void;
    /**
     * Call this method to send a TELNET command to the remote system.
     *
     * ```js
     * var NOP = 241; // No operation. -- See RFC 854
     * var tSocket = new TelnetSocket(socket);
     * // Sends: IAC NOP
     * tSocket.writeCommand(NOP);
     * ```
     *
     * @param command The command byte to send
     */
    writeCommand(command: number): void;
    /**
     * Call this method to send a TELNET DO option negotiation to the remote
     * system. A DO request is sent when the local system wants the remote
     * system to perform some function or obey some protocol.
     *
     * ```js
     * var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
     * var tSocket = new TelnetSocket(socket);
     * // Sends: IAC DO NAWS
     * tSocket.writeDo(NAWS);
     * ```
     *
     * @param option The option byte to request of the remote system
     */
    writeDo(option: number): void;
    /**
     * Call this method to send a TELNET DONT option negotiation to the remote
     * system. A DONT request is sent when the local system wants the remote
     * system to NOT perform some function or NOT obey some protocol.
     *
     * ```js
     * var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
     * var tSocket = new TelnetSocket(socket);
     * // Sends: IAC DONT NAWS
     * tSocket.writeDont(NAWS);
     * ```
     *
     * @param option The option byte to request of the remote system
     */
    writeDont(option: number): void;
    /**
     * Call this method to send a TELNET WILL option negotiation to the remote
     * system. A WILL offer is sent when the local system wants to inform the
     * remote system that it will perform some function or obey some protocol.
     *
     * ```js
     * var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
     * var tSocket = new TelnetSocket(socket);
     * // Sends: IAC WILL NAWS
     * tSocket.writeWill(NAWS);
     * ```
     *
     * @param option The option byte to offer to the remote system
     */
    writeWill(option: number): void;
    /**
     * Call this method to send a TELNET WONT option negotiation to the remote
     * system. A WONT refusal is sent when the remote system has requested that
     * the local system perform some function or obey some protocol, and the
     * local system is refusing to do so.
     *
     * ```js
     * var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
     * var tSocket = new TelnetSocket(socket);
     * // Sends: IAC WONT NAWS
     * tSocket.writeWont(NAWS);
     * ```
     *
     * @param option The option byte to refuse to the remote system
     */
    writeWont(option: number): void;
    /**
     * Call this method to send a TELNET subnegotiation to the remote system.
     * After the local and remote system have negotiated and agreed to use
     * an option, then subnegotiation information can be sent.
     *
     * See Example #2: Negotiate About Window Size (NAWS) in the README.
     *
     * @param option The option byte; identifies what the subnegotiation is about
     * @param buffer The buffer containing the subnegotiation data to send
     */
    writeSub(option: number, buffer: any): void;

    /** Inherited from `net` */
    on(name: "close", callback: (hadError: boolean) => void): void;
    /** Inherited from `net` */
    on(name: "connect", callback: () => void): void;
    /** Inherited from `net` */
    on(name: "data", callback: (data: Buffer | string) => void): void;
    /** Inherited from `net` */
    on(name: "drain", callback: () => void): void;
    /** Inherited from `net` */
    on(name: "end", callback: () => void): void;
    /** Inherited from `net` */
    on(name: "error", callback: (e: Error) => void): void;
    /** Inherited from `net` */
    on(name: "lookup", callback: () => void): void;
    /** Inherited from `net` */
    on(name: "timeout", callback: () => void): void;
    /** Inherited from `net` */
    address(): AddressInfo | string | null;
    /** Inherited from `net` */
    connect(opts: SocketConnectOpts, listener?: () => void): Socket;
    /** Inherited from `net` */
    connect(path: string, listener?: () => void): Socket;
    /** Inherited from `net` */
    connect(port: number, host?: string, listener?: () => void): Socket;
    /** Inherited from `net` */
    destroy(error?: Error): Socket;
    /** Inherited from `net` */
    end(data?: string, encoding?: string, callback?: () => void): Socket;
    /** Inherited from `net` */
    end(data?: Buffer | Uint8Array, callback?: () => void): Socket;
    /** Inherited from `net` */
    pause(): Socket;
    /** Inherited from `net` */
    ref(): Socket;
    /** Inherited from `net` */
    resume(): Socket;
    /** Inherited from `net` */
    setEncoding(encoding?: string): Socket;
    /** Inherited from `net` */
    setKeepAlive(enable?: boolean, initialDelay?: number): Socket;
    /** Inherited from `net` */
    setNoDelay(noDelay?: boolean): Socket;
    /** Inherited from `net` */
    setTimeout(timeout: number, callback: () => void): Socket;
    /** Inherited from `net` */
    unref(): Socket;
    /** Inherited from `net` */
    write(data: string, encoding?: string, callback?: () => void): boolean;
    /** Inherited from `net` */
    write(data: Buffer | Uint8Array, callback?: () => void): boolean;
  }

  export class TelnetInput extends Transform {
    constructor(options?: TelnetInputOptions);
  }

  export class TelnetOutput extends Transform {
    constructor(options?: TransformOptions);

    /**
     * Call this method to send a TELNET command to the remote system.
     *
     * ```js
     * var NOP = 241; // No operation. -- See RFC 854
     * var tSocket = new TelnetSocket(socket);
     * // Sends: IAC NOP
     * tSocket.writeCommand(NOP);
     * ```
     *
     * @param command The command byte to send
     */
    writeCommand(command: number): void;
    /**
     * Call this method to send a TELNET DO option negotiation to the remote
     * system. A DO request is sent when the local system wants the remote
     * system to perform some function or obey some protocol.
     *
     * ```js
     * var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
     * var tSocket = new TelnetSocket(socket);
     * // Sends: IAC DO NAWS
     * tSocket.writeDo(NAWS);
     * ```
     *
     * @param option The option byte to request of the remote system
     */
    writeDo(option: number): void;
    /**
     * Call this method to send a TELNET DONT option negotiation to the remote
     * system. A DONT request is sent when the local system wants the remote
     * system to NOT perform some function or NOT obey some protocol.
     *
     * ```js
     * var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
     * var tSocket = new TelnetSocket(socket);
     * // Sends: IAC DONT NAWS
     * tSocket.writeDont(NAWS);
     * ```
     *
     * @param option The option byte to request of the remote system
     */
    writeDont(option: number): void;
    /**
     * Call this method to send a TELNET WILL option negotiation to the remote
     * system. A WILL offer is sent when the local system wants to inform the
     * remote system that it will perform some function or obey some protocol.
     *
     * ```js
     * var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
     * var tSocket = new TelnetSocket(socket);
     * // Sends: IAC WILL NAWS
     * tSocket.writeWill(NAWS);
     * ```
     *
     * @param option The option byte to offer to the remote system
     */
    writeWill(option: number): void;
    /**
     * Call this method to send a TELNET WONT option negotiation to the remote
     * system. A WONT refusal is sent when the remote system has requested that
     * the local system perform some function or obey some protocol, and the
     * local system is refusing to do so.
     *
     * ```js
     * var NAWS = 31; // Negotiate About Window Size -- See RFC 1073
     * var tSocket = new TelnetSocket(socket);
     * // Sends: IAC WONT NAWS
     * tSocket.writeWont(NAWS);
     * ```
     *
     * @param option The option byte to refuse to the remote system
     */
    writeWont(option: number): void;
    /**
     * Call this method to send a TELNET subnegotiation to the remote system.
     * After the local and remote system have negotiated and agreed to use
     * an option, then subnegotiation information can be sent.
     *
     * See Example #2: Negotiate About Window Size (NAWS) in the README.
     *
     * @param option The option byte; identifies what the subnegotiation is about
     * @param buffer The buffer containing the subnegotiation data to send
     */
    writeSub(option: number, buffer: any): void;
  }
}
