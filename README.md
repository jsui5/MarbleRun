#  WantToCryEngine
## Version 0.2 - iOS + OpenGL ES

Game.cpp is where you should program the game itself.
Swift just initializes the whole thing and passes in input events.

Coming Soon<sup>TM</sup>:
- Actual Lights
- Fog
- Unity-style Behaviour system for gameobjects.
- Properly decoupling geometry from gameobjects.
- Refactoring

Textures are using texture image units for now, and probably forever.
Arrays aren't really worth the hassle of having to have all the textures
be the same size for the purposes of this project.
Maybe I'll optimize things a little if I can get around to it, but for now
the priority is filling the basic requirements.

Ease of use was very important when developing this engine. A some stuff is
less efficient than it could be right now because I want an inexperienced
user to make the final game without too much trouble.

P.S. "Alex" is the username on a Mac I had to borrow to work on this.
