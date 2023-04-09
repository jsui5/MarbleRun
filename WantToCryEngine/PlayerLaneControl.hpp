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
    int lane;
    int laneMin;
    int laneMax;
    ~PlayerLaneControl() = default;
    void changeBy(int num);
    void update(float deltaTime);
    bool otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing);
    PlayerLaneControl(GameObject& p, int defaultLane, int min, int max) : Component(p), lane(defaultLane), laneMin(min), laneMax(max) {};
};

#endif /* ComponentPlayerLaneControl_hpp */
