module mafisdl.system;

public import derelict.sdl2.sdl;
import mafisdl.video;

import std.string;
import std.conv : to;
import std.exception: enforce;

debug import std.stdio;

/* -------Utilities------- */

/** Exception class for failures of SDL*/
class SDLException : Exception {
    this(string msg) {
        super(msg);
    }

    this() {
        this( to!string(SDL_GetError()) );
    }
}

/**
A enforce-like function which ensures the return value is not -1.

throws: SDLException
*/
T sdlEnforce(T)(T t) if(is(typeof( { T t; return t == -1;} ))) {
    if(t == -1) {
        throw new SDLException;
    }
    return t;
}


/**
Initialize all SDL-Subsystems

throws: SDLException on failure
*/
void initSDL() {
    initSDL(SDL_INIT_EVERYTHING);
}

/**
Initialize SDL using the bitflags

throws: SDLException on failure

see_also: Subsystem
*/
void initSDL(Uint32 code) {
    debug writefln("init(%s)",code);

    if(!DerelictSDL2.isLoaded) {
        DerelictSDL2.load();
    }

    if(SDL_Init(code) == -1) {
        debug writefln("Initiliziation failed");
        throw new SDLException("Initialization failed");
    } else {
        debug writefln("Initialized");
        //Uninit.sdlInitialized();
        //debug writefln("Registred");
    }
}

/**
The SDL reference type used to represent a window of the
host gui environment.

It is a SDL_Window*
*/
alias Window = SDL_Window*;

/**
Create a new window with the given name, coordinates (or centered on the srceen), size and flags.
For flags, visit SDL documentation for SDL_CreateWindow.
*/
Window createWindow(string name, int x, int y, int width, int height, uint flags = 0) {
    return SDL_CreateWindow(toStringz(name), x, y, width, height, flags);
}

/** ditto */
Window createCenteredWindow(string name, int width, int height, uint flags = 0) {
    return createWindow(name, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        width, height, flags);
}

/**
Delay the execution of the program by (at least) the given milliseconds.
*/
void delay(long ms)
in {
    assert(ms > 0);
} body {
    SDL_Delay(cast(uint) ms);
}

/**
Get the number of already passed ticks (ms).
*/
alias SDL_GetTicks getTicks;

version(unittest) static this() {
    initSDL();
}
