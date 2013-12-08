module mafisdl.system;

public import mafisdl.sdlapi;
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
 Initialize Audio and Video

 throws: SDLException on failure
 */
void initAudioVideo() {
    initSDL(SDL_INIT_AUDIO | SDL_INIT_VIDEO);
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

/* -------Subsystem------- */
/**
 Instances of this struct represent the several SDL subsystems.

 NOT FINISHED
 */
struct Subsystem {
    immutable uint bitflag;

    /**
     These represent a Subsystem.

     Use for example the activated property to check if a Subsystem is activated.
     ----
     if(Subsystem.audio.activated) { }
     ----
     */
    static immutable(Subsystem) audio = Subsystem(SDL_INIT_AUDIO);
    static immutable(Subsystem) video = Subsystem(SDL_INIT_VIDEO); ///ditto
    static immutable(Subsystem) timer = Subsystem(SDL_INIT_TIMER); ///ditto
    static immutable(Subsystem) joystick = Subsystem(SDL_INIT_JOYSTICK); ///ditto

    package this(immutable uint bitflag){
        this.bitflag = bitflag;
    }

    /** Is this Subsystem activated? */
    @property
    bool activated() const {
        return SDL_WasInit(bitflag) != 0;
    }

    /**
     Activate this Subsystem.

     throws: SDLException on failure
     */
    void activate() const {
        if(SDL_InitSubSystem(bitflag) == -1) {
            throw new SDLException;
        }
    }
}

version(unittest) static this() {
    initSDL();
}
