module mysdl.system;

import mysdl.sdlapi;
import mysdl.gfx;

import std.string;
import std.conv : to;
import std.exception: enforce;
 
debug import std.stdio;

/* -------Utilities------- */

/** Exception class for failures of SDL*/
public class SDLException : Exception {
    /* dummy-subclass */
    public this(string msg) {
        super(msg);
    }
    
    public this() {
        this( to!string(SDL_GetError()) );
    }
}

/**
 Initialize all SDL-Subsystems
 
 throws: SDLException on failure
 */
public void initSDL() {
    initSDL(SDL_INIT_EVERYTHING);
}

/**
 Init Audio and Video
 
 throws: SDLException on failure
 */
public void initAudioVideo() {
    initSDL(SDL_INIT_AUDIO | SDL_INIT_VIDEO);
}

public Surface SetVideoMode(int width, int height, int bitspp, Uint32 flags) {
    return Surface(
    //TODO better exception
        enforce(SDL_SetVideoMode(width, height, bitspp, flags)),
    //It's a Display
        true );
}

/**
 Initialize SDL using the bitflags
 
 throws: SDLException on failure
 
 see_also: Subsystem
 */
public void initSDL(Uint32 code) {
    debug writefln("init(%s)",code);
    if(SDL_Init(code) == -1) {
        debug writefln("Initiliziation failed :-(");
        //TODO put sdl_GetError here
        throw new SDLException("Initialization failed");
    } else {
        debug writefln("Initialized");
        //Uninit.sdlInitialized();
        //debug writefln("Registred");
    }
}


shared static ~this() {
    if( /*activated && */ SDL_WasInit(SDL_INIT_EVERYTHING) ) {
        SDL_Quit();
        debug writeln("\nSDL_Quit()");
    } else debug writeln("\nSDL already shut down.");
}

/* -------Subsystem------- */
/**
 Instances of this struct represents the several SDL subsystems
 
 NOT FINISHED
 */
public struct Subsystem {
    immutable uint bitflag;

    package this(immutable uint bitflag){
        this.bitflag = bitflag;
    }
    
    @property
    public bool activated() {
        return SDL_WasInit(bitflag) != 0;
    }
}