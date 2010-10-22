module mysdl.events;

import mysdl.sdlapi;

import std.traits;

alias SDL_KEYDOWN KEYDOWN;
alias SDL_KEYUP   KEYUP;
alias SDL_MOUSEBUTTONDOWN MOUSEDOWN;
alias SDL_MOUSEBUTTONUP   MOUSEUP;

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

//TODO alias SDL_*Event s

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
    //TODO more Events
    
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
                    //TODO more, more !!!!!!!!!
                    default: break; //ignore
                }
                if(!dodg(evdg, event)) break eventloop;
            }
            if(!dodg(defaultdg)) break eventloop;
        }
    }

    private mixin template event (string ev) {
        mixin("bool delegate(SDL_"~ev~") handler"~ev~";");
        mixin("void setSDL_"~ev~"Handler(bool delegate(SDL_"~ev~") d) { this.handler"~ev~" = d; }");
    }
    
    private bool dodg(DG, P...)(DG dg, P p) {
        return  (dg != null) ? dg(p) : true;
    }
}

/**/
public enum Put : ubyte {
    BREAK_ON_QUIT = 0b_00_00_00_01
    //BREAK_ON_ESC
    //NO_LOOP
}

//TODO template constraint
public void listen(T...)(T ts) {
    EventListener listener;
    foreach(t; ts) {
        static if (is(typeof(t) == Put)) {
            if (!! (t & Put.BREAK_ON_QUIT)) {
                listener.setSDL_QuitEventHandler( (QuitEvent){return false;} );
            }
        } else {
            alias ParameterTypeTuple!(t) PTT;
            static if(PTT.length == 1) {
                mixin("listener.set"~PTT[0].stringof~"Handler(t);");
            } else static if(PTT.length == 0) {
                listener.setDefault(t);
            } else {
                static assert(0);
            }
        }
    }
    listener.listen();
}

private mixin template aliasEvent(string ev) {
    mixin("alias SDL_"~ev~" "~ev~";");
}