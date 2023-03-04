#  WantToCryEngine
## Version 0.4 - iOS + OpenGL ES

This is a work in progress project. If you got it from somewhere else, there's
probably a newer version at https://github.com/OrbitalMechanist/WantToCryEngine

Game.cpp is where you should program the game itself.
Swift just initializes the whole thing and passes in input events.
Use GameBridge to call Game event functions from Swift.

My priority for now is filling the basic requirements for a course. Once that's
done, I'll try to optimize and refactor some things, such as better encapsulation.

Coming Soon<sup>TM</sup>:
- Refactoring
- Optimization
- Implementing a physics library.
- Unity-style Behaviour system for gameobjects.
- Properly decoupling geometry from gameobjects.

Out of scope:
- Materials
- Multiplayer

Textures are using texture image units for now, and probably forever.
Arrays aren't really worth the hassle of having to have all the textures
be the same size for the purposes of this project.
Maybe I'll optimize things a little if I can get around to it, but for now
the priority is filling the basic requirements.

Ease of use was very important when developing this engine. Some stuff is
less efficient than it could be right now because I want an inexperienced
user to make the final game without too much trouble.

P.S. "Alex" is the username on a Mac I had to borrow to work on this.
