module mysdl.sdlapi_types;

import std.c.stdio;
public import mysdl.sdlapi_keys;

/* -------Basic----------*/
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
enum
{
    SDL_NOEVENT = 0,
    SDL_ACTIVEEVENT,
    SDL_KEYDOWN,
    SDL_KEYUP,
    SDL_MOUSEMOTION,
    SDL_MOUSEBUTTONDOWN,
    SDL_MOUSEBUTTONUP,
    SDL_JOYAXISMOTION,
    SDL_JOYBALLMOTION,
    SDL_JOYHATMOTION,
    SDL_JOYBUTTONDOWN,
    SDL_JOYBUTTONUP,
    SDL_QUIT,
    SDL_SYSWMEVENT,
    SDL_EVENT_RESERVEDA,
    SDL_EVENT_RESERVEDB,
    SDL_VIDEORESIZE,
    SDL_VIDEOEXPOSE,
    SDL_EVENT_RESERVED2,
    SDL_EVENT_RESERVED3,
    SDL_EVENT_RESERVED4,
    SDL_EVENT_RESERVED5,
    SDL_EVENT_RESERVED6,
    SDL_EVENT_RESERVED7,
    SDL_USEREVENT = 24,
    SDL_NUMEVENTS = 32
}

enum
{
    SDL_ACTIVEEVENTMASK         = (1<<SDL_ACTIVEEVENT),
    SDL_KEYDOWNMASK             = (1<<SDL_KEYDOWN),
    SDL_KEYUPMASK               = (1<<SDL_KEYUP),
    SDL_KEYEVENTMASK            = SDL_KEYDOWNMASK | SDL_KEYUPMASK,
    SDL_MOUSEMOTIONMASK         = (1<<SDL_MOUSEMOTION),
    SDL_MOUSEBUTTONDOWNMASK     = (1<<SDL_MOUSEBUTTONDOWN),
    SDL_MOUSEBUTTONUPMASK       = (1<<SDL_MOUSEBUTTONUP),
    SDL_MOUSEEVENTMADK          = (SDL_MOUSEMOTIONMASK |
                                   SDL_MOUSEBUTTONDOWNMASK |
                                   SDL_MOUSEBUTTONUPMASK),
    SDL_JOYAXISMOTIONMASK       = (1<<SDL_JOYAXISMOTION),
    SDL_JOYBALLMOTIONMASK       = (1<<SDL_JOYBALLMOTION),
    SDL_JOYHATMOTIONMASK        = (1<<SDL_JOYHATMOTION),
    SDL_JOYBUTTONDOWNMASK       = (1<<SDL_JOYBUTTONDOWN),
    SDL_JOYBUTTONUPMASK         = (1<<SDL_JOYBUTTONUP),
    SDL_JOYEVENTMASK            = (SDL_JOYAXISMOTIONMASK |
                                   SDL_JOYBALLMOTIONMASK |
                                   SDL_JOYHATMOTIONMASK |
                                   SDL_JOYBUTTONDOWNMASK |
                                   SDL_JOYBUTTONUPMASK),
    SDL_VIDEORESIZEMASK         = (1<<SDL_VIDEORESIZE),
    SDL_VIDEOEXPOSEMASK         = (1<<SDL_VIDEOEXPOSE),
    SDL_QUITMASK                = (1<<SDL_QUIT),
    SDL_SYSWMEVENTMASK          = (1<<SDL_SYSWMEVENT)
}

enum : uint { SDL_ALLEVENTS = 0xFFFFFFFF }

struct SDL_ActiveEvent
{
    Uint8 type;
    Uint8 gain;
    Uint8 state;
}

struct SDL_KeyboardEvent
{
    Uint8 type;
    Uint8 which;
    Uint8 state;
    SDL_keysym keysym;
}

struct SDL_MouseMotionEvent
{
    Uint8 type;
    Uint8 which;
    Uint8 state;
    Uint16 x, y;
    Sint16 xrel;
    Sint16 yrel;
}

