module mysdl.audio;

import mysdl.sdlapi;
import mysdl.system;

import std.string;
import std.c.stdlib, std.c.string;
import std.algorithm: min;
debug import std.stdio;

alias SDL_AudioSpec AudioSpec;

public __gshared AudioSpec globalAudioSpec;

static this() {
    debug writeln("Initing globalAudioSpec");
    globalAudioSpec.freq = 22050;
    globalAudioSpec.format = AUDIO_U8;
    globalAudioSpec.channels = 2;
    globalAudioSpec.samples = 2048;
    globalAudioSpec.callback = &mixAudio;
    globalAudioSpec.userdata = null;
}

void startAudio() {
    debug writeln("Starting audio");
    SDL_OpenAudio(&globalAudioSpec, null);
    SDL_PauseAudio(0); //make the music actually play
}

void stopAudio() {
    SDL_CloseAudio();
}


struct Sound {
    ubyte[] data;
    AudioSpec spec;
    
    static typeof(this) load(string path) {
        Sound s;
        ubyte* dataPtr;
        uint  dataLen;
        if(SDL_LoadWAV(toStringz(path), &s.spec, &dataPtr, &dataLen) == null) {
            throw new SDLException;
        }
        s.data = dataPtr[0.. dataLen];
        return s;
    }
    
    this(SDL_RWops* r) {
        ubyte* dataPtr;
        uint  dataLen;
        if(SDL_LoadWAV_RW(r, 0, &this.spec, &dataPtr, &dataLen) == null) {
            throw new SDLException;
        }
        this.data = dataPtr[0.. dataLen];        
    }
    
    this(ubyte[] rawBytes) {
        this(SDL_RWFromMem(rawBytes.ptr, rawBytes.length));
    }
    
    void convert(AudioSpec newSpec) {
        SDL_AudioCVT cvt;
        SDL_BuildAudioCVT(&cvt, spec.format,    spec.channels,    spec.freq,
                           newSpec.format, newSpec.channels, newSpec.freq);
        auto newLength = data.length * cvt.len_mult;
        cvt.buf = cast(ubyte*) malloc(newLength);
        cvt.len = data.length;
        memcpy(cvt.buf, data.ptr, data.length);
        SDL_ConvertAudio(&cvt);
        SDL_FreeWAV(data.ptr);
        spec = newSpec;
        data = cvt.buf[0.. cvt.len_cvt];
    }
    
    bool play() {
        //if this sound has the wrong spec create a copy
        //convert it and play it
        debug writeln("Trying to play sound");
        if(spec != globalAudioSpec) {
            Sound s = this;
            s.convert(globalAudioSpec);
            return s.play();
        }
        
        //the index of the slot to put the sound in
        int index;
        //if any slot was found
        bool found = false;
        //search for sound slot
        foreach(i, s; playedSounds) {
            debug writefln("Slot #%s", i);
            if(s.data.length >= 0) {
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

struct PlayedSound {
    ubyte[] data;
    
    public string toString() {
        return format("Sound of %s bytes: %s", 
            data.length, data); 
    }
}
__gshared PlayedSound[3] playedSounds;

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
