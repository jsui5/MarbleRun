//
//  PlayerPositionLimiter.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-04-08.
//

#include "PositionLimiter.hpp"

bool PositionLimiter::otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing){
    for(std::shared_ptr<Component> i : existing){
        if(typeid(*(i.get())) == typeid(PositionLimiter)){
            return true; //can only have one per object
        }
    }
    return false;;
}

void PositionLimiter::update(float deltaTime){
    Transform& t = parent.transform;
    
    if(constrainX){
        if(t.position.x < xMin){
            t.position.x = xMin;
            t.linVelocity.x = 0;
            if(t.linVelocity.x < 0){
                t.linVelocity.x = 0;
            }
        }
        if(t.position.x > xMax){
            t.position.x = xMax;
            t.linVelocity.x = 0;
            if(t.linVelocity.x > 0){
                t.linVelocity.x = 0;
            }
        }
    }
    if(constrainY){
        if(t.position.y > yMax){
            t.position.y = yMax;
            t.linVelocity.y = 0;
            if(t.linVelocity.y > 0){
                t.linVelocity.y = 0;
            }
        }
        if(t.position.y < yMin){
            t.position.y = yMin;
            if(t.linVelocity.y < 0){
                t.linVelocity.y = 0;
            }
        }
    }
    if(constrainZ){
        if(t.position.z < zMin){
            t.position.z = zMin;
            t.linVelocity.z = 0;
            if(t.linVelocity.z < 0){
                t.linVelocity.z = 0;
            }
        }
        if(t.position.z > zMax){
            t.position.z = zMax;
            t.linVelocity.z = 0;
            if(t.linVelocity.z > 0){
                t.linVelocity.z = 0;
            }
        }
    }
}
