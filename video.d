module mysdl.video;

import std.algorithm: min, max;
import std.exception: enforce;
import std.string: toStringz;
import std.math: floor;
//import std.stdio: IOException;

import mysdl.sdlapi;
import mysdl.system: SDLException;

struct Surface {
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
    
    this(SDL_RWops* r) {
        this.surptr = SDL_LoadBMP_RW(r, 0);
    }
    
    this(ubyte[] rawBytes) {
        this(SDL_RWFromMem(rawBytes.ptr, rawBytes.length));
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
    Rect whole() const {
        return Rect(0, 0, cast(ushort) width, cast(ushort) height);
    }
    
    /* -----Painting---------- */
    
    void blit(Surface dst, Rect r, short x, short y) {
        Rect dstrect = Rect(x, y, r.width, r.height);
        SDL_BlitSurface(this.surptr, &r.r, dst.surptr, &dstrect.r );
    }
    
    void blitTo(Surface dst, short x, short y) {
        Rect dstrect = Rect(x, y, 0, 0); //cast(ushort)this.width, cast(ushort)this.height
        //Rect srcrect = createRect(0, 0, cast(ushort)this.width, cast(ushort)this.height);
        SDL_BlitSurface(this.surptr, null, dst.surptr, &dstrect.r);
    }
    
    deprecated void blitTo(Surface dst) {
        SDL_BlitSurface(this.surptr, null, dst.surptr, null);
    }
    
    void fillRect(Rect r, ubyte[3] color ...) {
        SDL_FillRect(this.surptr, &r.r, 
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
        SDL_UpdateRect(this.surptr, r.x, r.y, r.width, r.height);
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
    
    Clip clip()(Rect r) {
        return Clip(this, r);
    }
    
    Clip clip(T...)(T t) if(is(typeof(rect(t) = Rect))) {
        return Clip(this, rect(t));
    }
    
    Clip clip()() {
        return Clip(this, whole);
    }
    
    static Surface loadBMP(string filename) {
        return Surface( enforce(
            SDL_LoadBMP(toStringz(filename)), new SDLException("Failed to load Bitmap")
        ));
    }

    /* ------ Utility -------- */
    
    void check(T)(T t) if(is(typeof( { T t; return t == -1;} ))) {
        if(t == -1) {
            throw new SDLException;
        }
    }
}



alias SDL_SWSURFACE     SWSURFACE;
alias SDL_HWSURFACE     HWSURFACE;
alias SDL_ASYNCBLIT     ASYNCBLIT;
alias SDL_ANYFORMAT     ANYFORMAT;
alias SDL_HWPALETTE     HWPALETTE;
alias SDL_DOUBLEBUF     DOUBLEBUF;
alias SDL_FULLSCREEN    FULLSCREEN;
alias SDL_OPENGL        OPENGL;
alias SDL_OPENGLBLIT    OPENGLBLIT;
alias SDL_RESIZABLE     RESIZABLE;
alias SDL_NOFRAME       NOFRAME;
alias SDL_HWACCEL       HWACCEL;
alias SDL_SRCCOLORKEY   SRCCOLORKEY;
alias SDL_RLEACCELOK    RLEACCELOK;
alias SDL_RLEACCEL      RLEACCEL;
alias SDL_SRCALPHA      SRCALPHA;
alias SDL_PREALLOC      PREALLOC;



Surface setVideoMode(int width, int height, int bitspp, Uint32 flags) {
    return Surface(
    //TODO better exception
        enforce(SDL_SetVideoMode(width, height, bitspp, flags)),
    //It's a Display
        true );
}

struct Rect {
    this(short x, short y, short w, short h) {
        r = SDL_Rect(x, y, w, h);
    }
    
    this(int[4] d...) {
        this(cast(short)d[0], cast(short)d[1], cast(short)d[2], cast(short)d[3]);
    }
    
    @property short x() { return r.x; }
    @property short y() { return r.y; }
    @property short width() { return r.w; }
    @property short height() { return r.h; }
    
    
    SDL_Rect r;
}

Rect maximalBounds(Rect r, short w, short h) {
    return Rect(r.x, r.y, min(r.width, w), min(r.height, h));
}

Rect smaller(Rect r, short sw, short sh) {
    return Rect(r.x, r.y, max(r.width - sw, 0), max(r.height - sh, 0));
}

struct Clip {
    Surface sur;
    Rect rect;
    
    @property int width() { return rect.width; }
    @property int height() { return rect.height; }
    
    void blitTo(Surface dst, short x, short y) {
        sur.blit(dst, rect, x, y);
    }
    
    void blitTo(Clip dst, short x, short y) {
        sur.blit(dst.sur,
            smaller(maximalBounds(rect, dst.rect.width, dst.rect.height), x, y),
            x, y);
    }
}

struct Clipper {
    Surface src;
    int width, height;
    private immutable int clipsPerLine;
    
    this(Surface s, int w, int h) {
        src = s;
        width = w;
        height = h;
        clipsPerLine = cast(int) floor((0.0 + src.width) / width);        
    }
    
    @property
    int count() {
        int clipsPerLine = cast(int) floor((0.0 + src.width) / width);
        int clipsPerColumn = cast(int) floor((0.0 + src.height) / height);
        return clipsPerLine * clipsPerColumn;
    }
    
    int opDollar(){
        return count;
    }
    
    Clip opIndex(int index) {
        int x = index % clipsPerLine;
        int y = (index - x) / clipsPerLine;
        auto r = Rect(x * width, y * height, width, height);
        return Clip(src, r);
    }
    
    Clip[] opSlice() {
        return opSlice(0, opDollar());
    }
    
    Clip[] opSlice(int st, int end) {
        Clip[] list;
        foreach(i; st .. end) {
            list ~= opIndex(i);
        }
        return list;
    }
    
    
}
