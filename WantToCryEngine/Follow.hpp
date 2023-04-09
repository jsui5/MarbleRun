//
//  ComponentFollow.hpp
//  WantToCryEngine
//
//  Created by Mark on 2023-04-08.
//

#ifndef ComponentFollow_hpp
#define ComponentFollow_hpp

#include <stdio.h>

#include "Component.hpp"

class Follow : public Component{
public:
    Transform following;
    GLKVector3 posOffset;
    ~Follow() = default;
    void update(float deltaTime);
    bool otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing);
    Follow(GameObject& p, Transform& f) : Follow(p, f, GLKVector3{0, 0, 0}){};
    Follow(GameObject& p, Transform& f, GLKVector3 offsetPos) : Component(p), following(f), posOffset(offsetPos){};
};

#endif /* ComponentFollow_hpp */
