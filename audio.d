module mysdl.audio;

import mysdl.sdlapi;
import mysdl.system;

import std.string;
import std.c.stdlib, std.c.string;
import std.algorithm: min;
debug import std.stdio;

/** 
An AudioSpec defines how exactly an audio stream is laid out in memory.

Alias of SDL_AudioSpec so look for it to get information about the fields.
*/
alias SDL_AudioSpec AudioSpec;

/**
Set this before you use startAudio. 

Changing it later is undefined behauvior.
*/
__gshared AudioSpec globalAudioSpec;

static this() {
    debug writeln("Initing globalAudioSpec");
    globalAudioSpec.freq = 22050;
    globalAudioSpec.format = AUDIO_U8;
    globalAudioSpec.channels = 2;
    globalAudioSpec.samples = 2048;
    globalAudioSpec.callback = &mixAudio;
    globalAudioSpec.userdata = null;
}

/**
Start playing audio.
*/
void startAudio() {
    debug writeln("Starting audio");
    SDL_OpenAudio(&globalAudioSpec, null);
    SDL_PauseAudio(0); //make the music actually play
}

/**
Stop using audio.
*/
void stopAudio() {
    SDL_CloseAudio();
}

/**
This struct represents a sound.

Load with Sound.load or use the constructor with an ubyte[] or RWops.
*/
struct Sound {
    ubyte[] data;
    AudioSpec spec;
    
    /**
    Load Sound from file specified with path.
    
    Only supports WAV format.
    
    Throws: SDLException on failure.
    */
    static typeof(this) loadWAV(string path) {
        Sound s;
        ubyte* dataPtr;
        uint  dataLen;
        if(SDL_LoadWAV(toStringz(path), &s.spec, &dataPtr, &dataLen) == null) {
            throw new SDLException;
        }
        s.data = dataPtr[0.. dataLen];
        return s;
    }
    
    /**
    Create a sound out of the data of the RWops given.
    
    Only supports WAV format.
    
    Throws: SDLException on failure.
    */
    this(SDL_RWops* r) {
        ubyte* dataPtr;
        uint  dataLen;
        if(SDL_LoadWAV_RW(r, 0, &this.spec, &dataPtr, &dataLen) == null) {
            throw new SDLException;
        }
        this.data = dataPtr[0.. dataLen];        
    }
    
    /**
    Create the sound of data pointed to by rawBytes. 
    
    Only supports WAV format.
    
    Throws: SDLException on failure.
    */
    this(ubyte[] rawBytes) {
        this(SDL_RWFromMem(rawBytes.ptr, rawBytes.length));
    }
    
    /**
    Convert the sound to newSpec. Use this struct to point to the new
    converted sound.
    
    Params:
    newSpec=   The spec you want to convert the sound to.
    freeOld=   If you want to free the old. Standard is true.
    */
    void convert(AudioSpec newSpec, bool freeOld = true) {
        SDL_AudioCVT cvt;
        SDL_BuildAudioCVT(&cvt, spec.format,    spec.channels,    spec.freq,
                           newSpec.format, newSpec.channels, newSpec.freq);
        auto newLength = data.length * cvt.len_mult;
        cvt.buf = cast(ubyte*) malloc(newLength);
        cvt.len = data.length;
        memcpy(cvt.buf, data.ptr, data.length);
        SDL_ConvertAudio(&cvt);
        if(freeOld) SDL_FreeWAV(data.ptr);
        spec = newSpec;
        data = cvt.buf[0.. cvt.len_cvt];
    }
    
    /**
    Play the sound.
    
    Assumes you use the standard audio mixer. Otherwise nothing should
    happen.
    */
    bool play() {
        //if this sound has the wrong spec create a copy
        //convert it and play it
        debug writeln("Trying to play sound");
        if(spec != globalAudioSpec) {
            Sound s = this;
            s.convert(globalAudioSpec, false);
            return s.play();
        }
        
        //the index of the slot to put the sound in
        int index;
        //if any slot was found
        bool found = false;
        //search for sound slot
        foreach(i, s; playedSounds) {
            debug writefln("Slot #%s", i);
            if(s.data.length == 0) {
                debug writeln("Slot is empty");
                found = true;
                index = i;
                break;
            }
        }
        
        if(!found) return false;
        
        debug writeln("A slot was found");
        
        SDL_LockAudio();
        scope(exit) SDL_UnlockAudio();
        playedSounds[index].data = this.data;
        
        return true;
    }
}

private struct PlayedSound {
    ubyte[] data;
    
    string toString() {
        return format("Sound of %s bytes: %s", 
            data.length, data); 
    }
}
private __gshared PlayedSound[3] playedSounds;

extern(C) private void mixAudio(void* unused, ubyte* stream, int maxLength) {
    //debug writefln("mixing: Stream: %s     maxLength: %s", stream, maxLength);
    foreach(ref ps; playedSounds) {
        auto toPlay = min(ps.data.length, maxLength);
        if(toPlay == 0) continue;
        debug writefln("Playing %s bytes", toPlay);
        SDL_MixAudio(stream, ps.data.ptr, toPlay, SDL_MIX_MAXVOLUME);
        ps.data = ps.data[toPlay .. $];
    }
}
