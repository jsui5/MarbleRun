//
//  ComponentSpinner.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-26.
//

#include "Spinner.hpp"

bool Spinner::otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing){
    return false;
}

void Spinner::update(float deltaTime){
    if(deltaTime == -1){
        parent.transform.rotation.x += rotRate.x;
        parent.transform.rotation.y += rotRate.y;
        parent.transform.rotation.z += rotRate.z;
    } else {
        parent.transform.rotation.x += rotRate.x * deltaTime;
        parent.transform.rotation.y += rotRate.y * deltaTime;
        parent.transform.rotation.z += rotRate.z * deltaTime;
    }
}
