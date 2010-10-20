module mysdl.sdlapi_types;

import std.c.stdio;

/* -------Basic----------*/
//TODO think about this
alias int Sint32;
alias uint Uint32;
alias short Sint16;
alias ushort Uint16;
alias byte Sint8;
alias ubyte Uint8;


enum : Uint32 {
    SDL_INIT_TIMER =       0x00000001,
    SDL_INIT_AUDIO =       0x00000010,
    SDL_INIT_VIDEO =       0x00000020,
    SDL_INIT_CDROM =       0x00000100,
    SDL_INIT_JOYSTICK =    0x00000200,
    SDL_INIT_NOPARACHUTE = 0x00100000, /*< Don't catch fatal signals */
    SDL_INIT_EVENTTHREAD = 0x01000000, /*< Not supported on all OS's */
    SDL_INIT_EVERYTHING  = 0x0000FFFF
}

/* -------Graphic------- */
struct SDL_Rect
{
    Sint16 x, y;
    Uint16 w, h;
}

struct SDL_Color
{
    Uint8 r;
    Uint8 g;
    Uint8 b;
    Uint8 unused;
}
alias SDL_Color SDL_Colour;

struct SDL_Palette
{
    int ncolors;
    SDL_Color *colors;
}

struct SDL_PixelFormat
{
    SDL_Palette *palette;
    Uint8 BitsPerPixel;
    Uint8 BytesPerPixel;
    Uint8 Rloss;
    Uint8 Gloss;
    Uint8 Bloss;
    Uint8 Aloss;
    Uint8 Rshift;
    Uint8 Gshift;
    Uint8 Bshift;
    Uint8 Ashift;
    Uint32 Rmask;
    Uint32 Gmask;
    Uint32 Bmask;
    Uint32 Amask;
    Uint32 colorkey;
    Uint8 alpha;
}

struct SDL_Surface
{
    Uint32 flags;
    SDL_PixelFormat *format;
    int w, h;
    Uint16 pitch;
    void *pixels;
    int offset;
    void *hwdata;
    SDL_Rect clip_rect;
    Uint32 unused1;
    Uint32 locked;
    void *map;
    uint format_version;
    int refcount;
}

enum : Uint32
{
    SDL_SWSURFACE                  = 0x00000000,
    SDL_HWSURFACE                  = 0x00000001,
    SDL_ASYNCBLIT                  = 0x00000004,
    SDL_ANYFORMAT                  = 0x10000000,
    SDL_HWPALETTE                  = 0x20000000,
    SDL_DOUBLEBUF                  = 0x40000000,
    SDL_FULLSCREEN                 = 0x80000000,
    SDL_OPENGL                     = 0x00000002,
    SDL_OPENGLBLIT                 = 0x0000000A,
    SDL_RESIZABLE                  = 0x00000010,
    SDL_NOFRAME                    = 0x00000020,
    SDL_HWACCEL                    = 0x00000100,
    SDL_SRCCOLORKEY                = 0x00001000,
    SDL_RLEACCELOK                 = 0x00002000,
    SDL_RLEACCEL                   = 0x00004000,
    SDL_SRCALPHA                   = 0x00010000,
    SDL_PREALLOC                   = 0x01000000,
}

/* -------Event------- */
/* -------IO---------- */
struct SDL_RWops
{
    extern(C)
    {
        int (*seek)(SDL_RWops *context, int offset, int whence);
        int (*read)(SDL_RWops *context, void *ptr, int size, int maxnum);
        int (*write)(SDL_RWops *context, in void *ptr, int size, int num);
        int (*close)(SDL_RWops *context);
    }

    Uint32 type;
    union Hidden
    {
        version(Windows)
        {
            struct Win32io
            {
                int append;
                void *h;
            }
            Win32io win32io;
        }

        struct Stdio
        {
            int autoclose;
            FILE *fp;
        }
        Stdio stdio;

        struct Mem
        {
            Uint8 *base;
            Uint8 *here;
            Uint8 *stop;
        }
        Mem mem;

        struct Unknown
        {
            void *data1;
        }
        Unknown unknown;
    }
    Hidden hidden;
}