struct SDL_MouseButtonEvent
{
    Uint8 type;
    Uint8 which;
    Uint8 button;
    Uint8 state;
    Uint16 x, y;
}

struct SDL_JoyAxisEvent
{
    Uint8 type;
    Uint8 which;
    Uint8 axis;
    Sint16 value;
}

struct SDL_JoyBallEvent
{
    Uint8 type;
    Uint8 which;
    Uint8 ball;
    Sint16 xrel;
    Sint16 yrel;
}

struct SDL_JoyHatEvent
{
    Uint8 type;
    Uint8 which;
    Uint8 hat;
    Uint8 value;
}

struct SDL_JoyButtonEvent
{
    Uint8 type;
    Uint8 which;
    Uint8 button;
    Uint8 state;
}

struct SDL_ResizeEvent
{
    Uint8 type;
    int w;
    int h;
}

struct SDL_ExposeEvent
{
    Uint8 type;
}

struct SDL_QuitEvent
{
    Uint8 type;
}

struct SDL_UserEvent
{
    Uint8 type;
    int code;
    void *data1;
    void *data2;
}

struct SDL_SysWMEvent
{
    Uint8 type;
    SDL_SysWMmsg *msg;
}

union SDL_Event
{
    Uint8 type;
    SDL_ActiveEvent active;
    SDL_KeyboardEvent key;
    SDL_MouseMotionEvent motion;
    SDL_MouseButtonEvent button;
    SDL_JoyAxisEvent jaxis;
    SDL_JoyBallEvent jball;
    SDL_JoyHatEvent jhat;
    SDL_JoyButtonEvent jbutton;
    SDL_ResizeEvent resize;
    SDL_ExposeEvent expose;
    SDL_QuitEvent quit;
    SDL_UserEvent user;
    SDL_SysWMEvent syswm;
}

alias int SDL_eventaction;
enum
{
    SDL_ADDEVENT,
    SDL_PEEKEVENT,
    SDL_GETEVENT
}

extern(C) alias int function(in SDL_Event *event) SDL_EventFilter;

enum
{
    SDL_QUERY           = -1,
    SDL_IGNORE          = 0,
    SDL_DISABLE         = 0,
    SDL_ENABLE          = 1,
}


/*-------Mouse--------*/
// SDL_mouse.h
struct WMcursor {}

struct SDL_Cursor
{
    SDL_Rect area;
    Sint16 hot_x, hot_y;
    Uint8 *data;
    Uint8 *mask;
    Uint8 *save[2];
    WMcursor *wm_cursor;
}

enum : Uint8
{
    SDL_BUTTON_LEFT         = 1,
    SDL_BUTTON_MIDDLE       = 2,
    SDL_BUTTON_RIGHT        = 3,
    SDL_BUTTON_WHEELUP      = 4,
    SDL_BUTTON_WHEELDOWN    = 5,
    SDL_BUTTON_X1           = 6,
    SDL_BUTTON_X2           = 7,
    SDL_BUTTON_LMASK        = 1 << (SDL_BUTTON_LEFT-1),
    SDL_BUTTON_MMASK        = 1 << (SDL_BUTTON_MIDDLE-1),
    SDL_BUTTON_RMASK        = 1 << (SDL_BUTTON_RIGHT-1),
    SDL_BUTTON_X1MASK       = 1 << (SDL_BUTTON_X1-1),
    SDL_BUTTON_X2MASK       = 1 << (SDL_BUTTON_X2-1),
}

/*-------Keyboard-----*/
// SDL_keyboard.h
struct SDL_keysym
{
    Uint8 scancode;
    SDLKey sym;
    SDLMod mod;
    Uint16 unicode;
}

enum : uint { SDL_ALL_HOTKEYS = 0xFFFFFFFF }

enum
{
    SDL_DEFAULT_REPEAT_DELAY      = 500,
    SDL_DEFAULT_REPEAT_INTERVAL   = 30,
}

