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

//TODO alias SDL_*Event s

private struct EventListener {
    mixin event!"QuitEvent";
    mixin event!"KeyboardEvent";
    mixin event!"MouseMotionEvent";
    mixin event!"MouseButtonEvent";
    mixin event!"JoyButtonEvent";
    mixin event!"JoyAxisEvent";
    bool delegate() defaultdg;
    //TODO more Events
    
    void setDefault(typeof(defaultdg) dg) {
        defaultdg = dg;
    }
    
    void listen() {
        SDL_Event event;
        eventloop: while(true) {
            while(SDL_PollEvent(&event)) {
                switch(event.type) {
                    case SDL_QUIT: 
                        if(!dodg(handlerQuitEvent, event.quit)) break eventloop;
                        break; //switch statement
                    case SDL_KEYDOWN: case SDL_KEYUP: 
                        if(!dodg(handlerKeyboardEvent, event.key)) break eventloop;
                        break; //switch statement
                    case SDL_MOUSEMOTION: 
                        if(!dodg(handlerMouseMotionEvent, event.motion)) break eventloop;
                        break; //switch statement
                    case SDL_MOUSEBUTTONDOWN: case SDL_MOUSEBUTTONUP:
                        if(!dodg(handlerMouseButtonEvent, event.button)) break eventloop;
                        break; //switch statement
                    //TODO more, more !!!!!!!!!
                    default: break; //ignore
                }
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

//TODO template constraint
public void listen(T...)(T ts) {
    EventListener listener;
    foreach(t; ts) {
        alias ParameterTypeTuple!(t) PTT;
        static if(PTT.length == 1) {
            mixin("listener.set"~PTT[0].stringof~"Handler(t);");
        } else static if(PTT.length == 0) {
            listener.setDefault(t);
        } else {
            static assert(0);
        }
    }
    listener.listen();
}

public mixin template aliasEvent(string ev) {
    mixin("alias SDL_"~ev~" "~ev~";");
}