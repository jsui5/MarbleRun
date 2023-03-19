//
//  GameBridge.c
//  WantToCryEngine
//
//  Created by Alex on 2023-02-14.
//

#include "GameBridge.h"
#include "Game.hpp"

extern "C" Game* NewGame(GLKView* view){
    return new Game(view);
}

extern "C" void GameUpdate(struct Game* inThis){
    inThis->Update();
}

extern "C" void GameDraw(struct Game* inThis, CGRect rect){
    inThis->DrawCall(&rect);
}

extern "C" void GameEventSinglePan(struct Game* inThis, GLKVector2 input){
    inThis->EventSinglePan(input);
}

extern "C" void GameEventDoublePan(struct Game* inThis, GLKVector2 input){
    inThis->EventDoublePan(input);
}

extern "C" void GameEventPinch(struct Game* inThis, float input){
    inThis->EventPinch(input);
}

extern "C" void GameEventDoubleTap(struct Game* inThis){
    inThis->EventDoubleTap();
}