//Keys in mysdl.sdlapi_keys

alias int SDLMod;
enum
{
    KMOD_NONE  = 0x0000,
    KMOD_LSHIFT= 0x0001,
    KMOD_RSHIFT= 0x0002,
    KMOD_LCTRL = 0x0040,
    KMOD_RCTRL = 0x0080,
    KMOD_LALT  = 0x0100,
    KMOD_RALT  = 0x0200,
    KMOD_LMETA = 0x0400,
    KMOD_RMETA = 0x0800,
    KMOD_NUM   = 0x1000,
    KMOD_CAPS  = 0x2000,
    KMOD_MODE  = 0x4000,
    KMOD_RESERVED = 0x8000,
    KMOD_CTRL         = KMOD_LCTRL | KMOD_RCTRL,
    KMOD_SHIFT        = KMOD_LSHIFT | KMOD_RSHIFT,
    KMOD_ALT          = KMOD_LALT | KMOD_RALT,
    KMOD_META         = KMOD_LMETA | KMOD_RMETA,
}

/* -------IO---------- */
struct SDL_RWops
{
    extern(C)
    {
/+        int (*seek)(SDL_RWops *context, int offset, int whence);
        int (*read)(SDL_RWops *context, void *ptr, int size, int maxnum);
        int (*write)(SDL_RWops *context, in void *ptr, int size, int num);
        int (*close)(SDL_RWops *context); +/
        int function(SDL_RWops *context, int offset, int whence) seek;
        int function(SDL_RWops *context, void *ptr, int size, int maxnum) read;
        int function(SDL_RWops *context, in void *ptr, int size, int num) write;
        int function(SDL_RWops *context) close; 
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

/* ------SDLVersion -----*/
// SDL_version.h
enum : Uint8
{
    SDL_MAJOR_VERSION   = 1,
    SDL_MINOR_VERSION   = 2,
    SDL_PATCHLEVEL      = 13,
}

struct SDL_version
{
    Uint8 major;
    Uint8 minor;
    Uint8 patch;
}

version(D_Version2)
{
    mixin("alias const(SDL_version*) CSDLVERPTR;" );
}
else
{
    alias SDL_version* CSDLVERPTR;
}


void SDL_VERSION(SDL_version *X)
{
    X.major = SDL_MAJOR_VERSION;
    X.minor = SDL_MINOR_VERSION;
    X.patch = SDL_PATCHLEVEL;
}

uint SDL_VERSIONNUM(Uint8 major, Uint8 minor, Uint8 patch)
{
    return (major * 1000 + minor * 100 + patch);
}

enum : uint
{
    SDL_COMPILEDVERSION =  SDL_MAJOR_VERSION * 1000 +
                                  SDL_MINOR_VERSION * 100 + SDL_PATCHLEVEL,
}

bool SDL_VERSION_ATLEAST(Uint8 major, Uint8 minor, Uint8 patch)
{
    return cast(bool)(SDL_COMPILEDVERSION >= SDL_VERSIONNUM(major,minor,patch));
}

/* ------Syswm---------*/
// SDL_syswm.h
version(Windows)
{
    pragma(msg, "Don't use syswm. Mysdl's support is only a kludge.");

    struct SDL_SysWMmsg
    { /+
        // this is named 'version' in SDL_syswm.h, but since version is a keyword,
        // 'ver' will have to do
        SDL_version ver;
        HWND hwnd;
        UINT msg;
        WPARAM wParam;
        LPARAM lParam;
        +/
    }

    struct SDL_SysWMinfo
    {
       /+ // this is named 'version' in SDL_syswm.h, but since version is a keyword,
        // 'ver' will have to do
        SDL_version ver;
        HWND window;
        HGLRC hglrc; +/
    }
}
else
{
    struct SDL_SysWMmsg;
    struct SDL_SysWMinfo;
}
