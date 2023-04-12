//
//  Game.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-14.
//

#include "Game.hpp"

Game::Game(GLKView* view){
    //basic setup
    NSBundle* bundleName = [NSBundle mainBundle];
    NSString* nspath = [bundleName bundlePath];
    NSString* nspathAppended = [nspath stringByAppendingString: @"/"];

    resourcePath = std::string();
    resourcePath = nspathAppended.UTF8String;

    models = std::map<std::string, GeometryObject>();
    objects = std::map<std::string, GameObject>();
    textures = std::map<std::string, GLuint>();
    
    //renderer setup
    renderer = Renderer();
    renderer.camRot = GLKVector3{0, 0, 0};
    renderer.camPos = GLKVector3{0, 0, 0};
    renderer.setup(view);
        
    //Load in textures.
    CGImageRef img0 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"white.jpg"]].CGImage;
    textures[""] = renderer.loadTexture(img0);
    CGImageRef img1 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"test.jpg"]].CGImage;
    textures["test"] = renderer.loadTexture(img1);
    CGImageRef img2 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"tile.jpg"]].CGImage;
    textures["tile"] = renderer.loadTexture(img2);
    
    CGImageRef img3 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"coin_tex.jpg"]].CGImage;
    textures["coin"] = renderer.loadTexture(img3);
    CGImageRef img4 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"marble_tex.jpg"]].CGImage;
    textures["marble"] = renderer.loadTexture(img4);
    CGImageRef img5 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"cave_tex.jpg"]].CGImage;
    textures["cave1"] = renderer.loadTexture(img5);
    CGImageRef img6 = [UIImage imageNamed:[nspathAppended stringByAppendingString: @"cave_tex_2.jpg"]].CGImage;
    textures["cave2"] = renderer.loadTexture(img6);
    
    // Set initial obstacle timer
    obstacleTimer = OBSTACLE_SPAWN_INTERVEL;
    
    // Set distance checks
    nextRePlatformCheckpoint = -PLATFORM_LENGTH / 2;
    
    //Load models
    models["monkey"] = WavefrontLoader::ReadFile(resourcePath + "blender_suzanne.obj");
    models["cube"] = WavefrontLoader::ReadFile(resourcePath + "cube.obj");
    models["caveRock"] = WavefrontLoader::ReadFile(resourcePath = "CaveRock02_Obj.obj");
    
    //load models into reusable VAOs
    for(auto i : models){
        loadedGeometry[i.first] = PreloadedGeometryObject(renderer.loadGeometryVAO(i.second), models[i.first].GetRadius(), models[i.first].indices);
    }
    
    //Create game objects
    for (int i = 0; i < NUM_PLATFORMS; i++) {
        std::string label = "ground" + std::to_string(platformsSpawned);
        // printf("%s\n", label.c_str());
        objects[label] = GameObject(GLKVector3{0, -1, (float)-platformsSpawned * PLATFORM_LENGTH / 2}, GLKVector3{0, 0, 0}, GLKVector3{PLATFORM_WIDTH, PLATFORM_HEIGHT, (float)platformsSpawned * PLATFORM_LENGTH});
        objects[label].preloadedGeometry = loadedGeometry["cube"];
        objects[label].textureIndex = textures["cave1"];
        objects[label].addComponent(std::make_shared<BoundingBoxCollision>(objects[label], GLKVector3{PLATFORM_WIDTH / 2, PLATFORM_HEIGHT / 2, PLATFORM_LENGTH / 2}, true));
        platforms[i] = label;
        platformsSpawned++;
    }
    
    // Spawn Walls
    objects["wallLeft"] = GameObject(GLKVector3{-PLATFORM_WIDTH / 2, WALL_HEIGHT / 2, -WALL_LENGTH / 2}, GLKVector3{0, 0, 0}, GLKVector3{WALL_WIDTH, WALL_HEIGHT, WALL_LENGTH});
    objects["wallLeft"].preloadedGeometry = loadedGeometry["cube"];
    objects["wallLeft"].textureIndex = textures["cave2"];
    objects["wallLeft"].addComponent(std::make_shared<BoundingBoxCollision>(objects["wallLeft"], GLKVector3{WALL_WIDTH / 2, WALL_HEIGHT / 2, WALL_LENGTH / 2}, true));
    
    objects["wallRight"] = GameObject(GLKVector3{PLATFORM_WIDTH / 2, WALL_HEIGHT / 2, -WALL_LENGTH / 2}, GLKVector3{0, 0, 0}, GLKVector3{WALL_WIDTH, WALL_HEIGHT, WALL_LENGTH});
    objects["wallRight"].preloadedGeometry = loadedGeometry["cube"];
    objects["wallRight"].textureIndex = textures["cave2"];
    objects["wallRight"].addComponent(std::make_shared<BoundingBoxCollision>(objects["wallRight"], GLKVector3{WALL_WIDTH / 2, WALL_HEIGHT / 2, WALL_LENGTH / 2}, true));
    
    // Spawn Ceiling
    objects["ceiling"] = GameObject(GLKVector3{0, CEIL_SPAWN_Y, -WALL_LENGTH / 2}, GLKVector3{0, 0, 0}, GLKVector3{PLATFORM_WIDTH, CEIL_HEIGHT, WALL_LENGTH});
    objects["ceiling"].preloadedGeometry = loadedGeometry["cube"];
    objects["ceiling"].textureIndex = textures["cave2"];
    objects["ceiling"].addComponent(std::make_shared<BoundingBoxCollision>(objects["ceiling"], GLKVector3{PLATFORM_WIDTH / 2, CEIL_HEIGHT / 2, WALL_LENGTH / 2}, true));
    
    // Spawn Player
    objects["player"] = GameObject(GLKVector3{0, 2.0f, -1}, GLKVector3{0, 0, 0}, GLKVector3{0.75, 2, 0.75});
    objects["player"].preloadedGeometry = loadedGeometry["cube"];
    objects["player"].textureIndex = textures["marble"];
    objects["player"].addComponent(std::make_shared<BoundingBoxCollision>(objects["player"], GLKVector3{0.375, 0.5, 0.375}, true));
    objects["player"].addComponent(std::make_shared<PlayerLaneControl>(objects["player"], 0, -ceil(NUM_LANES / 2), ceil(NUM_LANES / 2)));
    objects["player"].addComponent(std::make_shared<PositionLimiter>(objects["player"], false, true, false, 0, 1, 0, 0, 500, 0));
    SimulatedBody* playerSB = (SimulatedBody*)objects["player"].addComponent(std::make_shared<SimulatedBody>(objects["player"]));
    Spinner* playerSpinner = (Spinner*)objects["player"].addComponent(std::make_shared<Spinner>(objects["player"], GLKVector3{0, 1, 0}));
    playerSB->gravAcceleration = 2;
    objects["player"].transform.linVelocity = GLKVector3{0.0, 0.0, PLAYER_SPEED};
}

