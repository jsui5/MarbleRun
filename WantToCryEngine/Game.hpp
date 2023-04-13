//
//  Game.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-14.
//

#ifndef Game_hpp
#define Game_hpp

#define NUM_LANES 5

#define NUM_PLATFORMS 5

#define PLATFORM_LENGTH 50
#define PLATFORM_WIDTH 10
#define PLATFORM_HEIGHT 1

#define CAMERA_OFFSET_Z 10

#define OBSTACLE_LENGTH 5
#define OBSTACLE_SPAWN_INTERVEL 7.5
#define OBSTACLE_SPAWN_OFFSET_Z 25
#define OBSTACLE_RAND_MIN 1
#define OBSTACLE_RAND_MAX 5
#define OBSTACLE_RAND_TO_SPAWN 3
#define SCORE_ON_PASS_OBSTACLE 50

#define BOTTOM_OBSTACLE_SPAWN_Y 1
#define BOTTOM_OBSTACLE_HEIGHT 2

#define TOP_OBSTACLE_SPAWN_Y 17.5
#define TOP_OBSTACLE_ALLOW_DROP 1
#define TOP_OBSTACLE_HEIGHT 3

#define WALL_WIDTH 1
#define WALL_HEIGHT 25
#define WALL_LENGTH 2500

#define CEIL_SPAWN_Y 20
#define CEIL_HEIGHT 1

#define ENABLE_FOG_ON_START 0

#define PLAYER_JUMP_STRENGTH 3
#define PLAYER_SPEED -10

#define FOG_START_OFFSET_FROM_PLAYER 100
#define FOG_END_OFFSET_FROM_PLAYER 250

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
#include <unordered_map>
#include <ctime>


class Game{
public:
    
    std::unordered_map<std::string, float> bottomObstacleRotationSpeeds;

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
    void EventSwipeRight();
    void EventSwipeLeft();
    void EventSwipeUp();
    void EventSwipeDown();
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
    std::string platforms[NUM_PLATFORMS];
    float nextRePlatformCheckpoint;
    float obstacleTimer;
    int platformsSpawned;
    std::chrono::time_point<std::chrono::steady_clock> prevTime;
};


#endif /* Game_hpp */
