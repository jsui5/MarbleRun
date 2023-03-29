//
//  ObjectNotifier.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-26.
//

#include "ObjectNotifier.hpp"


bool ObjectNotifier::otherComponentInteractionCheck(const std::vector<std::shared_ptr<Component>>& existing){
    return false;
}


void ObjectNotifier::update(float deltaTime){
    std::cout << "Updated with dt = " << deltaTime << " position is {" << parent.transform.position.x << "," << parent.transform.position.y << "," << parent.transform.position.z << "} " << " velocity is {" << parent.transform.linVelocity.x << "," << parent.transform.linVelocity.y << "," << parent.transform.linVelocity.z << "} " << proclamation << std::endl;
}

ObjectNotifier::ObjectNotifier(GameObject& p, std::string talk) : Component(p),
proclamation(talk){
    std::cout << "Created new ObjectNotifier with proclamation " << proclamation << std::endl;
}

ObjectNotifier::~ObjectNotifier(){
    std::cout << "Deleted an ObjectNotifier" << std::endl;
}
