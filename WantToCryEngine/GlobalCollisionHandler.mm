//
//  GlobalCollisionHandler.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-29.
//

#include "GlobalCollisionHandler.hpp"
#include "BoundingBoxCollision.hpp"

GlobalCollisionHandler& GlobalCollisionHandler::getInstance(){
    static GlobalCollisionHandler instance; //this should stay the same between calls
    return instance;
}

GLuint GlobalCollisionHandler::addCollider(std::shared_ptr<BoundingBoxCollision> addition){
    for(auto i : targets){
        if(i.second == addition){
            return 0;
        }
    }
    targets[next] = addition;
    next++;
    return next - 1;
}


void GlobalCollisionHandler::removeCollider(GLuint victim){
    targets.erase(victim);
}

GLKVector3 GlobalCollisionHandler::getBlockageOffset(GLuint collider){
    
    GLKVector3 blockageOffset = GLKVector3{0,0,0};
    
    std::shared_ptr<BoundingBoxCollision> a = targets[collider];
    for(auto j : targets){
        std::shared_ptr<BoundingBoxCollision> b = j.second;
        if(a != b){
            if((a.get())->blocking && b.get()->blocking){
                auto& transformA = a.get()->getParentTransform();
                auto& transformB = b.get()->getParentTransform();
                GLKVector3 extentsA = a.get()->halfExtents;
                GLKVector3 extentsB = b.get()->halfExtents;
                
                float encroachX = 0.0f, encroachY = 0.0f, encroachZ = 0.0f;
                
                if(
                   transformA.position.x - abs(extentsA.x) <= transformB.position.x + abs(extentsB.x) &&
                   transformA.position.x + abs(extentsA.x) >= transformB.position.x - abs(extentsB.x) &&
                   transformA.position.y - abs(extentsA.y) <= transformB.position.y + abs(extentsB.y) &&
                   transformA.position.y + abs(extentsA.y) >= transformB.position.y - abs(extentsB.y) &&
                   transformA.position.z - abs(extentsA.z) <= transformB.position.z + abs(extentsB.z) &&
                   transformA.position.z + abs(extentsA.z) >= transformB.position.z - abs(extentsB.z)
                   ){
                       if(transformA.linVelocity.x > 0){
                           encroachX = (transformB.position.x - abs(extentsB.x)) -
                           (transformA.position.x + abs(extentsA.x));
                       } else if (transformA.linVelocity.x < 0){
                           encroachX = (transformA.position.x - abs(extentsA.x)) -
                           (transformB.position.x + abs(extentsB.x));
                       }
                       if(transformA.linVelocity.y > 0){
                           encroachY = (transformB.position.y - abs(extentsB.y)) -
                           (transformA.position.y + abs(extentsA.y));
                       } else if (transformA.linVelocity.y < 0){
                           encroachY = (transformA.position.y - abs(extentsA.y)) -
                           (transformB.position.y + abs(extentsB.y));
                       }
                       if(transformA.linVelocity.z > 0){
                           encroachZ = (transformB.position.z - abs(extentsB.z)) -
                           (transformA.position.z + abs(extentsA.z));
                       } else if (transformA.linVelocity.z < 0){
                           encroachZ = (transformA.position.z - abs(extentsA.z)) -
                           (transformB.position.z + abs(extentsB.z));
                       }
                       
                       if(abs(encroachY) != 0 && (abs(encroachY) < abs(encroachX) || encroachX == 0) && (abs(encroachY) < abs(encroachZ) || encroachZ == 0)){
                           encroachX = 0;
                           encroachZ = 0;
                       } else if(abs(encroachX) != 0 && (abs(encroachX) < abs(encroachY) || encroachY == 0) && (abs(encroachX) < abs(encroachZ) || encroachZ == 0)){
                           encroachY = 0;
                           encroachZ = 0;
                       } else {
                           encroachX = 0;
                           encroachY = 0;
                       }
                   }
                
                blockageOffset = GLKVector3{blockageOffset.x -encroachX, blockageOffset.y -encroachY,blockageOffset.z -encroachZ};
            }
        }
    }

    
    return blockageOffset;
}
