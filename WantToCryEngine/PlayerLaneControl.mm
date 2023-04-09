//
//  ComponentPlayerLaneControl.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-26.
//

#include "PlayerLaneControl.hpp"
#include <cmath>

bool PlayerLaneControl::otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing){
    return false;
}

void PlayerLaneControl::update(float deltaTime){
    parent.transform.position = GLKVector3{(float)lane, parent.transform.position.y, parent.transform.position.z};
}

void PlayerLaneControl::changeBy(int num) {
    lane += num;
    //printf("Attempt: %i\n", lane);
    if (lane > laneMax)
        lane = laneMax;
    if (lane < laneMin)
        lane = laneMin;
    //printf("Set: %i\n", lane);
    
}