//It seems like the renderer needs to have cycled once for some things to work.
//This might just be the least janky way of going about it.
void Game::FirstUpdate(){
    if(ENABLE_FOG_ON_START == 0){
        renderer.setEnvironment(100, 40, GLKVector4{0.65, 0.7, 0.75, 1});
        fogActive = false;
    } else {
        renderer.setEnvironment(FOG_START_OFFSET_FROM_PLAYER, FOG_END_OFFSET_FROM_PLAYER, GLKVector4{0.65, 0.7, 0.75, 1});
        fogActive = true;
    }
    
    Light l = Light();
    
    l.type = 0;
    l.color = GLKVector3{1, 1, 1};
    l.direction = GLKVector3{0.2, -1, -0.5};
    l.power = 1;
    
    renderer.setLight(0, l);
    
    // l.type = 0;
    // l.color = GLKVector3{1, 0, 0};
    // l.direction = GLKVector3{-0.5, 0, -0.5};
    // l.power = 0.25;
    
    // renderer.setLight(1, l);
    
    //The first frame takes an eternity, so we'll reset the clock
    prevTime = std::chrono::steady_clock::now();
}

void Game::Update(){
    //Deal with FirstUpdate
    if(!firstUpdated){
        FirstUpdate();
        firstUpdated = true;
    }
    
    // Update the camera position to look at the player
    GLKVector3 playerPosition = objects["player"].transform.position;
    GLKVector3 cameraOffset = GLKVector3{0, 2.5, 10};
    renderer.camPos = GLKVector3{playerPosition.x + cameraOffset.x, playerPosition.y + cameraOffset.y, playerPosition.z + cameraOffset.z};
    
    auto nowTime = std::chrono::steady_clock::now();
    //I want fractions of seconds instead of whole milliseconds.
    float deltaTime = std::chrono::duration_cast<std::chrono::milliseconds>(nowTime - prevTime).count() * 0.001f;
    prevTime = nowTime;
    
    // Add Score
    score += 1;
    
    
    if(objects["player"].transform.linVelocity.z > -3){
        score = 0;
        objects["player"].transform.position.z = 0;
        objects["player"].transform.linVelocity.z = -5;
    }

    for(auto i : objects){
        i.second.update(deltaTime);
    }
    
    // printf("Next Checkpoint: %f of %f\n", playerPosition.z, nextRePlatformCheckpoint);
    if (playerPosition.z < nextRePlatformCheckpoint) {
        // Re Platform
        
        // Rmoeve Old
        // printf("Erasing: %s\n", platforms[0].c_str());
        objects.erase(platforms[0]);
        
        // Shift array
        for (int i = 1; i < NUM_PLATFORMS; i++) {
            std::string platformLabel = platforms[i];
            platforms[i-1]=platformLabel;
            // printf("During Shift: %i: %s\n", i, platforms[i].c_str());
        }
        
        // Spawn New
        std::string label = "ground" + std::to_string(platformsSpawned);
        // printf("New: %s\n", label.c_str());
        objects[label] = GameObject(GLKVector3{0, -1, (float)-platformsSpawned * PLATFORM_LENGTH / 2}, GLKVector3{0, 0, 0}, GLKVector3{PLATFORM_WIDTH, PLATFORM_HEIGHT, (float)platformsSpawned * PLATFORM_LENGTH});
        objects[label].preloadedGeometry = loadedGeometry["cube"];
        objects[label].textureIndex = textures["cave1"];
        objects[label].addComponent(std::make_shared<BoundingBoxCollision>(objects[label], GLKVector3{PLATFORM_WIDTH / 2, PLATFORM_HEIGHT / 2, PLATFORM_LENGTH / 2}, true));
        platforms[4] = label;
        platformsSpawned++;
        nextRePlatformCheckpoint -= PLATFORM_LENGTH / 2;
        
        
    }
    
    if (obstacleTimer > 0) {
        obstacleTimer -= deltaTime;
    } else {
        obstacleTimer = OBSTACLE_SPAWN_INTERVEL;
        
        // Bottom Obstacles
        for (int i = 0; i < NUM_LANES; i++) {
            std::string label = "bottomObstacle" + std::to_string(i);
            
            // Remove old obstacle
            if (objects.contains(label)) {
                // printf("Erased...");
                objects.erase(label);
                score += SCORE_ON_PASS_OBSTACLE;
            }
            
            int randNum = rand()%(OBSTACLE_RAND_MAX-OBSTACLE_RAND_MIN + 1)
                + OBSTACLE_RAND_MIN;
            
            if (randNum < OBSTACLE_RAND_TO_SPAWN) {
                continue;
            }
            
            // Spawn new Obstacle
            objects[label] = GameObject(GLKVector3{(float)i - NUM_LANES / 2, BOTTOM_OBSTACLE_SPAWN_Y, playerPosition.z - OBSTACLE_SPAWN_OFFSET_Z}, GLKVector3{0, 0, 0}, GLKVector3{1, BOTTOM_OBSTACLE_HEIGHT, OBSTACLE_LENGTH});
            objects[label].preloadedGeometry = loadedGeometry["cube"];
            objects[label].textureIndex = textures["cave1"];
            objects[label].addComponent(std::make_shared<BoundingBoxCollision>(objects[label], GLKVector3{0.5, BOTTOM_OBSTACLE_HEIGHT / 2, OBSTACLE_LENGTH / 2}, true));
            // SimulatedBody* obstacleSB = (SimulatedBody*)objects[label].addComponent(std::make_shared<SimulatedBody>(objects[label]));
            // objects[label].transform.linVelocity = GLKVector3{0, 0, -1};
            // obstacleSB->gravAcceleration = 0;
        }
        
        // Top Obstacles
        for (int i = 0; i < NUM_LANES; i++) {
            std::string label = "topObstacle" + std::to_string(i);
            
            // Remove old obstacle
            if (objects.contains(label)) {
                // printf("Erased...");
                objects.erase(label);
                score += SCORE_ON_PASS_OBSTACLE;
            }
            
            int randNum = rand()%(OBSTACLE_RAND_MAX-OBSTACLE_RAND_MIN + 1)
                + OBSTACLE_RAND_MIN;
            
            if (randNum < OBSTACLE_RAND_TO_SPAWN) {
                continue;
            }
            
            // Spawn new Obstacle
            objects[label] = GameObject(GLKVector3{(float)i - NUM_LANES / 2, TOP_OBSTACLE_SPAWN_Y, playerPosition.z - OBSTACLE_SPAWN_OFFSET_Z}, GLKVector3{0, 0, 0}, GLKVector3{1, TOP_OBSTACLE_HEIGHT, OBSTACLE_LENGTH});
            objects[label].preloadedGeometry = loadedGeometry["cube"];
            objects[label].textureIndex = textures["coin"];
            objects[label].addComponent(std::make_shared<BoundingBoxCollision>(objects[label], GLKVector3{0.5, TOP_OBSTACLE_HEIGHT / 2, OBSTACLE_LENGTH / 2}, true));
            
            if (TOP_OBSTACLE_ALLOW_DROP == 0) {
                continue;
            }
            
            SimulatedBody* obstacleSB = (SimulatedBody*)objects[label].addComponent(std::make_shared<SimulatedBody>(objects[label]));
            obstacleSB->gravAcceleration = 1;
        }
        
    }
    
    //Per-frame events - here, a spotlight attached to the camera has its position changed.
//    Light l = Light();
    
//    l.type = 2;
//    l.color = GLKVector3{0.2, 0.2, 1};
//    l.direction = rotToDir(renderer.camRot);
//    l.position = renderer.camPos;
//    l.power = 1;
//    l.attenuationZeroDistance = 15;
//    l.distanceLimit = 10;
//    l.angle = 0.25;
    
//    renderer.setLight(1, l);

    renderer.update();
}

