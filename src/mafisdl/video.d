module mafisdl.video;

import std.algorithm: min, max;
import std.exception: enforce;
import std.string: toStringz, format;
import std.math: floor;

//import mafisdl.sdlapi;
public import derelict.sdl2.sdl;
import mafisdl.system;

///The SDL renderer (reference) type
alias Renderer = SDL_Renderer*;

///Create the renderer for the given window
Renderer createRenderer(Window window, uint flags = 0) {
    return SDL_CreateRenderer(window, -1, cast(SDL_RendererFlags) flags);
}

///Set the drawing colour for the given renderer
Renderer setColor(Renderer r, ubyte[3] color...) {
    SDL_SetRenderDrawColor(r, color[0], color[1], color[2], SDL_ALPHA_OPAQUE);
    return r;
}

///ditto
Renderer setColor(Renderer r, ubyte[4] color...) {
    SDL_SetRenderDrawColor(r, color[0], color[1], color[2], color[3]);
    return r;
}

///Draw the (outline of the) given rect onto renderer using the current colour.
void drawRect(Renderer renderer, Rect rect) {
    SDL_RenderDrawRect(renderer, &rect);
}

///Fill the given rect in renderer using the current colour.
void fillRect(Renderer renderer, Rect rect) {
    SDL_RenderFillRect(renderer, &rect);
}

///Clear the renderer using the current colour
alias renderClear = SDL_RenderClear;

///Push the rendered image onto the screen
alias renderPresent = SDL_RenderPresent;


///The SDL texture (reference) type
alias Texture = SDL_Texture*;

/**
Upload a surface to a renderer's texture space

throws: SDLException
*/
Texture fromSurface(Renderer renderer, Surface surface) {
    return enforce(SDL_CreateTextureFromSurface(renderer, surface), new SDLException);
}

/**
Query the size of a texture

throws: SDLException
*/
int width(Texture texture) {
    int result;
    sdlEnforce(SDL_QueryTexture(texture, null, null, &result, null));

    return result;
}

///ditto
int height(Texture texture) {
    int result;
    sdlEnforce(SDL_QueryTexture(texture, null, null, null, &result));

    return result;
}

///ditto
Rect whole(Texture texture) {
    int width, height;
    sdlEnforce(SDL_QueryTexture(texture, null, null, &width, &height));

    return Rect(0, 0, width, height);
}

/**
Copy (some part of) the texture onto the renderer at x,y or rescale it
into the destination space.

throws: SDLException
*/
void renderCopy(Renderer renderer, Texture texture, int x, int y) {
    Rect src = Rect(0, 0, 0, 0);
    sdlEnforce(SDL_QueryTexture(texture, null, null, &src.w, &src.h));
    renderCopy(renderer, texture, &src, x, y);
}

///ditto
void renderCopy(Renderer renderer, Texture texture, Rect src, int x, int y) {
    renderCopy(renderer, texture, &src, x, y);
}

///ditto
void renderCopy(Renderer renderer, Texture texture, Rect* src, int x, int y) {
    Rect dst = Rect(x, y, src.w, src.h);
    sdlEnforce(SDL_RenderCopy(renderer, texture, src, &dst));
}

///ditto
void renderCopy(Renderer renderer, Texture texture, Rect dst) {
    renderCopy(renderer, texture, &dst);
}

///ditto
void renderCopy(Renderer renderer, Texture texture, Rect* dst) {
    Rect src = Rect(0, 0, 0, 0);
    sdlEnforce(SDL_QueryTexture(texture, null, null, &src.w, &src.h));
    sdlEnforce(SDL_RenderCopy(renderer, texture, &src, dst));
}

///ditto
void renderCopy(Renderer renderer, Texture texture, Rect src, Rect dst) {
    renderCopy(renderer, texture, &src, &dst);
}

///ditto
void renderCopy(Renderer renderer, Texture texture, Rect* src, Rect dst) {
    renderCopy(renderer, texture, src, &dst);
}

///ditto
void renderCopy(Renderer renderer, Texture texture, Rect src, Rect* dst) {
    renderCopy(renderer, texture, &src, dst);
}

///ditto
void renderCopy(Renderer renderer, Texture texture, Rect* src, Rect* dst) {
    sdlEnforce(SDL_RenderCopy(renderer, texture, src, dst));
}

///The SDL surface (reference) type
alias Surface = SDL_Surface*;

///Query the size of a surface
int width(in Surface s) { return s.w; }

///ditto
int height(in Surface s) { return s.h; }

///ditto
Rect rect(in Surface s) { return Rect(0, 0, s.width, s.height); }


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

///Free surface
void free(Surface s)
{
    SDL_FreeSurface(s);
}


/* Loading */

/**
Load a BMP

throws: SDLException
*/
Surface loadBMP(string filename) {
    return enforce(
        SDL_LoadBMP(toStringz(filename)), new SDLException("Failed to load Bitmap")
    );
}

///ditto
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

int width(Rect r) { return r.w; }
int height(Rect r) { return r.h; }
int right(Rect r) { return r.x + r.w - 1; }
int bottom(Rect r) { return r.y + r.h - 1; }

///Returns true iff r contains the point x,y
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
        min(minor.width, major.width  - minor.x, major.width),
        min(minor.height, major.height - minor.y, major.height));
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
The rect that contains only and all of the points that are in both
a and b.
*/
Rect overlap(Rect a, Rect b) {
    auto x = max(a.x, b.x);
    auto y = max(a.y, b.y);
    auto r = min(a.x + a.width, b.x + b.width);
    auto d = min(a.y + a.height, b.y + b.height);
    return Rect(x, y, r - x, d - y);
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

