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
    renderer.setup(view);
    
    models = std::map<std::string, GeometryObject>();
    objects = std::map<std::string, GameObject>();
    
    models["helmet"] = WavefrontLoader::ReadFile(resourcePath + "halo_reach_grenadier.obj");
    
    objects["static"] = GameObject(GLKVector3{0, -1, -5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["static"].geometry = models["helmet"];
    
    objects["victim"] =  GameObject(GLKVector3{0, 1, -5}, GLKVector3{0, 0, 0}, GLKVector3{1, 1, 1});
    objects["victim"].geometry = models["helmet"];
    objects["victim"].color = GLKVector4{0, 0.5, 1, 1};
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
    objects["victim"].transform.rotation.x += input.x;
    objects["victim"].transform.rotation.y += input.y;
}
