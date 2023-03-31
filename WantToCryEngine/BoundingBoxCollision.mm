//
//  BoundingBoxCollision.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-29.
//

#include "BoundingBoxCollision.hpp"

BoundingBoxCollision::BoundingBoxCollision(GameObject& p, GLKVector3 directionalExtents, bool isBlocking) :
Component(p), halfExtents(directionalExtents), blocking(isBlocking), gch(GlobalCollisionHandler::getInstance()){
    indexForGlobalHandler = gch.addCollider(std::make_shared<BoundingBoxCollision>(*this));
}

BoundingBoxCollision::~BoundingBoxCollision(){
    gch.removeCollider(indexForGlobalHandler);
}

void BoundingBoxCollision::update(float deltaTime){
    GLKVector3 offset = gch.getBlockageOffset(indexForGlobalHandler);
            
    if(parent.getComponent<SimulatedBody>() != nullptr){
        if(offset.x != 0){
            parent.transform.position.x += offset.x;
            parent.transform.linVelocity.x = 0;
        }
        if(offset.y != 0){
            parent.transform.position.y += offset.y;
            parent.transform.linVelocity.y =0;//+= deltaTime * SimulatedBody::gravAcceleration;
        }
        if(offset.z != 0){
            parent.transform.position.z += offset.z;
            parent.transform.linVelocity.z = 0;
        }
    }
}

bool BoundingBoxCollision::otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing){
    return false;
}
