//
//  ObjectNotifier.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-26.
//

#ifndef ObjectNotifier_hpp
#define ObjectNotifier_hpp

#include <stdio.h>
#include "Component.hpp"

class ObjectNotifier : public Component{
public:
    std::string proclamation;
    ~ObjectNotifier();
    void update(float deltaTime);
    bool otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing);
    ObjectNotifier(GameObject& p, std::string talk);
};

#endif /* ObjectNotifier_hpp */