void Game::DrawCall(CGRect* drawArea){
    //Issue draw calls for each of the game objects to the renderer.
    for(auto i : objects){
        if(i.second.preloadedGeometry.vao){
            renderer.drawVAO(i.second.preloadedGeometry.vao,
                             i.second.preloadedGeometry.indices,
                             i.second.preloadedGeometry.radius,
                             i.second.transform.position, i.second.transform.rotation,
                             i.second.transform.scale, i.second.textureIndex,
                             i.second.color, drawArea);
        }
    }
}

void Game::EventSinglePan(GLKVector2 input){
    /*
     objects["victim"].transform.rotation.x += input.x;
     objects["victim"].transform.rotation.y += input.y;
     */
    // renderer.camRot.y -= input.y;
    // renderer.camRot.x -= input.x;
}

void Game::EventDoublePan(GLKVector2 input){
    // renderer.camPos.x -= cos(renderer.camRot.y) * input.x;
    // renderer.camPos.z += sin(renderer.camRot.y) * input.x;
    // renderer.camPos.y += input.y;
}

void Game::EventPinch(float input){
    // renderer.camPos.z += cos(renderer.camRot.y) * input;
    // renderer.camPos.x += sin(renderer.camRot.y) * input;
}

void Game::EventDoubleTap(){
    /*
    renderer.camRot = GLKVector3{0, 0, 0};
    renderer.camPos = GLKVector3{0, 0, 0};
    
        
    if(objects.contains("victim") && objects["victim"].getComponent<SimulatedBody>() != nullptr && objects["victim"].transform.position.y < 2){
        objects.erase("victim");
        objects["brick"].transform.position.y = 15;
        objects["brick"].transform.linVelocity.y = 0;
    } else {
        //    objects["victim"].transform.linVelocity.x += 0.15;
            objects["victim"].transform.linVelocity.y = 0;
            objects["victim"].transform.position.y = 3;
            objects["victim"].transform.position.x = 0;
        objects["brick"].transform.position.y = 15;
        objects["brick"].transform.position.x = 0;
        objects["brick"].transform.linVelocity.y = 0;
        objects["brick"].transform.linVelocity.x = 0.01;

        objects["victim"].addComponent(std::make_shared<SimulatedBody>(objects["victim"]));
        objects["brick"].addComponent(std::make_shared<SimulatedBody>(objects["brick"]));
    }
     */
    
    /*
    auto notifiers = objects["victim"].getComponentsOfType<ObjectNotifier>();
    if(notifiers.size()){
        objects["victim"].removeComponent(notifiers[0]);
    }
     */

     /*
    if(fogActive){
        renderer.setEnvironment(100, 40, GLKVector4{0.65, 0.7, 0.75, 1});
        fogActive = false;
    } else {
        renderer.setEnvironment(15, 40, GLKVector4{0.65, 0.7, 0.75, 1});
        fogActive = true;
    }
      */
}

void Game::EventSingleTap() {
    
    if(objects["player"].transform.position.y < 1.1){
        GLKVector3 curVelocity = objects["player"].transform.linVelocity;
        objects["player"].transform.linVelocity = GLKVector3{curVelocity.x, PLAYER_JUMP_STRENGTH, curVelocity.z};
    }
    
}

void Game::SetScore(UITextView* setTextOf) {
    NSString *scoreText = [NSString stringWithFormat:@"Score: %i", score];
    setTextOf.text = scoreText;
}

void Game::EventSwipeRight() {
    ((PlayerLaneControl*)objects["player"].getComponent<PlayerLaneControl>())->changeBy(1);
    
    
}

void Game::EventSwipeLeft() {
    ((PlayerLaneControl*)objects["player"].getComponent<PlayerLaneControl>())->changeBy(-1);
}

void Game::EventSwipeUp(){
    
}

void Game::EventSwipeDown() {
    
}
