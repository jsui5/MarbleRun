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
    
    // Set initial obstacle timer
    timeBetweenObstacles = 5;
    obstacleTimer = timeBetweenObstacles;
    
    //Load models
//    models["helmet"] = WavefrontLoader::ReadFile(resourcePath + "halo_reach_grenadier.obj");
    models["monkey"] = WavefrontLoader::ReadFile(resourcePath + "blender_suzanne.obj");
    models["cube"] = WavefrontLoader::ReadFile(resourcePath + "cube.obj");
    //load models into reusable VAOs
    for(auto i : models){
        loadedGeometry[i.first] = PreloadedGeometryObject(renderer.loadGeometryVAO(i.second), models[i.first].GetRadius(), models[i.first].indices);
    }
    
    //Create game objects
    float platformWidth = 5;
    float platformLength = 50;
    float platformHeight = 1;
    
    for (int i = 0; i < 5; i++) {
        std::string label = "ground" + std::to_string(i);
        objects[label] = GameObject(GLKVector3{0, -1, -i * platformLength / 2}, GLKVector3{0, 0, 0}, GLKVector3{platformWidth, platformHeight, i * platformLength});
        objects[label].preloadedGeometry = loadedGeometry["cube"];
        objects[label].textureIndex = textures["test"];
        objects[label].addComponent(std::make_shared<BoundingBoxCollision>(objects[label], GLKVector3{platformWidth / 2, platformHeight / 2, platformLength / 2}, true));
    }
    
    objects["player"] = GameObject(GLKVector3{0, 1.0f, -1}, GLKVector3{0, 0, 0}, GLKVector3{0.75, 2, 0.75});
    objects["player"].preloadedGeometry = loadedGeometry["cube"];
    objects["player"].textureIndex = textures["test"];
    objects["player"].addComponent(std::make_shared<BoundingBoxCollision>(objects["player"], GLKVector3{0.375, 0.5, 0.375}, true));
    objects["player"].addComponent(std::make_shared<PlayerLaneControl>(objects["player"], 0, -1, 1, 25));
    SimulatedBody* playerSB = (SimulatedBody*)objects["player"].addComponent(std::make_shared<SimulatedBody>(objects["player"]));
    playerSB->gravAcceleration = 1;
    objects["player"].transform.linVelocity = GLKVector3{0.0, 0.0, -5};
    
    // SimulatedBody* groundSB = (SimulatedBody*)objects["ground"].addComponent(std::make_shared<SimulatedBody>(objects["ground"]));
    
    /*
    objects["static"] = GameObject(GLKVector3{0, -1, -5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["static"].preloadedGeometry = loadedGeometry["cube"];
    objects["static"].textureIndex = textures["test"];
    objects["static"].addComponent(std::make_shared<BoundingBoxCollision>(objects["static"], GLKVector3{0.5,0.5,0.5}, true));

    objects["static2"] = GameObject(GLKVector3{0, -5, -5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["static2"].preloadedGeometry = loadedGeometry["cube"];
    objects["static2"].textureIndex = textures["test"];
    objects["static2"].addComponent(std::make_shared<BoundingBoxCollision>(objects["static2"], GLKVector3{0.5,0.5,0.5}, true));
     */
    
    /*
    for(int i = 0; i <= 100; i++){
        std::string wb = std::string("wallblock").append(std::to_string(i));
        objects[wb] = GameObject(GLKVector3{2, -1, -50.0f + i}, GLKVector3{0, 0, 0}, GLKVector3{1, 2, 1});
        objects[wb].preloadedGeometry = loadedGeometry["cube"];
        objects[wb].textureIndex = textures["tile"];
    }
    */
    
    /*
    objects["bottom"] = GameObject(GLKVector3{0, -5, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["bottom"].preloadedGeometry = loadedGeometry["monkey"];
    objects["bottom"].color = GLKVector4{0, 0, .25, 1};
    objects["bottom"].textureIndex = textures[""];

    objects["top"] = GameObject(GLKVector3{0, 5, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["top"].preloadedGeometry = loadedGeometry["monkey"];
    objects["top"].color = GLKVector4{.5, .5, 0, 1};
    objects["top"].textureIndex = textures[""];

    objects["left"] = GameObject(GLKVector3{-5, 0, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["left"].preloadedGeometry = loadedGeometry["monkey"];
    objects["left"].color = GLKVector4{1, 0, 0, 1};
    objects["left"].textureIndex = textures[""];

    objects["far"] = GameObject(GLKVector3{-15, 0, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["far"].preloadedGeometry = loadedGeometry["monkey"];
    objects["far"].color = GLKVector4{1, 0, 0, 1};
    objects["far"].textureIndex = textures[""];
    
    objects["right"] = GameObject(GLKVector3{5, 0, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["right"].preloadedGeometry = loadedGeometry["monkey"];
    objects["right"].color = GLKVector4{0, 1, 0, 1};
    objects["right"].textureIndex = textures["tile"];

    objects["back"] = GameObject(GLKVector3{0, 0, 5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["back"].preloadedGeometry = loadedGeometry["monkey"];
    objects["back"].color = GLKVector4{.5, 0, .5, 1};
    objects["back"].textureIndex = textures["tile"];

//    SimulatedBody::gravAcceleration = 0.1;
    
    objects["victim"] =  GameObject(GLKVector3{0, 3, -5}, GLKVector3{0, 4.712, 0}, GLKVector3{1, 1, 1});
    objects["victim"].preloadedGeometry = loadedGeometry["monkey"];
    objects["victim"].color = GLKVector4{0, 0.25, .5, 1};
    objects["victim"].textureIndex = textures[""];
//    objects["victim"].addComponent(std::make_shared<ObjectNotifier>(objects["victim"], "One!!1!"));
//    objects["victim"].addComponent(std::make_shared<ObjectNotifier>(objects["victim"], "Two"));
    objects["victim"].addComponent(std::make_shared<BoundingBoxCollision>(objects["victim"], GLKVector3{1,1.7,1}, true));
    //objects["victim"].addComponent(std::make_shared<Spinner>(objects["victim"], GLKVector3{0, 1.0f, 0}));
    
    objects["brick"] = GameObject(GLKVector3{0, 20, -5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["brick"].preloadedGeometry = loadedGeometry["cube"];
    objects["brick"].textureIndex = textures["tile"];
    objects["brick"].addComponent(std::make_shared<BoundingBoxCollision>(objects["brick"], GLKVector3{0.5,0.5,0.5}, true));
     */
}

