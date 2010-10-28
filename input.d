module mysdl.input;

//make the key codes available to users of mysdl.input
public import mysdl.sdlapi_keys;
import mysdl.sdlapi;

/**
 The state of the mouse at some point in time
 */
struct MouseState {
    int x,y; ///Mouse's position
    bool leftButton;
    bool middleButton;   
    bool rightButton;
    //TODO more
}

public MouseState getMouseState() {
    MouseState ms;
    int mask = SDL_GetMouseState(&ms.x, &ms.y);
    ms.leftButton = (mask & SDL_BUTTON(SDL_BUTTON_LEFT)) == 0;
    ms.rightButton = (mask & SDL_BUTTON(SDL_BUTTON_RIGHT)) == 0;
    ms.middleButton = (mask & SDL_BUTTON(SDL_BUTTON_MIDDLE)) == 0;
    return ms;
}

public bool[] getInternalKeyState() {
    Uint8* keys = SDL_GetKeyState(null);
    assert(keys != null);
    return cast(bool[]) (keys[0.. SDLK_LAST]);
}

public typeof(getInternalKeyState()) getKeyState() {
    return getInternalKeyState().dup;
}

//TODO Joystick