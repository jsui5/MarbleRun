//
//  Component.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-21.
//

#include "Component.hpp"
#include "GameObject.hpp"

//Component::Component(const Component& copy) : parent(copy.parent){
//
//}

Component::~Component(){

}

Transform& Component::getParentTransform(){
    return parent.transform;
}