//It seems like the renderer needs to have cycled once for some things to work.
//This might just be the least janky way of going about it.
void Game::FirstUpdate(){
    renderer.setEnvironment(100, 40, GLKVector4{0.65, 0.7, 0.75, 1});
    fogActive = false;
    
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
    distancePlayerTravelled = playerPosition.z;
    
    for(auto i : objects){
        i.second.update(deltaTime);
    }
    
    if (obstacleTimer > 0) {
        obstacleTimer -= deltaTime;
    } else {
        obstacleTimer = timeBetweenObstacles;
        
        float obstacleSpawnOffset = 10;
        int chanceToSpawnInLaneMin = 1;
        int chanceToSpawnInLaneMax = 5;
        float scoreGainedOnPassObstacle = 5;
        int minResultantRandomToSpawnInLane = 3;
        for (int i = 0; i < 3; i++) {
            std::string label = "obstacle" + std::to_string(i);
            
            
            // Remove old obstacle
            if (objects.contains(label)) {
                // printf("Erased...");
                objects.erase(label);
                score += scoreGainedOnPassObstacle;
            }
            
            int randNum = rand()%(chanceToSpawnInLaneMax-chanceToSpawnInLaneMin + 1)
                + chanceToSpawnInLaneMin;
            
            if (randNum < minResultantRandomToSpawnInLane) {
                continue;
            }
            
            // Spawn new Obstacle
            objects[label] = GameObject(GLKVector3{(float)i - 1, 1, playerPosition.z - obstacleSpawnOffset}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
            objects[label].preloadedGeometry = loadedGeometry["cube"];
            objects[label].textureIndex = textures["test"];
            objects[label].addComponent(std::make_shared<BoundingBoxCollision>(objects[label], GLKVector3{0.5, 0.5, 0.5}, true));
        }
    }
    
    //Per-frame events - here, a spotlight attached to the camera has its position changed.
    Light l = Light();
    
    l.type = 2;
    l.color = GLKVector3{0.2, 0.2, 1};
    l.direction = rotToDir(renderer.camRot);
    l.position = renderer.camPos;
    l.power = 1;
    l.attenuationZeroDistance = 15;
    l.distanceLimit = 10;
    l.angle = 0.25;
    
    renderer.setLight(1, l);

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
    ((PlayerLaneControl*)objects["player"].getComponent<PlayerLaneControl>())->changeBy(input.x);
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
    GLKVector3 curVelocity = objects["player"].transform.linVelocity;
    objects["player"].transform.linVelocity = GLKVector3{curVelocity.x, .05, curVelocity.z};
}

void Game::SetScore(UITextView* setTextOf) {
    NSString *scoreText = [NSString stringWithFormat:@"Score: %i", score];
    setTextOf.text = scoreText;
}
