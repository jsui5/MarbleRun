//
//  ComponentPlayerLaneControl.hpp
//  WantToCryEngine
//
//  Created by Mark on 2023-04-08.
//

#ifndef ComponentPlayerLaneControl_hpp
#define ComponentPlayerLaneControl_hpp

#include <stdio.h>

#include "Component.hpp"

class PlayerLaneControl : public Component{
public:
    float lane;
    float laneMin;
    float laneMax;
    float changeMult;
    ~PlayerLaneControl() = default;
    void changeBy(float num);
    void update(float deltaTime);
    bool otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing);
    PlayerLaneControl(GameObject& p, float defaultLane, float min, float max, float rate) : Component(p), lane(defaultLane), laneMin(min), laneMax(max), changeMult(rate) {};
};

#endif /* ComponentPlayerLaneControl_hpp */
