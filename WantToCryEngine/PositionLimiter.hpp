//
//  PlayerPositionLimiter.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-04-08.
//

#ifndef PlayerPositionLimiter_hpp
#define PlayerPositionLimiter_hpp

#include <stdio.h>

#include "Component.hpp"

class PositionLimiter : public Component{
public:
    bool constrainX;
    bool constrainY;
    bool constrainZ;
    float xMin;
    float yMin;
    float zMin;
    float xMax;
    float yMax;
    float zMax;
    ~PositionLimiter() = default;
    void update(float deltaTime);
    bool otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing);
    PositionLimiter(GameObject& p) : PositionLimiter(p, false, false, false, 0, 0, 0, 0, 0, 0){};
    PositionLimiter(GameObject& p, bool actX, bool actY, bool actZ, float xMinVal, float yMinVal, float zMinVal, float xMaxVal, float yMaxVal, float zMaxVal) : Component(p), constrainX(actX), constrainY(actY), constrainZ(actZ), xMin(xMinVal), yMin(yMinVal), zMin(zMinVal), xMax(xMaxVal), yMax(yMaxVal), zMax(zMaxVal){};
};

#endif /* PlayerPositionLimiter_hpp */
