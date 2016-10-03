module mafisdl.events;

import derelict.sdl2.sdl;

import std.traits;

/** an alias for the correspondnig SDL event type */
alias SDL_KEYDOWN keyDown;
alias SDL_KEYUP   keyUp; /// ditto
alias SDL_MOUSEBUTTONDOWN mouseDown; /// ditto
alias SDL_MOUSEBUTTONUP   mouseUp; /// ditto
alias SDL_JOYBUTTONDOWN  joyButtonDown; /// ditto
alias SDL_JOYBUTTONUP    joyButtonUp; /// ditto
alias SDL_BUTTON_LEFT     leftButton; /// ditto
alias SDL_BUTTON_RIGHT    rightButton; /// ditto
alias SDL_BUTTON_MIDDLE   middleButton; /// ditto


//These are all (documented) Events
mixin aliasEvent!("QuitEvent");
mixin aliasEvent!("KeyboardEvent");
mixin aliasEvent!("MouseMotionEvent");
mixin aliasEvent!("MouseButtonEvent");
mixin aliasEvent!("MouseWheelEvent");
mixin aliasEvent!("JoyAxisEvent");
mixin aliasEvent!("JoyBallEvent");
mixin aliasEvent!("JoyHatEvent");
mixin aliasEvent!("JoyButtonEvent");
mixin aliasEvent!("UserEvent");
mixin aliasEvent!("SysWMEvent");
mixin aliasEvent!("TextInputEvent");
mixin aliasEvent!("TextEditingEvent");

/**
The SDL event type. All SDL_XEvent types are aliased to XEvent.
*/
alias SDL_Event Event;

/**
Shallow wrapper type allowing to overload on event type.
*/
struct KeyUp {
    KeyboardEvent event;
    alias event this;
}

/// ditto
struct KeyDown {
    KeyboardEvent event;
    alias event this;
}

/// ditto
struct MouseButtonUp {
    MouseButtonEvent event;
    alias event this;
}

/// ditto
struct MouseButtonDown {
    MouseButtonEvent event;
    alias event this;
}

/// ditto
struct JoyButtonUp {
    JoyButtonEvent event;
    alias event this;
}

/// ditto
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

/**
Implements an event loop using the given value.

First that.beginLoop() is called (if available).

The events are listened for in a loop while that.keepLooping
is true (if available).

Events are dispatched to that.on(...) overloads. This on member
should get a single parameter of the sdl event type. The events
with up and down variants can be split by overloading the
KeyUp, KeyDown etc. wrappers defined above.

Not every event needs to be dispatched. You can receive all other
events by defining that.onOther(Event). Otherwise all other
events are ignored.

Define that.looping() to define the actions for every loop iteration
(regardless of the number of events).
*/
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
                mixin(caseOnEvent!("SDL_MOUSEWHEEL", "wheel"));
                mixin(caseOnEvent!("SDL_MOUSEBUTTONUP", "eventMouseButtonUp"));
                mixin(caseOnEvent!("SDL_MOUSEBUTTONDOWN", "eventMouseButtonDown"));
                mixin(caseOnEvent!("SDL_JOYAXISMOTION", "jaxis"));
                mixin(caseOnEvent!("SDL_JOYBALLMOTION", "jball"));
                mixin(caseOnEvent!("SDL_JOYHATMOTION", "jhat"));
                mixin(caseOnEvent!("SDL_JOYBUTTONDOWN", "eventJoyButtonDown"));
                mixin(caseOnEvent!("SDL_JOYBUTTONUP", "eventJoyButtonUp"));
                mixin(caseOnEvent!("SDL_USEREVENT", "user"));
                mixin(caseOnEvent!("SDL_SYSWMEVENT", "syswm"));
                mixin(caseOnEvent!("SDL_TEXTINPUT", "text"));
                mixin(caseOnEvent!("SDL_TEXTINPUT", "edit"));
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
