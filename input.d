module mysdl.input;

//make the key codes available to users of mysdl.input
public import mysdl.sdlapi_keys;
import mysdl.sdlapi;
import mysdl.system;

import std.typecons: Tuple, tuple;

/**
 The state of the mouse at some point in time
 */
struct MouseState {
    int x, ///Mouse's position
        y; ///ditto
    bool leftButton;   /// Is the corresponding button down?
    bool middleButton; /// ditto
    bool rightButton;  /// ditto
    //TODO more
}

/**
 Get the current mouse state.
*/
public MouseState getMouseState() {
    MouseState ms;
    int mask = SDL_GetMouseState(&ms.x, &ms.y);
    ms.leftButton = (mask & SDL_BUTTON(SDL_BUTTON_LEFT)) != 0;
    ms.rightButton = (mask & SDL_BUTTON(SDL_BUTTON_RIGHT)) != 0;
    ms.middleButton = (mask & SDL_BUTTON(SDL_BUTTON_MIDDLE)) != 0;
    return ms;
}

/**
 Get SDL's internal key state.
 
 This state will be kept up to date by the SDL.
 
 see_also: getKeyState
*/
public bool[] getInternalKeyState() {
    Uint8* keys = SDL_GetKeyState(null);
    assert(keys != null);
    return cast(bool[]) (keys[0.. SDLK_LAST]);
}

/**
 Get the current key state.
*/
public typeof(getInternalKeyState()) getKeyState() {
    return getInternalKeyState().dup;
}

/**
 This struct represents the a joystick.
 
 You can use this struct to query information about the joysticks connected
 to this computer. Don't forget to properly close it.
 
 Use countOfX where x is Axes, Balls, Buttons or Axes to get the count of 
 the corresponding input elements of this joytsick.
*/
public struct Joystick {
    private SDL_Joystick* joyptr = null;
    
    public static int getCount() {
        return SDL_NumJoysticks();
    }
    
    mixin count!"Axes";
    mixin count!"Balls";
    mixin count!"Buttons";
    mixin count!"Hats";
    /+
    public this(SDL_Joystick* somePtr) {
        this.joyptr = somePtr;
    }+/
    
    public this(int index) 
    in { 
        assert(index >= 0);
        assert(index < Joystick.getCount());
    } body {
        //this(SDL_JoystickOpen(index));
        joyptr = SDL_JoystickOpen(index);
    }
    
    public short getAxis(int no) 
    in {
        assert(no >= 0);
        assert(no < countOfAxes);
    } body {
        return SDL_JoystickGetAxis(joyptr, no);
    }
    
    public short getButton(int no) 
    in {
        assert(no >= 0);
        assert(no < countOfButtons);
    } body {
        return cast(bool) SDL_JoystickGetButton(joyptr, no);
    }  
    
    public short getHat(int no) 
    in {
        assert(no >= 0);
        assert(no < countOfHats);
    } body {
        return SDL_JoystickGetHat(joyptr, no);
    } 

    public Tuple!(int,int) getBall(int no) {
        int x, y;
        if(SDL_JoystickGetBall(joyptr, no, &x, &y) == -1) {
            throw new SDLException();
        }
        return tuple(x,y);
    }

    public void enable() {
        SDL_JoystickEventState(SDL_ENABLE);
    }
    
    public void close() {
        SDL_JoystickClose(joyptr);
        joyptr = null;
    }
    
    mixin template count(string name) {
        mixin(`
            @property
            public int countOf`~name~`() {
                return SDL_JoystickNum`~name~`(this.joyptr);
            }
        `);
    }
}