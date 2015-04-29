module mafisdl.events;

import mafisdl.sdlapi;

import std.traits;

alias SDL_KEYDOWN keyDown;
alias SDL_KEYUP   keyUp;
alias SDL_MOUSEBUTTONDOWN mouseDown;
alias SDL_MOUSEBUTTONUP   mouseUp;
alias SDL_JOYBUTTONDOWN  joyButtonDown;
alias SDL_JOYBUTTONUP    joyButtonUp;
alias SDL_BUTTON_LEFT     leftButton;
alias SDL_BUTTON_RIGHT    rightButton;
alias SDL_BUTTON_MIDDLE   middleButton;


//These are all (documented) Events (21.10.10)
mixin aliasEvent!("QuitEvent");
mixin aliasEvent!("KeyboardEvent");
mixin aliasEvent!("MouseMotionEvent");
mixin aliasEvent!("MouseButtonEvent");
mixin aliasEvent!("JoyAxisEvent");
mixin aliasEvent!("JoyBallEvent");
mixin aliasEvent!("JoyHatEvent");
mixin aliasEvent!("JoyButtonEvent");
mixin aliasEvent!("UserEvent");
mixin aliasEvent!("SysWMEvent");
alias SDL_Event Event;

struct KeyUp {
    KeyboardEvent event;
    alias event this;
}
struct KeyDown {
    KeyboardEvent event;
    alias event this;
}

struct MouseButtonUp {
    MouseButtonEvent event;
    alias event this;
}
struct MouseButtonDown {
    MouseButtonEvent event;
    alias event this;
}

struct JoyButtonUp {
    JoyButtonEvent event;
    alias event this;
}
struct JoyButtonDown {
    JoyButtonEvent event;
    alias event this;
}

private KeyUp eventKeyUp(Event ev) { return KeyUp(ev.key); }
private KeyDown eventKeyDown(Event ev) { return KeyDown(ev.key); }
private MouseButtonUp eventMouseButtonUp(Event ev) { return MouseButtonUp(ev.button); }
private MouseButtonDown eventMouseButtonDown(Event ev) { return MouseButtonDown(ev.button); }
private JoyButtonUp eventJoyButtonUp(Event ev) { return JoyButtonUp(ev.jbutton); }
private JoyButtonDown eventJoyButtonDown(Event ev) { return JoyButtonDown(ev.jbutton); }

void eventLoop(T)(T that) {
    template caseOnEvent(string constant, string name) {
        enum caseOnEvent = "
        static if(is(typeof(that.on(polledEvent."~name~")))) {
            case "~constant~":
            that.on(polledEvent."~name~"); break;
        }";
    }

    static if(is(typeof(that.beginLoop()))) {
        that.beginLoop();
    }


    while(mixin(is(typeof(that.keepLooping))?
        "that.keepLooping" : "true")) {
        SDL_Event polledEvent;
        while(SDL_PollEvent(&polledEvent)) {
            switch(polledEvent.type) {
                mixin(caseOnEvent!("SDL_QUIT", "quit"));
                mixin(caseOnEvent!("SDL_ACTIVEEVEENT", "active"));
                mixin(caseOnEvent!("SDL_KEYDOWN", "eventKeyDown"));
                mixin(caseOnEvent!("SDL_KEYUP", "eventKeyUp"));
                mixin(caseOnEvent!("SDL_MOUSEMOTION", "motion"));
                mixin(caseOnEvent!("SDL_MOUSEBUTTONUP", "eventMouseButtonUp"));
                mixin(caseOnEvent!("SDL_MOUSEBUTTONDOWN", "eventMouseButtonDown"));
                mixin(caseOnEvent!("SDL_JOYAXISMOTION", "jaxis"));
                mixin(caseOnEvent!("SDL_JOYBALLMOTION", "jball"));
                mixin(caseOnEvent!("SDL_JOYHATMOTION", "jhat"));
                mixin(caseOnEvent!("SDL_JOYBUTTONDOWN", "eventJoyButtonDown"));
                mixin(caseOnEvent!("SDL_JOYBUTTONUP", "eventJoyButtonUp"));
                mixin(caseOnEvent!("SDL_USEREVENT", "user"));
                mixin(caseOnEvent!("SDL_SYSWMEVENT", "syswm"));
            default: //has to be there even if empty
                static if(is(typeof(that.onOther(Event.init)))) {
                    that.onOther(polledEvent); break;
                }
            }
        }
        static if(is(typeof(that.looping()))) {
            that.looping();
        }
    }
}

private mixin template aliasEvent(string ev) {
    mixin("alias SDL_"~ev~" "~ev~";");
}
