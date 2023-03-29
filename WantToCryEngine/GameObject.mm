//
//  GameObject.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-11.
//

#include "GameObject.hpp"

GameObject::GameObject(GLKVector3 pos, GLKVector3 rot, GLKVector3 scale):
    transform(pos, rot, scale), color{1, 1, 1, 1}{
        components = std::vector<std::shared_ptr<Component>>();
}

void GameObject::update(float deltaTime){
    for(int i = 0; i < components.size(); ++i){
        components[i]->update(deltaTime);
    }
}

Component* GameObject::addComponent(std::shared_ptr<Component> c){
    if(c->otherComponentInteractionCheck(components)){
        return nullptr;
    } else {
        components.push_back(std::move(c));
        return components.back().get();
    }
}


void GameObject::removeComponent(Component* victim){
    for(auto i = components.begin(); i < components.end(); ++i){
        if((*i).get() == victim){
            std::cout << "Erasing component at " << *i << std::endl;
            components.erase(i);
            components.shrink_to_fit();
            return;
        }
    }
}
