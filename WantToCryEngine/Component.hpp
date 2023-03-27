//
//  Component.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-21.
//

#ifndef Component_hpp
#define Component_hpp

#include <stdio.h>
#include "Common.h"

class GameObject;

class Component{
protected:
    GameObject& parent;
public:
//    Component(const Component& copy);
    Component(GameObject& p) : parent(p){};
    virtual ~Component() = 0;
    virtual void update(float deltaTime) = 0;
    //Should return true if there's a problem and it should NOT be added to a gameobject
    //that already has the existing components.
    virtual bool otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing) = 0;
};

#endif /* Component_hpp */
