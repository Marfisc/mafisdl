module mysdl.events;

import mysdl.sdlapi;

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
mixin aliasEvent!("ActiveEvent");
mixin aliasEvent!("KeyboardEvent");
mixin aliasEvent!("MouseMotionEvent");
mixin aliasEvent!("MouseButtonEvent");
mixin aliasEvent!("JoyAxisEvent");
mixin aliasEvent!("JoyBallEvent");
mixin aliasEvent!("JoyHatEvent");
mixin aliasEvent!("JoyButtonEvent");
mixin aliasEvent!("ResizeEvent");
mixin aliasEvent!("ExposeEvent");
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
            polledEvent.eventKeyUp;
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
                mixin(caseOnEvent!("SDL_VIDEOEXPOSE", "expose"));
                mixin(caseOnEvent!("SDL_VIDEORESIZE", "resize"));
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

/*
 Internal structure for holding delegates 
 and giving them logic for listen
 */
private struct EventListener {
    mixin event!"QuitEvent";
    mixin event!"ActiveEvent";
    mixin event!"KeyboardEvent";
    mixin event!"MouseMotionEvent";
    mixin event!"MouseButtonEvent";
    mixin event!"JoyAxisEvent";
    mixin event!"JoyBallEvent";
    mixin event!"JoyHatEvent";    
    mixin event!"JoyButtonEvent";
    mixin event!"ResizeEvent";
    mixin event!"ExposeEvent";
    mixin event!"UserEvent";
    mixin event!"SysWMEvent";
    bool delegate() defaultdg;
    bool delegate(Event) evdg;
    
    void setDefault(typeof(defaultdg) dg) {
        defaultdg = dg;
    }
    
    void setSDL_EventHandler(typeof(evdg) dg) {
        evdg = dg;
    }
    
    void listen() {
        SDL_Event event;
        eventloop: while(true) {
            while(SDL_PollEvent(&event)) {
                switch(event.type) {
                    case SDL_QUIT: 
                        if(!dodg(handlerQuitEvent, event.quit)) break eventloop;
                        break; //switch statement
                    case SDL_ACTIVEEVENT: 
                        if(!dodg(handlerActiveEvent, event.active)) break eventloop;
                        break; //switch statemen
                    case SDL_KEYDOWN: case SDL_KEYUP: 
                        if(!dodg(handlerKeyboardEvent, event.key)) break eventloop;
                        break; //switch statement
                    case SDL_MOUSEMOTION: 
                        if(!dodg(handlerMouseMotionEvent, event.motion)) break eventloop;
                        break; //switch statement
                    case SDL_MOUSEBUTTONDOWN: case SDL_MOUSEBUTTONUP:
                        if(!dodg(handlerMouseButtonEvent, event.button)) break eventloop;
                        break; //switch statement
                    case SDL_JOYAXISMOTION: 
                        if(!dodg(handlerJoyAxisEvent, event.jaxis)) break eventloop;
                        break; //switch statement
                    case SDL_JOYBALLMOTION: 
                        if(!dodg(handlerJoyBallEvent, event.jball)) break eventloop;
                        break; //switch statement
                    case SDL_JOYHATMOTION: 
                        if(!dodg(handlerJoyHatEvent, event.jhat)) break eventloop;
                        break; //switch statement
                    case SDL_JOYBUTTONDOWN: case SDL_JOYBUTTONUP: 
                        if(!dodg(handlerJoyButtonEvent, event.jbutton)) break eventloop;
                        break; //switch statement
                    case SDL_VIDEOEXPOSE: 
                        if(!dodg(handlerExposeEvent, event.expose)) break eventloop;
                        break; //switch statement
                    case SDL_VIDEORESIZE: 
                        if(!dodg(handlerResizeEvent, event.resize)) break eventloop;
                        break; //switch statement
                    case SDL_USEREVENT: 
                        if(!dodg(handlerUserEvent, event.user)) break eventloop;
                        break; //switch statement
                    case SDL_SYSWMEVENT:
                        if(!dodg(handlerSysWMEvent, event.syswm)) break eventloop;
                        break; //switch statement
                    default: break; //ignore
                }
                if(!dodg(evdg, event)) break eventloop;
            }
            if(!dodg(defaultdg)) break eventloop;
        }
    }

    private mixin template event (string ev) {
        mixin("bool delegate(SDL_"~ev~") handler"~ev~";");
        mixin(
        "void setSDL_"~ev~"Handler(bool delegate(SDL_"~ev~") d)"~
        " in{assert(this.handler"~ev~"==null);}body{ this.handler"~ev~" = d; }");
    }
    
    private bool dodg(DG, P...)(DG dg, P p) {
        return  (dg != null) ? dg(p) : true;
    }
}

private enum Put : ubyte {
    BREAK_ON_QUIT = 0b_00_00_00_01
    //BREAK_ON_ESC
    //NO_LOOP
}
/**
 These constants can be used to give listen preimplemented functionalities.
 
 They can OR'ed together and can be used together with normal delegates.
 
 ----
 listen(BreakOnQuit);
 ----
 
 see_also: listen
 */
alias Put.BREAK_ON_QUIT BreakOnQuit;

//TODO template constraint
/**
 With this function you can listen for SDL's events using delegates.
 
 It has a std.concurrency.recieve()-like structure. It also allows for 
 listening for any event. All delegates have have to be bool delegates.
 This bool indicates if to stay in the event loop.
 ----
 listen( (KeyboardEvent){writeln("KeyboardEvent!"); return true;},
         (Event){ /+Do something on any Event after the possible
                    specialized handling.+/} );
 ---- 
 
 bugs: It has no template constraint yet.
 */
public void listen(T...)(T ts) {
    EventListener listener;
    //For each parameter...
    foreach(t; ts) {
        //if it's from Put enum...
        static if (is(typeof(t) == Put)) {
            //use predifend behaviour
            if (!! (t & Put.BREAK_ON_QUIT)) {
                listener.setSDL_QuitEventHandler( (QuitEvent ev){return false;} );
            }
        //hopefully a delegate
        } else {
            //what are the parameters of t
            alias ParameterTypeTuple!(t) PTT;   
            //if t is a bool delegate
            static if(is(ReturnType!t == bool)) {
                //t is our delegate to use
                alias t dg;
            //at a void delegate
            } else static if (is(ReturnType!t == void)){
                //a wrapper is our delegate
                auto wrapper = (PTT p){t(p); return true;};
                alias wrapper dg;
            } else {
                //otherwise something went wrong
                static assert(0);
            }
            //one parameter?
            static if(PTT.length == 1) {
                //put it into the eventlistener
                mixin("listener.set"~PTT[0].stringof~"Handler(dg);");
            } else static if(PTT.length == 0) {
                //without parameters it's the so called default delegate
                listener.setDefault(dg);
            } else {
                //otherwise something went wrong
                static assert(0);
            }
        }
    }
    listener.listen();
}

private mixin template aliasEvent(string ev) {
    mixin("alias SDL_"~ev~" "~ev~";");
}
