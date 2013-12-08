module mafisdl.video;

import std.algorithm: min, max;
import std.exception: enforce;
import std.string: toStringz, format;
import std.math: floor;

import mafisdl.sdlapi;
import mafisdl.system: SDLException, sdlEnforce;

alias Surface = SDL_Surface*;

@property int width(in Surface s) { return s.w; }
@property int height(in Surface s) { return s.h; }
@property Rect rect(in Surface s) { return Rect(0, 0, s.width, s.height); }
@property SClip whole(Surface s) { return SClip(s, s.rect); }

/* Painting */

void blit(Surface src, Rect r, Surface dst, int x, int y) {
    Rect dstrect = Rect(x, y, r.width, r.height);
    SDL_BlitSurface(src, &r, dst, &dstrect );
}

void blitTo(Surface src, Surface dst, int x, int y) {
    Rect dstrect = Rect(x, y, 0, 0);
    SDL_BlitSurface(src, null, src, &dstrect);
}

void fillRect(Surface src, Rect r, ubyte[3] color ...) {
    SDL_FillRect(src, &r, src.mapRGB(color));
}

void setColorKey(Surface s, ubyte[3] color ...) {
    sdlEnforce(SDL_SetColorKey(s, SDL_TRUE, s.mapRGB(color)));
}

uint mapRGB(Surface s, ubyte[3] color ...) {
    return SDL_MapRGB(s.format, color[0], color[1], color[2]);
}

void free(Surface s)
{
    SDL_FreeSurface(s);
}

Clip clip()(Rect r) {
    return Clip(this, r);
}

Clip clip(T...)(T t) if(is(typeof(Rect(t)) == Rect)) {
    return Clip(this, Rect(t));
}

/* Loading */

Surface loadBMP(string filename) {
    return enforce(
        SDL_LoadBMP(toStringz(filename)), new SDLException("Failed to load Bitmap")
    );
}

Surface loadBMP(ubyte[] rawBytes) {
    return enforce(
        SDL_LoadBMP_RW(SDL_RWFromMem(rawBytes.ptr, cast(int)rawBytes.length), 0)
    );
}



/**
This structure represents rectengular area with x, y, width
and heights.
*/

alias Rect = SDL_Rect;

@property int width(Rect r) { return r.w; }
@property int height(Rect r) { return r.h; }
@property int right(Rect r) { return r.x + r.w - 1; }
@property int bottom(Rect r) { return r.y + r.h - 1; }

bool contains(Rect r, int tx, int ty) {
    return tx >= r.x && tx <= r.right && ty >= r.y && ty <= r.bottom;
}

string toString(Rect r) {
    return format("Rect(%s,%s, %s,%s)", r.x, r.y, r.width, r.height);
}

Rect maximalBounds(Rect r, int w, int h) {
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
struct SClip {
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
    SClip clip()(Rect r) {
        return Clip(sur, absoluteSubrect(rect, r));
    }

    ///ditto
    SClip clip(T...)(T t) if(is(typeof(Rect(t)) == Rect)) {
        return clip(Rect(t));
    }
}

/**
Blit clip c onto a Surface or another clip.
*/
void blitTo(SClip src, Surface dst, int x, int y) {
    src.sur.blit(src.rect, dst, x, y);
}

///ditto
void blitTo(SClip src, SClip dst, int x, int y) {
    src.sur.blit(maximalBounds(src.rect, dst.rect.width - x, dst.rect.height - y),
        dst.sur, x, y);
}

/**
Fill the whole clip with one color.
-----
//Fill the whole surface black.
surface.whole.fill(0, 0, 0);
-----
*/
void fill(SClip c, ubyte[3] color...) {
    c.sur.fillRect(c.rect, color);
}

/**
This struct generates clips in a tileset like manner.

Use opIndex() to get the n-th Clip or opSlice() to get
the whole Clip[].
*/
struct SClipper {
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

    SClip opIndex(int index) {
        int x = index % clipsPerLine;
        int y = (index - x) / clipsPerLine;
        auto r = Rect(x * width, y * height, width, height);
        return SClip(src, r);
    }

    SClip[] opSlice() {
        return opSlice(0, opDollar());
    }

    SClip[] opSlice(int st, int end) {
        SClip[] list;
        foreach(i; st .. end) {
            list ~= opIndex(i);
        }
        return list;
    }


}
