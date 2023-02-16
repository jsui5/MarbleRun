//
//  Game.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-14.
//

#include "Game.hpp"

Game::Game(GLKView* view){
    NSBundle* bundleName = [NSBundle mainBundle];
    NSString* nspath = [bundleName bundlePath];
    NSString* nspathAppended = [nspath stringByAppendingString: @"/"];

    resourcePath = std::string();
    resourcePath = nspathAppended.UTF8String;

    renderer = Renderer();
    renderer.camRot = GLKVector3{0, 0, 0};
    renderer.camPos = GLKVector3{0, 0, 0};
    renderer.setup(view);
    
    models = std::map<std::string, GeometryObject>();
    objects = std::map<std::string, GameObject>();
    
    models["helmet"] = WavefrontLoader::ReadFile(resourcePath + "halo_reach_grenadier.obj");
    
    objects["static"] = GameObject(GLKVector3{0, -1, -5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["static"].geometry = models["helmet"];
    
    objects["bottom"] = GameObject(GLKVector3{0, -5, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["bottom"].geometry = models["helmet"];
    objects["bottom"].color = GLKVector4{0, 0, .25, 1};

    objects["top"] = GameObject(GLKVector3{0, 5, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["top"].geometry = models["helmet"];
    objects["top"].color = GLKVector4{.5, .5, 0, 1};

    objects["left"] = GameObject(GLKVector3{-5, 0, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["left"].geometry = models["helmet"];
    objects["left"].color = GLKVector4{1, 0, 0, 1};

    objects["right"] = GameObject(GLKVector3{5, 0, 0}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["right"].geometry = models["helmet"];
    objects["right"].color = GLKVector4{0, 1, 0, 1};

    objects["back"] = GameObject(GLKVector3{0, 0, 5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["back"].geometry = models["helmet"];
    objects["back"].color = GLKVector4{.5, 0, .5, 1};
    
    objects["victim"] =  GameObject(GLKVector3{0, 1, -5}, GLKVector3{0, 4.712, 0}, GLKVector3{1, 1, 1});
    objects["victim"].geometry = models["helmet"];
    objects["victim"].color = GLKVector4{0, 0.25, .5, 1};
}

void Game::Update(){
    renderer.update();
}

void Game::DrawCall(CGRect* drawArea){
    for(auto i : objects){
        if(i.second.geometry.indices.size() > 3){
            renderer.drawGeometryObject(i.second.geometry, i.second.transform.position, i.second.transform.rotation, i.second.transform.scale, i.second.color, drawArea);
        }
    }
}

void Game::EventSinglePan(GLKVector2 input){
    /*
    objects["victim"].transform.rotation.x += input.x;
    objects["victim"].transform.rotation.y += input.y;
     */
    renderer.camRot.y -= input.y;
    renderer.camRot.x -= input.x;
}

void Game::EventDoublePan(GLKVector2 input){
    renderer.camPos.x += cos(renderer.camRot.y) * input.x;
    renderer.camPos.z -= sin(renderer.camRot.y) * input.x;
    renderer.camPos.y -= input.y;
}

void Game::EventPinch(float input){
    renderer.camPos.z -= cos(renderer.camRot.y) * input;
    renderer.camPos.x -= sin(renderer.camRot.y) * input;
}
