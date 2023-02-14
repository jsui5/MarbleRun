//
//  GameObject.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-11.
//

#ifndef GameObject_hpp
#define GameObject_hpp

#include <OpenGLES/ES3/gl.h>
#include <GLKit/GLKit.h>
#include "WavefrontLoader.hpp"

struct Transform{
    GLKVector3 position;
    GLKVector3 rotation;
    GLKVector3 scale;
    Transform(){
        position = GLKVector3{0, 0, 0};
        rotation = GLKVector3{0, 0, 0};
        scale = GLKVector3{1, 1, 1};
    }
    Transform(GLKVector3 pos, GLKVector3 rot, GLKVector3 scl):
        position(pos), rotation(rot), scale(scl){}
};

class GameObject{
public:
    Transform transform;
    GeometryObject geometry;
    GLKVector4 color;
    GameObject():transform(), color{1, 1, 1, 1}{}
    GameObject(GLKVector3 pos, GLKVector3 rot, GLKVector3 scale):
        transform(pos, rot, scale), color{1, 1, 1, 1}{}
};

#endif /* GameObject_hpp */
