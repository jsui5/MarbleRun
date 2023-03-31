//
//  SimulatedBody.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-29.
//

#ifndef SimulatedBody_hpp
#define SimulatedBody_hpp

#include <stdio.h>

#include "Component.hpp"

class SimulatedBody : public Component{
private:
    void applyVelocity(float deltaTime);
    void applyGravity(float deltaTime);
public:
    inline static float gravAcceleration = 9.81;
    ~SimulatedBody();
    void update(float deltaTime);
    bool otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing);
    SimulatedBody(GameObject& p) : Component(p){};
};

#endif /* SimulatedBody_hpp */
