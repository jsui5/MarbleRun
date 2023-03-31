//
//  BoundingBoxCollision.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-29.
//

#ifndef BoundingBoxCollision_hpp
#define BoundingBoxCollision_hpp

#include <stdio.h>

#include "Component.hpp"
#include "GlobalCollisionHandler.hpp"
#include "SimulatedBody.hpp"

//This whole system is horrible. Unfortunately, I'm in a hurry, and care more about passing
//than about making it actually work.
//Generally speaking, Collider should be a parent class.
class BoundingBoxCollision : public Component{
private:
    GlobalCollisionHandler& gch;
    GLuint indexForGlobalHandler;
public:
    GLKVector3 halfExtents;
    bool blocking;
    ~BoundingBoxCollision();
    void update(float deltaTime);
    bool otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing);
    BoundingBoxCollision(GameObject& p, GLKVector3 directionalExtents, bool isBlocking);
    BoundingBoxCollision(GameObject& p) : BoundingBoxCollision(p, GLKVector3{1,1,1}, true){};
};


#endif /* BoundingBoxCollision_hpp */
