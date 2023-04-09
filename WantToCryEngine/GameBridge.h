//
//  GameBridge.h
//  WantToCryEngine
//
//  Created by Alex on 2023-02-14.
//

#ifndef GameBridge_h
#define GameBridge_h

#import <GLKit/GLKit.h>

struct Game;

#ifdef __cplusplus
extern "C"
{
#endif
//Creates a game and gives Swift the pointer to it for future calls.
struct Game* NewGame(GLKView* view);
//Game's update function to be triggered by the update.
void GameUpdate(struct Game* inThis);
//Game's draw that passes things to the renderer draw.
void GameDraw(struct Game* inThis, CGRect rect);
//Game Event caller.
void GameEventSinglePan(struct Game* inThis, GLKVector2 input);
void GameEventDoublePan(struct Game* inThis, GLKVector2 input);
void GameEventPinch(struct Game* inThis, float input);
void GameEventDoubleTap(struct Game* inThis);
void GameEventSingleTap(struct Game* inThis);
void GameEventSwipeRight(struct Game* inThis);
void GameEventSwipeLeft(struct Game* inThis);
void GameEventSwipeUp(struct Game* inThis);
void GameEventSwipeDown(struct Game* inThis);
void SetScore(struct Game* inThis, UITextView* text);
#ifdef __cplusplus
}
#endif

#endif /* GameBridge_h */
