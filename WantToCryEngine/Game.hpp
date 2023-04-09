//
//  Game.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-14.
//

#ifndef Game_hpp
#define Game_hpp

#include <stdio.h>
#include <chrono>
#include "Common.h"
#include "ObjectNotifier.hpp"
#include "Spinner.hpp"
#include "Follow.hpp"
#include "PlayerLaneControl.hpp"
#include "SimulatedBody.hpp"
#include "BoundingBoxCollision.hpp"
#include "GlobalCollisionHandler.hpp"
#include "PositionLimiter.hpp"

class Game{
public:
    std::string resourcePath;
    //these are used to store models, texture indices, and gameobjects in an easily accessible way.
    std::map<std::string, GeometryObject> models;
    std::map<std::string, PreloadedGeometryObject> loadedGeometry;
    std::map<std::string, GLuint> textures;
    std::map<std::string, GameObject> objects;
    Renderer renderer;
    //Set up the base state upon construction. Build the level, etc...
    //The view is required to set up the Renderer straight from here.
    Game(GLKView* view);
    void EventSingleTap();
    //Call these events from Swift using the GameBridge.
    void EventDoubleTap();
    //Events can have parameters - once again, pass in from Swift through GameBridge.
    void EventSinglePan(GLKVector2 input);
    void EventDoublePan(GLKVector2 input);
    void EventPinch(float input);
    void SetScore(UITextView* set);
    //This is where the magic happens - pass the frame update to this function.
    void Update();
    //This is a bridge to the Renderer.
    void DrawCall(CGRect* drawArea);
private:
    bool fogActive;
    bool firstUpdated;
    void FirstUpdate();
    void handleCollisions();
    int score;
    float distancePlayerTravelled;
    float obstacleTimer;
    float timeBetweenObstacles;
    std::chrono::time_point<std::chrono::steady_clock> prevTime;
};


#endif /* Game_hpp */
