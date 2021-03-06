module mafisdl.input;

import mafisdl.system;

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
MouseState getMouseState() {
    MouseState ms;
    int mask = SDL_GetMouseState(&ms.x, &ms.y);
    ms.leftButton = (mask & SDL_BUTTON(SDL_BUTTON_LEFT)) != 0;
    ms.rightButton = (mask & SDL_BUTTON(SDL_BUTTON_RIGHT)) != 0;
    ms.middleButton = (mask & SDL_BUTTON(SDL_BUTTON_MIDDLE)) != 0;
    return ms;
}

/**
 Get state of the keyboard.

 This state will be kept up to date by the SDL.

*/
bool[] getKeyboardState() {
    int numKeys;
    auto state = cast(bool*) SDL_GetKeyboardState(&numKeys);
    return state[0 .. numKeys];
}


/**
 This struct represents a joystick.

 You can use this struct to query information about the joysticks connected
 to this computer. Don't forget to properly close it.

 Use countOfX where x is Axes, Balls, Buttons or Axes to get the count of
 the corresponding input elements of this joytsick.
*/
struct Joystick {
    private SDL_Joystick* joyptr = null;

    static int getCount() {
        return SDL_NumJoysticks();
    }

    mixin count!"Axes";
    mixin count!"Balls";
    mixin count!"Buttons";
    mixin count!"Hats";

    //strange linker error with this uncommented
    /+
    this(SDL_Joystick* somePtr) {
        this.joyptr = somePtr;
    }+/

    ///open a new joystick connection for the given index
    this(int index)
    in {
        assert(index >= 0);
        assert(index < Joystick.getCount());
    } body {
        //this(SDL_JoystickOpen(index));
        joyptr = SDL_JoystickOpen(index);
    }

    ///Get the state of the given axis
    short getAxis(int no)
    in {
        assert(no >= 0);
        assert(no < countOfAxes);
    } body {
        return SDL_JoystickGetAxis(joyptr, no);
    }

    ///Get the state of the given button
    short getButton(int no)
    in {
        assert(no >= 0);
        assert(no < countOfButtons);
    } body {
        return cast(bool) SDL_JoystickGetButton(joyptr, no);
    }

    ///Get the state of the given hat
    short getHat(int no)
    in {
        assert(no >= 0);
        assert(no < countOfHats);
    } body {
        return SDL_JoystickGetHat(joyptr, no);
    }

    ///Get the state of the given ball
    Tuple!(int,int) getBall(int no) {
        int x, y;
        if(SDL_JoystickGetBall(joyptr, no, &x, &y) == -1) {
            throw new SDLException();
        }
        return tuple(x,y);
    }

    void enable() {
        SDL_JoystickEventState(SDL_ENABLE);
    }

    ///Close
    void close() {
        SDL_JoystickClose(joyptr);
        joyptr = null;
    }

    mixin template count(string name) {
        mixin(`
            @property
            int countOf`~name~`() {
                return SDL_JoystickNum`~name~`(this.joyptr);
            }
        `);
    }
}
