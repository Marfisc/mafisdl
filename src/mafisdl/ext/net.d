module mafisdl.ext.net;

import std.conv, std.string, std.exception;
debug import std.stdio;

import derelict.sdl2.net;

import mafisdl.system;

void initNet() {
    if(!DerelictSDL2Net.isLoaded) {
        DerelictSDL2Net.load();
    }
    if(SDLNet_Init() != 0) throw new SDLNetException;
}

void quitNet() {
    SDLNet_Quit();
}

class SDLNetException : SDLException {
    this(string s) {
        super(s);
    }

    this() {
        super(to!string(SDLNet_GetError()));
    }
}

alias IPaddress IPAddress;

IPAddress resolve(string host, ushort port = 0) {
    IPAddress result;
    SDLNet_ResolveHost(&result, toStringz(host), port);
    return result;
}

IPAddress server(ushort port) {
    IPAddress result;
    SDLNet_ResolveHost(&result, null, port);
    return result;
}

struct TCPSocket {
    TCPsocket soc;

    this(TCPsocket tcps) {
        soc = tcps;
    }

    static typeof(this) open(IPAddress adr) {
        //return typeof(this)(enforce(SDLNet_TCP_Open(cast(IPAddress)&adr), new SDLNetException));
        return typeof(this)(enforce(SDLNet_TCP_Open(&adr), new SDLNetException));
    }

    typeof(this) accept() {
        return typeof(this)(SDLNet_TCP_Accept(soc));
    }

    void rawSend(in ubyte[] data) {
        int len = SDLNet_TCP_Send(soc, data.ptr, cast(int) data.length);
        if(len < data.length) throw new SDLNetException;
    }

    ubyte[] rawRecieve(ubyte[] buffer = null) {
        if(buffer is null) {
            buffer = new ubyte[](512);
        }
        int len = SDLNet_TCP_Recv(soc, buffer.ptr, cast(int) buffer.length);
        if(len == -1) throw new SDLException;
        return buffer[0.. len];
    }

    void close() {
        if(soc !is null) SDLNet_TCP_Close(soc);
        soc = null;
    }

}
