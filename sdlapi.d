/**
 * This module declares the SDL-API.
 */
module mysdl.sdlapi;

public import mysdl.sdlapi_types;

//pragma(lib,r"D:\d\mysdl_test\SDL.lib");

/* ---------- SDL-Functions ----------- */
export extern(C) {
    void         SDL_Delay(Uint32 ms);
    SDL_Surface* SDL_DisplayFormat(SDL_Surface* surface);
    int          SDL_FillRect(SDL_Surface *dst, SDL_Rect *dstrect, Uint32 color);
    int          SDL_Flip(SDL_Surface* screen);
    void         SDL_FreeSurface(SDL_Surface* surface);
    char*        SDL_GetError();    
    int          SDL_Init(Uint32 flags);
    int          SDL_InitSubSystem (Uint32 flags);
    SDL_Surface* SDL_LoadBMP_RW(SDL_RWops*,int);
    Uint32       SDL_MapRGB(const SDL_PixelFormat* fmt, Uint8 r, Uint8 g, Uint8 b);
    int          SDL_SetColorKey(SDL_Surface* surface, Uint32 flag, Uint32 key);
    SDL_Surface* SDL_SetVideoMode(int width, int height, int bitsperpixel, Uint32 flags);
    int          SDL_PollEvent(SDL_Event* event);
    void         SDL_Quit(); 
    SDL_RWops*   SDL_RWFromFile(in char*,in char*);
    void         SDL_UpdateRect(SDL_Surface* screen, Sint32 x, Sint32 y, Sint32 w, Sint32 h);
    //1er Parameter const?
    int          SDL_UpperBlit(const SDL_Surface *src, SDL_Rect *srcrect, SDL_Surface *dst, SDL_Rect *dstrect);
    int          SDL_WasInit(Uint32 flags);
}

alias SDL_UpperBlit SDL_BlitSurface;

SDL_Surface* SDL_LoadBMP(in char* file)
{
    return SDL_LoadBMP_RW(SDL_RWFromFile(file, "rb"), 1);
}


