//
//  ComponentFollow.cpp
//  WantToCryEngine
//
//  Created by Mark on 2024-04-08.
//

#include "Follow.hpp"

bool Follow::otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing){
    return false;
}

void Follow::update(float deltaTime){
    parent.transform.position =
        GLKVector3{following.position.x + posOffset.x, following.position.y + posOffset.y, following.position.z + posOffset.z};
}
