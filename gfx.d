module mysdl.gfx;

import std.exception: enforce;
import std.string: toStringz;
import std.stdio: IOException;
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
    
    void blitFrom(const Surface src) {
        src.blitTo(this);
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