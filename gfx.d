module mysdl.gfx;

import std.exception: enforce;
import std.string: toStringz;
//import std.stdio: IOException;
import mysdl.sdlapi;
import mysdl.system: SDLException;

public struct Surface {
    private:
    SDL_Surface* surptr = null;
    bool isDisplay = false;

    public:
    
    /* ----- Access ------- */
    
    this(SDL_Surface* ptr, bool disp = false) {
        enum msg = "null SDL_Surface pointer in "~typeof(this).stringof;
        this.surptr = enforce(ptr, msg);
        this.isDisplay = disp;
    }
    
    @property
    SDL_Surface* ptr() nothrow {
        return this.surptr;
    }
    
    @property
    int width() const { return this.surptr.w; }
    
    @property
    int height() const { return this.surptr.h; }
    
    @property
    Rect rect() const {
        return createRect(0, 0, cast(ushort) width, cast(ushort) height);
    }
    
    /* -----Painting---------- */
    
    void blitTo(Surface dst) const {
        SDL_BlitSurface(this.surptr, null, dst.surptr, null);
    }
    
    void blitTo(Surface dst, Rect r, short x, short y) const {
        Rect dstrect = createRect(x, y, r.w, r.h);
        SDL_BlitSurface(this.surptr, &r, dst.surptr, &dstrect );
    }
    
    void blitTo(Surface dst, short x, short y) const {
        Rect dstrect = createRect(x, y, 0, 0); //cast(ushort)this.width, cast(ushort)this.height
        //Rect srcrect = createRect(0, 0, cast(ushort)this.width, cast(ushort)this.height);
        SDL_BlitSurface(this.surptr, null, dst.surptr, &dstrect);
    }
    
    void blitFrom(const Surface src) {
        src.blitTo(this);
    }
    
    void blitFrom(const Surface src, Rect r, short x, short y) {
        src.blitTo(this, r, x, y);
    } 

    void fillRect(Rect r, ubyte[3] color ...) {
        SDL_FillRect(this.surptr, &r, 
            this.mapRGB(color[0], color[1], color[2]));
    }
    
    void setColorKey(ubyte[3] color ...) {
        check(SDL_SetColorKey(this.surptr, SDL_SRCCOLORKEY,
           this.mapRGB(color)));
    }
    
    /* ------- Meta ------ */
    
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
    
    void flip() 
    in { assert(this.isDisplay); }
    body {
        check(SDL_Flip(this.surptr));
    }
    
    uint mapRGB(ubyte[3] color ...) const {
        return SDL_MapRGB(this.surptr.format, color[0], color[1], color[2]);
    }
    
    void optimize(bool freeold = true) {
        SDL_Surface* opt = SDL_DisplayFormat(this.surptr);
        if(opt == null) {
            throw new SDLException;
        }
        if(freeold) free();
        this.surptr = opt;
        
    }
    
    void free() 
    /* The surface returned by SetVideoMode is 
       freed by SDL. */
    in { assert(!this.isDisplay); } 
    body {
        SDL_FreeSurface(this.surptr);
    }
    
    static Surface loadBMP(string filename) {
        //TODO find some better exception type
        return Surface( enforce(
            SDL_LoadBMP(toStringz(filename)), new Exception("Failed to load Bitmap")
        ));
    }

    /* ------ Utility -------- */
    
    void check(T)(T t) if(is(typeof( { T t; return t == -1;} ))) {
        if(t == -1) {
            throw new SDLException;
        }
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
    r.y = y;
    r.w = width;
    r.h = height;
    return r;
}