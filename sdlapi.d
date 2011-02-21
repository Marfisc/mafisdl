/**
 * This module declares the SDL-API.
 */
module mysdl.sdlapi;

public import derelict.sdl.sdl;
public import mysdl.sdlapi_types;

version(none):
//pragma(lib,r"D:\d\mysdl_test\SDL.lib");

/* ---------- SDL-Functions ----------- */
export extern(C) {
    void         SDL_Delay(Uint32 ms);
    SDL_Surface* SDL_DisplayFormat(SDL_Surface* surface);
    int          SDL_FillRect(SDL_Surface *dst, SDL_Rect *dstrect, Uint32 color);
    int          SDL_Flip(SDL_Surface* screen);
    void         SDL_FreeSurface(SDL_Surface* surface);
    char*        SDL_GetError();    
    Uint8        SDL_GetMouseState(int *x, int *y);
    int          SDL_GetTicks();
    Uint8*       SDL_GetKeyState(int *numkeys);    
    int          SDL_Init(Uint32 flags);
    int          SDL_InitSubSystem (Uint32 flags);
    void         SDL_JoystickClose (SDL_Joystick *Joystick);
    int          SDL_JoystickEventState (int state);
    Sint16       SDL_JoystickGetAxis (SDL_Joystick* Joystick, int no);
    int          SDL_JoystickGetBall (SDL_Joystick* Joystick, int ball, int *dx, int *dy);
    Uint8        SDL_JoystickGetButton(SDL_Joystick* joystick, int button);
    Uint8        SDL_JoystickGetHat (SDL_Joystick* JoyStick, int no);
    int          SDL_JoystickNumAxes (SDL_Joystick* Joystick);
    int          SDL_JoystickNumBalls (SDL_Joystick* Joystick);
    int          SDL_JoystickNumButtons (SDL_Joystick *Joystick);  
    int          SDL_JoystickNumHats (SDL_Joystick* Joystick);
    SDL_Joystick* SDL_JoystickOpen (int index);
    SDL_Surface* SDL_LoadBMP_RW(SDL_RWops*,int);
    Uint32       SDL_MapRGB(const SDL_PixelFormat* fmt, Uint8 r, Uint8 g, Uint8 b);
    int          SDL_NumJoysticks();
    int          SDL_SetColorKey(SDL_Surface* surface, Uint32 flag, Uint32 key);
    SDL_Surface* SDL_SetVideoMode(int width, int height, int bitsperpixel, Uint32 flags);
    int          SDL_PollEvent(SDL_Event* event);
    void         SDL_Quit(); 
    SDL_RWops*   SDL_RWFromFile(in char*,in char*);
    void         SDL_UpdateRect(SDL_Surface* screen, Sint32 x, Sint32 y, Sint32 w, Sint32 h);
    //1st parameter const?
    int          SDL_UpperBlit(const SDL_Surface *src, SDL_Rect *srcrect, SDL_Surface *dst, SDL_Rect *dstrect);
    int          SDL_WasInit(Uint32 flags);
}

alias SDL_UpperBlit SDL_BlitSurface;

SDL_Surface* SDL_LoadBMP(in char* file)
{
    return SDL_LoadBMP_RW(SDL_RWFromFile(file, "rb"), 1);
}

Uint8 SDL_BUTTON(Uint8 x)
{
    return cast(Uint8)(1 << (x - 1));
}

