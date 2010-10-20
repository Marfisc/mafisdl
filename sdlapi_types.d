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

// SDL_keysym.h
alias int SDLKey;
enum
{
    /* The keyboard syms have been cleverly chosen to map to ASCII */
    SDLK_UNKNOWN        = 0,
    SDLK_FIRST      = 0,
    SDLK_BACKSPACE      = 8,
    SDLK_TAB        = 9,
    SDLK_CLEAR      = 12,
    SDLK_RETURN     = 13,
    SDLK_PAUSE      = 19,
    SDLK_ESCAPE     = 27,
    SDLK_SPACE      = 32,
    SDLK_EXCLAIM        = 33,
    SDLK_QUOTEDBL       = 34,
    SDLK_HASH       = 35,
    SDLK_DOLLAR     = 36,
    SDLK_AMPERSAND      = 38,
    SDLK_QUOTE      = 39,
    SDLK_LEFTPAREN      = 40,
    SDLK_RIGHTPAREN     = 41,
    SDLK_ASTERISK       = 42,
    SDLK_PLUS       = 43,
    SDLK_COMMA      = 44,
    SDLK_MINUS      = 45,
    SDLK_PERIOD     = 46,
    SDLK_SLASH      = 47,
    SDLK_0          = 48,
    SDLK_1          = 49,
    SDLK_2          = 50,
    SDLK_3          = 51,
    SDLK_4          = 52,
    SDLK_5          = 53,
    SDLK_6          = 54,
    SDLK_7          = 55,
    SDLK_8          = 56,
    SDLK_9          = 57,
    SDLK_COLON      = 58,
    SDLK_SEMICOLON      = 59,
    SDLK_LESS       = 60,
    SDLK_EQUALS     = 61,
    SDLK_GREATER        = 62,
    SDLK_QUESTION       = 63,
    SDLK_AT         = 64,
    /*
       Skip uppercase letters
     */
    SDLK_LEFTBRACKET    = 91,
    SDLK_BACKSLASH      = 92,
    SDLK_RIGHTBRACKET   = 93,
    SDLK_CARET      = 94,
    SDLK_UNDERSCORE     = 95,
    SDLK_BACKQUOTE      = 96,
    SDLK_a          = 97,
    SDLK_b          = 98,
    SDLK_c          = 99,
    SDLK_d          = 100,
    SDLK_e          = 101,
    SDLK_f          = 102,
    SDLK_g          = 103,
    SDLK_h          = 104,
    SDLK_i          = 105,
    SDLK_j          = 106,
    SDLK_k          = 107,
    SDLK_l          = 108,
    SDLK_m          = 109,
    SDLK_n          = 110,
    SDLK_o          = 111,
    SDLK_p          = 112,
    SDLK_q          = 113,
    SDLK_r          = 114,
    SDLK_s          = 115,
    SDLK_t          = 116,
    SDLK_u          = 117,
    SDLK_v          = 118,
    SDLK_w          = 119,
    SDLK_x          = 120,
    SDLK_y          = 121,
    SDLK_z          = 122,
    SDLK_DELETE     = 127,
    /* End of ASCII mapped keysyms */

