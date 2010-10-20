module mysdl.gfx;

import std.exception: enforce;
import std.string: toStringz;
//import std.stdio: IOException;
import mysdl.sdlapi;

public struct Surface {
    private:
    SDL_Surface* surptr = null;
    bool isDisplay = false;

    public:
    
    this(SDL_Surface* ptr, bool disp = false) {
        enum msg = "null SDL_Surface pointer in "~typeof(this).stringof;
        this.surptr = enforce(ptr, msg);
        this.isDisplay = disp;
    }
    
    @property
    SDL_Surface* ptr() nothrow {
        return this.surptr;
    }
    
    void blitTo(Surface dst) const {
        SDL_BlitSurface(this.surptr, null, dst.surptr, null);
    }
    
    void blitTo(Surface dst, Rect r, short x, short y) const {
        Rect dstrect = createRect(x, y, r.w, r.h);
        SDL_BlitSurface(this.surptr, &r, dst.surptr, &dstrect );
    }
    
    void blitFrom(const Surface src) {
        src.blitTo(this);
    }
    
    void blitFrom(const Surface src, Rect r, short x, short y) {
        src.blitTo(this, r, x, y);
    }    
    
    void update() 
    in { assert(this.isDisplay); }
    body {
        SDL_UpdateRect(this.surptr, 0, 0, 0, 0);
    }
    
    void update(Rect r)
    in { assert(this.isDisplay); }
    body {
        SDL_UpdateRect(this.surptr, r.x, r.y, r.w, r.h);
    }
    
    void update(short x, short y, ushort width, ushort height)
    in { assert(this.isDisplay); }
    body {
        SDL_UpdateRect(this.surptr, x, y, width, height);
    }
    
    
    void free() {
        SDL_FreeSurface(this.surptr);
    }
    
    static Surface loadBMP(string filename) {
        //TODO find some better exception type
        return Surface( enforce(
            SDL_LoadBMP(toStringz(filename)), new Exception("Failed to load Bitmap")
        ));
    }   
}

public Surface SetVideoMode(int width, int height, int bitspp, Uint32 flags) {
    return Surface(
    //TODO better exception
        enforce(SDL_SetVideoMode(width, height, bitspp, flags)),
    //It's a Display
        true );
}

alias SDL_Rect Rect;

Rect createRect(short x, short y, ushort width, ushort height)
//in { assert(data[2] > 0); assert(data[3] > 0); }
body {
    SDL_Rect r;
    r.x = x;
    r.x = y;
    r.w = width;
    r.h = height;
    return r;
}