//
//  ComponentSpinner.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-26.
//

#ifndef ComponentSpinner_hpp
#define ComponentSpinner_hpp

#include <stdio.h>

#include "Component.hpp"

class Spinner : public Component{
public:
    GLKVector3 rotRate;
    ~Spinner() = default;
    void update(float deltaTime);
    bool otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing);
    Spinner(GameObject& p) : Spinner(p, GLKVector3{0, 0, 0}){};
    Spinner(GameObject& p, GLKVector3 rates) : Component(p), rotRate(rates){};
};

#endif /* ComponentSpinner_hpp */