    /* International keyboard syms */
    SDLK_WORLD_0        = 160,      /* 0xA0 */
    SDLK_WORLD_1        = 161,
    SDLK_WORLD_2        = 162,
    SDLK_WORLD_3        = 163,
    SDLK_WORLD_4        = 164,
    SDLK_WORLD_5        = 165,
    SDLK_WORLD_6        = 166,
    SDLK_WORLD_7        = 167,
    SDLK_WORLD_8        = 168,
    SDLK_WORLD_9        = 169,
    SDLK_WORLD_10       = 170,
    SDLK_WORLD_11       = 171,
    SDLK_WORLD_12       = 172,
    SDLK_WORLD_13       = 173,
    SDLK_WORLD_14       = 174,
    SDLK_WORLD_15       = 175,
    SDLK_WORLD_16       = 176,
    SDLK_WORLD_17       = 177,
    SDLK_WORLD_18       = 178,
    SDLK_WORLD_19       = 179,
    SDLK_WORLD_20       = 180,
    SDLK_WORLD_21       = 181,
    SDLK_WORLD_22       = 182,
    SDLK_WORLD_23       = 183,
    SDLK_WORLD_24       = 184,
    SDLK_WORLD_25       = 185,
    SDLK_WORLD_26       = 186,
    SDLK_WORLD_27       = 187,
    SDLK_WORLD_28       = 188,
    SDLK_WORLD_29       = 189,
    SDLK_WORLD_30       = 190,
    SDLK_WORLD_31       = 191,
    SDLK_WORLD_32       = 192,
    SDLK_WORLD_33       = 193,
    SDLK_WORLD_34       = 194,
    SDLK_WORLD_35       = 195,
    SDLK_WORLD_36       = 196,
    SDLK_WORLD_37       = 197,
    SDLK_WORLD_38       = 198,
    SDLK_WORLD_39       = 199,
    SDLK_WORLD_40       = 200,
    SDLK_WORLD_41       = 201,
    SDLK_WORLD_42       = 202,
    SDLK_WORLD_43       = 203,
    SDLK_WORLD_44       = 204,
    SDLK_WORLD_45       = 205,
    SDLK_WORLD_46       = 206,
    SDLK_WORLD_47       = 207,
    SDLK_WORLD_48       = 208,
    SDLK_WORLD_49       = 209,
    SDLK_WORLD_50       = 210,
    SDLK_WORLD_51       = 211,
    SDLK_WORLD_52       = 212,
    SDLK_WORLD_53       = 213,
    SDLK_WORLD_54       = 214,
    SDLK_WORLD_55       = 215,
    SDLK_WORLD_56       = 216,
    SDLK_WORLD_57       = 217,
    SDLK_WORLD_58       = 218,
    SDLK_WORLD_59       = 219,
    SDLK_WORLD_60       = 220,
    SDLK_WORLD_61       = 221,
    SDLK_WORLD_62       = 222,
    SDLK_WORLD_63       = 223,
    SDLK_WORLD_64       = 224,
    SDLK_WORLD_65       = 225,
    SDLK_WORLD_66       = 226,
    SDLK_WORLD_67       = 227,
    SDLK_WORLD_68       = 228,
    SDLK_WORLD_69       = 229,
    SDLK_WORLD_70       = 230,
    SDLK_WORLD_71       = 231,
    SDLK_WORLD_72       = 232,
    SDLK_WORLD_73       = 233,
    SDLK_WORLD_74       = 234,
    SDLK_WORLD_75       = 235,
    SDLK_WORLD_76       = 236,
    SDLK_WORLD_77       = 237,
    SDLK_WORLD_78       = 238,
    SDLK_WORLD_79       = 239,
    SDLK_WORLD_80       = 240,
    SDLK_WORLD_81       = 241,
    SDLK_WORLD_82       = 242,
    SDLK_WORLD_83       = 243,
    SDLK_WORLD_84       = 244,
    SDLK_WORLD_85       = 245,
    SDLK_WORLD_86       = 246,
    SDLK_WORLD_87       = 247,
    SDLK_WORLD_88       = 248,
    SDLK_WORLD_89       = 249,
    SDLK_WORLD_90       = 250,
    SDLK_WORLD_91       = 251,
    SDLK_WORLD_92       = 252,
    SDLK_WORLD_93       = 253,
    SDLK_WORLD_94       = 254,
    SDLK_WORLD_95       = 255,      /* 0xFF */

    /* Numeric keypad */
    SDLK_KP0        = 256,
    SDLK_KP1        = 257,
    SDLK_KP2        = 258,
    SDLK_KP3        = 259,
    SDLK_KP4        = 260,
    SDLK_KP5        = 261,
    SDLK_KP6        = 262,
    SDLK_KP7        = 263,
    SDLK_KP8        = 264,
    SDLK_KP9        = 265,
    SDLK_KP_PERIOD      = 266,
    SDLK_KP_DIVIDE      = 267,
    SDLK_KP_MULTIPLY    = 268,
    SDLK_KP_MINUS       = 269,
    SDLK_KP_PLUS        = 270,
    SDLK_KP_ENTER       = 271,
    SDLK_KP_EQUALS      = 272,

    /* Arrows + Home/End pad */
    SDLK_UP         = 273,
    SDLK_DOWN       = 274,
    SDLK_RIGHT      = 275,
    SDLK_LEFT       = 276,
    SDLK_INSERT     = 277,
    SDLK_HOME       = 278,
    SDLK_END        = 279,
    SDLK_PAGEUP     = 280,
    SDLK_PAGEDOWN       = 281,

    /* Function keys */
    SDLK_F1         = 282,
    SDLK_F2         = 283,
    SDLK_F3         = 284,
    SDLK_F4         = 285,
    SDLK_F5         = 286,
    SDLK_F6         = 287,
    SDLK_F7         = 288,
    SDLK_F8         = 289,
    SDLK_F9         = 290,
    SDLK_F10        = 291,
    SDLK_F11        = 292,
    SDLK_F12        = 293,
    SDLK_F13        = 294,
    SDLK_F14        = 295,
    SDLK_F15        = 296,

    /* Key state modifier keys */
    SDLK_NUMLOCK        = 300,
    SDLK_CAPSLOCK       = 301,
    SDLK_SCROLLOCK      = 302,
    SDLK_RSHIFT     = 303,
    SDLK_LSHIFT     = 304,
    SDLK_RCTRL      = 305,
    SDLK_LCTRL      = 306,
    SDLK_RALT       = 307,
    SDLK_LALT       = 308,
    SDLK_RMETA      = 309,
    SDLK_LMETA      = 310,
    SDLK_LSUPER     = 311,      /* Left "Windows" key */
    SDLK_RSUPER     = 312,      /* Right "Windows" key */
    SDLK_MODE       = 313,      /* "Alt Gr" key */
    SDLK_COMPOSE        = 314,      /* Multi-key compose key */

    /* Miscellaneous function keys */
    SDLK_HELP       = 315,
    SDLK_PRINT      = 316,
    SDLK_SYSREQ     = 317,
    SDLK_BREAK      = 318,
    SDLK_MENU       = 319,
    SDLK_POWER      = 320,      /* Power Macintosh power key */
    SDLK_EURO       = 321,      /* Some european keyboards */
    SDLK_UNDO       = 322,      /* Atari keyboard has Undo */

    /* Add any other keys here */

    SDLK_LAST
}

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
