//
//  RendererBridge.h
//  WantToCryEngine
//
//  Created by Alex on 2023-02-12.
//
#ifndef RendererBridge_h
#define RendererBridge_h

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

//This is an old bridge left mainly for posterity. DO NOT USE. YOU DON'T NEED IT!

struct Renderer;
struct GameObject;

#ifdef __cplusplus
extern "C"
{
#endif
struct Renderer* NewRenderer();
void DeleteRenderer(struct Renderer* inThis);
void RendererSetup(struct Renderer* inThis, GLKView* view);
void RendererUpdate(struct Renderer* inThis);
void RendererLoadModel(struct Renderer* inThis, NSString* path, NSString* refName);
void RendererDrawModel(struct Renderer* inThis, NSString* refName,
                       float xPos, float yPos, float zPos,
                       float xRot, float yRot, float zRot,
                       CGRect drawArea);

//void RendererDrawObjects(struct Renderer* inThis, CGRect drawArea);

/*
struct GameObject* RendererCreateGameObject(struct Renderer* inThis, NSString* modelRef,
                                            GLKVector3 pos, GLKVector3 rot,
                                            GLKVector3 scale, GLKVector4 color);
*/

void GameObjectSetPos(struct GameObject* inThis, GLKVector3 newPos);
GLKVector3 GameObjectGetPos(struct GameObject* inThis);
void GameObjectSetRot(struct GameObject* inThis, GLKVector3 newRot);
GLKVector3 GameObjectGetRot(struct GameObject* inThis);

#ifdef __cplusplus
}
#endif

#endif /* RendererBridge_h */
