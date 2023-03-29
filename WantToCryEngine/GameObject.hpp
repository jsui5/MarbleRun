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
#include "PreloadedGeometryObject.hpp"
#include "Utility.hpp"
#include "Common.h"

struct Transform{
    GLKVector3 position;
    GLKVector3 rotation;
    GLKVector3 scale;
    GLKVector3 linVelocity;
    Transform() : Transform(GLKVector3{0,0,0}, GLKVector3{0,0,0},GLKVector3{1,1,1}){}
    Transform(GLKVector3 pos, GLKVector3 rot, GLKVector3 scl):
        position(pos), rotation(rot), scale(scl),
        linVelocity(GLKVector3{0,0,0}){}
};

class Component;

class GameObject{
private:
    //The use of C++ pointer wrappers makes it easy to free memory when needed.
    //Theoretically, removing all references to these pointers destroys the object.
    //Testing with destructors seems to confirm that.
    std::vector<std::shared_ptr<Component>> components;
public:
    Transform transform;
    GeometryObject geometry;
    GLKVector4 color;
    GameObject(): GameObject(GLKVector3{0, 0, 0}, GLKVector3{0,0,0}, GLKVector3{1,1,1}){}
    GameObject(GLKVector3 pos, GLKVector3 rot, GLKVector3 scale);
    GLuint textureIndex;
    PreloadedGeometryObject preloadedGeometry;
    
    void update(float deltaTime);
    
    Component* addComponent(std::shared_ptr<Component> c);
        
    //Apparently you can't implement template functions outside of the header file.
    
    template<typename T = Component>
    std::vector<Component*> getComponentsOfType(){
        static_assert(std::is_base_of<Component, T>::value, "type must be a child of Component");
        std::vector<Component*> result = std::vector<Component*>();
        for(auto& i : components){
            if(dynamic_cast<T*>(i.get())){
                result.push_back(i.get());
            }
        }
        return result;
    }
    
    template<typename T = Component>
    Component* getComponent(){
        static_assert(std::is_base_of<Component, T>::value, "type must be a child of Component");
        for(auto& i : components){
            if(dynamic_cast<T*>(i.get())){
                return i.get();
            }
        }
        return nullptr;
    }
    
    void removeComponent(Component* victim);
};


#endif /* GameObject_hpp */
