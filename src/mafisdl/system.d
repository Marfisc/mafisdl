module mafisdl.system;

//public import mafisdl.sdlapi;
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

alias Window = SDL_Window*;

Window createWindow(string name, int x, int y, int width, int height, uint flags = 0) {
    return SDL_CreateWindow(toStringz(name), x, y, width, height, flags);
}

Window createCenteredWindow(string name, int width, int height, uint flags = 0) {
    return createWindow(name, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        width, height, flags);
}

void delay(long ms)
in {
    assert(ms > 0);
} body {
    SDL_Delay(cast(uint) ms);
}

alias SDL_GetTicks getTicks;


/*shared*/ static ~this() {
    if( /*activated && */ SDL_WasInit(SDL_INIT_EVERYTHING) ) {
        SDL_Quit();
        debug writeln("\nSDL_Quit()");
    } else debug writeln("\nSDL already shut down.");
}

version(unittest) static this() {
    initSDL();
}
