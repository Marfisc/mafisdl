module mysdl.events;

import mysdl.sdlapi;

import std.traits;

alias SDL_KEYDOWN KeyDown;
alias SDL_KEYUP   KeyUp;
alias SDL_MOUSEBUTTONDOWN MouseDown;
alias SDL_MOUSEBUTTONUP   MouseUP;
alias SDL_JOYBUTTONDOWN  JoyButtonDown;
alias SDL_JOYBUTTONUP    JoyButtonUp;

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
                listener.setSDL_QuitEventHandler( (QuitEvent){return false;} );
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