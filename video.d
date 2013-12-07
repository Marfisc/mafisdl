module mysdl.video;

import std.algorithm: min, max;
import std.exception: enforce;
import std.string: toStringz, format;
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
        this(SDL_RWFromMem(rawBytes.ptr, cast(int)rawBytes.length));
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
        return Rect(0, 0, cast(ushort) width, cast(ushort) height);
    }
    
    @property
    Clip whole() {
        return Clip(this, rect);
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
    
    Clip clip(T...)(T t) if(is(typeof(Rect(t)) == Rect)) {
        return Clip(this, Rect(t));
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



/**
Like SDL_SetVideoMode. Creates the main window of size
width*height and colordepth bitspp.

Use flags to control the behauvior of the game window.
The flags are named exactly like in SDL but without the
SDL_-prefix.

returns: the Surface that represents drawable area of the
window.
*/
Surface setVideoMode(int width, int height, int bitspp, Uint32 flags) {
    return Surface(
    //TODO better exception
        enforce(SDL_SetVideoMode(width, height, bitspp, flags)),
    //It's a Display
        true );
}

/**
This structure represents rectengular area with x, y, width
and heights.
*/
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

    @property int right() { return r.x + r.w - 1; }
    @property int bottom() { return r.y + r.h - 1; }

    bool contains(int tx, int ty) {
        return tx >= x && tx <= right && ty >= y && ty <= bottom;
    }
    
    string toString() {
        return format("Rect(%s,%s, %s,%s)", x, y, width, height);
    }
    
    SDL_Rect r;
}

Rect maximalBounds(Rect r, short w, short h) {
    return Rect(r.x, r.y, min(r.width, w), min(r.height, h));
}

Rect smaller(Rect r, short sw, short sh) {
    return Rect(r.x, r.y, max(r.width - sw, 0), max(r.height - sh, 0));
}

/**
The parameters are a (probably bigger) rect called major and a second
rect called minor. Minor's origin is major upper left corner so minor
is relative to major.
This function returns the overlap of these rect as a rect which is
relative to major.
*/
Rect subrect(Rect major, Rect minor) {
    return Rect(max(0, minor.x), max(0, minor.y),
        min(minor.width, major.width  - minor.x),
        min(minor.height, major.height - minor.y));
}

unittest {
    //import std.stdio;
    //writeln(subrect(Rect(12,8, 6,7), Rect(1,2, 18,3)));
    assert(subrect(Rect(12,8, 6,7), Rect(1,2, 18,3)) == Rect(1,2, 5,3));
}

/**
Returns a rect with absolute coordinates out of a relative rect.

params: origin= the rect to whose upper left corner the other
                 is relative to.
        relative= the relative rect.
*/
Rect absolute(Rect origin, Rect relative) {
    return Rect(origin.x + relative.x, origin.y+ relative.y,
        relative.width, relative.height);
}

Rect relative(Rect origin, Rect absolute) {
    return Rect(absolute.x - origin.x, absolute.y - origin.y,
        absolute.width, absolute.height);
}

/**
Like subrect but returns a rect with absolute coordinates.
*/
Rect absoluteSubrect(Rect major, Rect minor) {
    return absolute(major, subrect(major, minor));
}

/**
The rect that conatins only and all of the points that are in both
a and b.
*/
Rect overlap(Rect a, Rect b) {
    return absoluteSubrect(a, relative(a, b));
}

/**
Returns true iff the rects collide, ie share some points.
*/
bool collide(Rect r1, Rect r2) {
    if(r1.x + r1.width -1 < r2.x) return false;
    if(r2.x + r2.width -1 < r1.x) return false;
    if(r1.y + r1.height -1 < r2.y) return false;
    if(r2.y + r2.height -1 < r1.y) return false;
    return true;
}

/**
This structure represents a part of a Surface. Many operations that work 
on Surfaces also work on Clips.

The standard way to create a Clip is Surface's clip function or whole-
property.

When some operation needs a Clip but you want to give it a whole Surface
just use the Surface's whole property.
*/
struct Clip {
    Surface sur;
    Rect rect;
    
    /**
    The width and height of this Clip.
    */
    @property int width() { return rect.width; }
    @property int height() { return rect.height; } ///ditto

    /**
    Get a subclip of this one using relative coordinates.
    */
    Clip clip()(Rect r) {
        return Clip(sur, absoluteSubrect(rect, r));
    }

    ///ditto
    Clip clip(T...)(T t) if(is(typeof(Rect(t)) == Rect)) {
        return clip(Rect(t));
    }
    
    /**
    Blit this clip onto a Surface or another clip.
    */
    void blitTo(Surface dst, short x, short y) {
        sur.blit(dst, rect, x, y);
    }

    ///ditto
    void blitTo(Clip dst, short x, short y) {
        sur.blit(dst.sur,
            maximalBounds(rect, cast(short)(dst.rect.width - x), cast(short)(dst.rect.height - y)),
            x, y);
    }
    
    /**
    Fill the whole clip with one color.
    -----
    Surface display;
    ...
    //Fill the whole display black.
    display.whole.fill(0, 0, 0);
    -----
    */
    void fill(ubyte[3] color...) {
        sur.fillRect(rect, color);
    }
}

/**
This struct generates clips in a tileset like manner.

Use opIndex() to get the n-th Clip or opSlice() to get
the whole Clip[].
*/
struct Clipper {
    Surface src;
    int width, height;
    private int clipsPerLine;
    
    /**
    Construct a clipper that generates Clips of the
    Surface s and size w*h.
    */
    this(Surface s, int w, int h) {
        src = s;
        width = w;
        height = h;
        clipsPerLine = cast(int) floor((0.0 + src.width) / width);        
    }
    
    /**
    How many Clips are there?
    */
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
