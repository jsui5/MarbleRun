//
//  GlobalCollisionHandler.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-29.
//

#ifndef GlobalCollisionHandler_hpp
#define GlobalCollisionHandler_hpp

#include <stdio.h>
#include "Common.h"

class BoundingBoxCollision;

//This is a singleton btw.
class GlobalCollisionHandler{
public:
    static GlobalCollisionHandler& getInstance();
    
    //This prevents initialization of new instances through various ways of copying the real one
    GlobalCollisionHandler(const GlobalCollisionHandler& copy) = delete;
    void operator=(const GlobalCollisionHandler& rhs) = delete;
    
    GLuint addCollider(std::shared_ptr<BoundingBoxCollision> addition);

    GLKVector3 getBlockageOffset(GLuint collider);
    
    void removeCollider(GLuint victim);

private:
    GLuint next = 1;
    GlobalCollisionHandler(){};
    std::map<GLuint, std::shared_ptr<BoundingBoxCollision>> targets;
};

#endif /* GlobalCollisionHandler_hpp */
