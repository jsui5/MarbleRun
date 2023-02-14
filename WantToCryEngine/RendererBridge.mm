//
//  RendererBridge.m
//  WantToCryEngine
//
//  Created by Alex on 2023-02-12.
//

#import <Foundation/Foundation.h>
#include "RendererBridge.h"
#include "Renderer.hpp"

extern "C" Renderer* NewRenderer(){
    return new Renderer();
}

extern "C" void DeleteRenderer(Renderer* inThis){
    delete inThis;
}

extern "C" void RendererSetup(Renderer* inThis, GLKView* view){
    inThis->setup(view);
}

extern "C" void RendererUpdate(Renderer* inThis){
    inThis->update();
}

extern "C" void RendererLoadModel(Renderer* inThis, NSString* path, NSString* refName){
    inThis->loadModel(path.UTF8String, refName.UTF8String);
}

/*
extern "C" GameObject* RendererCreateGameObject(struct Renderer* inThis, NSString* modelRef,
                                                GLKVector3 pos, GLKVector3 rot,
                                                GLKVector3 scale, GLKVector4 color){
    return &inThis->createGameObject(modelRef.UTF8String, pos, rot, scale, color);
}
*/

/*
extern "C" void RendererDrawModel(Renderer* inThis, NSString* refName, CGRect drawArea){
    inThis->drawModel(refName.UTF8String, GLKVector3{0, 0, 0}, GLKVector3{0, 0, 0}, &drawArea);
}
*/

extern "C" void RendererDrawModel(Renderer* inThis, NSString* refName,
                                  float xPos, float yPos, float zPos,
                                  float xRot, float yRot, float zRot,
                                  CGRect drawArea){
    inThis->drawModel(refName.UTF8String, GLKVector3{xPos, yPos, zPos},
                      GLKVector3{xRot, yRot, zRot}, &drawArea);
}

/*
extern "C" void RendererDrawObjects(Renderer* inThis, CGRect drawArea){
    inThis->drawGameObjects(&drawArea);
}
*/

extern "C" void GameObjectSetPos(struct GameObject* inThis, GLKVector3 newPos){
    inThis->transform.position = newPos;
}

extern "C" GLKVector3 GameObjectGetPos(struct GameObject* inThis){
    return inThis->transform.position;
}

extern "C" void GameObjectSetRot(struct GameObject* inThis, GLKVector3 newRot){
    inThis->transform.rotation = newRot;
}

extern "C" GLKVector3 GameObjectGetRot(struct GameObject* inThis){
    return inThis->transform.rotation;
}
