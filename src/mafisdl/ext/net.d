module mafisdl.ext.net;

import std.conv, std.string, std.exception;
debug import std.stdio;

import derelict.sdl2.net;

import mafisdl.system;

/**
Init the SDL net extension.

Loads the library through Derelict if necessary.
*/
void initNet() {
    if(!DerelictSDL2Net.isLoaded) {
        DerelictSDL2Net.load();
    }
    if(SDLNet_Init() != 0) throw new SDLNetException;
}

/**
Quit the SDL net extension.
*/
void quitNet() {
    SDLNet_Quit();
}

/**
An exception thrown for problems specific to SDL net
extension.
*/
class SDLNetException : SDLException {
    this(string s) {
        super(s);
    }

    this() {
        super(to!string(SDLNet_GetError()));
    }
}

///An IP address (includes port)
alias IPaddress IPAddress;

///Resolve the address for host and return its IPAddress
IPAddress resolve(string host, ushort port = 0) {
    IPAddress result;
    SDLNet_ResolveHost(&result, toStringz(host), port);
    return result;
}

/**
Creates the IPAddress needed to create a server socket
that listens to port.
*/

IPAddress server(ushort port) {
    IPAddress result;
    SDLNet_ResolveHost(&result, null, port);
    return result;
}

/**
A wrapper around a raw SDL_Net TCPsocket
*/
struct TCPSocket {
    ///the raw socket type
    TCPsocket soc;

    this(TCPsocket tcps) {
        soc = tcps;
    }

    /**
    Open a connection to the given IPAddress (and port)

    throws: SDLNetException on failure
    */
    static typeof(this) open(IPAddress adr) {
        //return typeof(this)(enforce(SDLNet_TCP_Open(cast(IPAddress)&adr), new SDLNetException));
        return typeof(this)(enforce(SDLNet_TCP_Open(&adr), new SDLNetException));
    }

    ///Accept incoming connections through this server socket
    typeof(this) accept() {
        return typeof(this)(SDLNet_TCP_Accept(soc));
    }

    /**
    Send the given raw data directly through the socket.

    throws: SDLNetException on failure
    */
    void rawSend(in ubyte[] data) {
        int len = SDLNet_TCP_Send(soc, data.ptr, cast(int) data.length);
        if(len < data.length) throw new SDLNetException;
    }

    /**
    Receive some amount of raw data through the socket and fill the buffer.
    The buffer might not necessarily be completely filled
    and it might be left completely untouched if there is currently no
    data to receive. When given null allocates a new buffer (using the GC).

    returns: the slice of the buffer that was filled with incoming data

    throws: SDLNetException on failure
    */
    ubyte[] rawReceive(ubyte[] buffer = null) {
        if(buffer is null) {
            buffer = new ubyte[](512);
        }
        int len = SDLNet_TCP_Recv(soc, buffer.ptr, cast(int) buffer.length);
        if(len == -1) throw new SDLException;
        return buffer[0.. len];
    }

    ///Close the socket
    void close() {
        if(soc !is null) SDLNet_TCP_Close(soc);
        soc = null;
    }

}
