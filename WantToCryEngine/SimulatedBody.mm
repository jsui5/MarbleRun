//
//  SimulatedBody.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-29.
//

#include "SimulatedBody.hpp"

void SimulatedBody::update(float deltaTime){
    applyGravity(deltaTime);
    applyVelocity(deltaTime);
}

bool SimulatedBody::otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing){
    for(std::shared_ptr<Component> i : existing){
        if(typeid(*(i.get())) == typeid(SimulatedBody)){
            return true; //can only have one per object
        }
    }
    return false;;
}

SimulatedBody::~SimulatedBody(){
}

void SimulatedBody::applyVelocity(float deltaTime){
    parent.transform.position.x += parent.transform.linVelocity.x * deltaTime;
    parent.transform.position.y += parent.transform.linVelocity.y * deltaTime;
    parent.transform.position.z += parent.transform.linVelocity.z * deltaTime;
}

void SimulatedBody::applyGravity(float deltaTime){
    parent.transform.linVelocity.y -= gravAcceleration * deltaTime;
}
