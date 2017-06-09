module mafisdl.ext.ttf;

import std.algorithm, std.conv, std.string;

import mafisdl.system, mafisdl.video;

import derelict.sdl2.ttf;

/**
Init the SDL ttf extension.

Loads the library through Derelict if necessary.
*/
void initTTF() {
    if(!DerelictSDL2ttf.isLoaded) {
        DerelictSDL2ttf.load();
    }
    if(TTF_Init() != 0) throw new SDLTTFException;
}

///The TTF Font (reference) type
alias Font = TTF_Font*;

Font loadFont(string file, int ptsize) {
    Font font = TTF_OpenFont(toStringz(file), ptsize);
    if(!font) throw new SDLTTFException;
    return font;
}

void freeFont(Font font) {
    assert(font != null);
    TTF_CloseFont(font);
    font = null;
}

struct RenderedTextBuffer(size_t n) {
    char[n + 1] buffer;
    size_t len;
    Texture texture;

    void setText(Renderer display, Font font, const char[] text, ubyte[3] color...) {
        setText(display, font, text, color[0], color[1], color[2], 255);
    }

    void setText(Renderer display, Font font, const char[] text, ubyte[4] color...) {
        if(text == buffer[0..len]) return;

        len = min(text.length, n);
        buffer[0..len] = text[0..len];
        //make buffer string zero-terminated
        buffer[len] = '\0';

        SDL_Color sdlColor;
        sdlColor.r = color[0];
        sdlColor.g = color[1];
        sdlColor.b = color[2];
        sdlColor.a = color[3];

        Surface surface = null;
        if(len != 0) {
            surface = TTF_RenderUTF8_Blended(font, &buffer[0], sdlColor);
            if(!surface) throw new SDLTTFException;
        }

        Texture newTexture = null;
        if(surface) newTexture = fromSurface(display, surface);

        if(texture) {
            SDL_DestroyTexture(texture);
        }
        texture = newTexture;
        if(surface) free(surface);
    }
}

/**
An exception thrown for problems specific to SDL ttf
extension.
*/
class SDLTTFException : SDLException {
    this(string s) {
        super(s);
    }

    this() {
        super(to!string(TTF_GetError()));
    }
}
