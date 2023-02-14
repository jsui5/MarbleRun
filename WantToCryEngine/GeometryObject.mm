//
//  GeometryObject.cpp
//  greencube
//
//  Created by Max Korchagov on 2023-02-09.
//

#include "GeometryObject.h"

int GeometryObject::loadSelfIntoBuffers(float** pos, float** norm, float** texCoord, int** ind) const{
    if(ind != NULL){
        *ind = (int *)malloc ( sizeof ( int ) * indices.size() );
//        memcpy ( *ind, indices.data(), sizeof ( int* ) * indices.size() );
        for(int i = 0; i < indices.size(); i++){
            (*ind)[i] = indices[i];
        }
    }
    if(pos != NULL && norm != NULL && ind != NULL){
        *pos = (float*)malloc(sizeof(float) * 3 * vertices.size());
        *norm = (float*)malloc(sizeof(float) * 3 * vertices.size());
        *texCoord = (float*)malloc(sizeof(float) * 2 * vertices.size());
        for(int i = 0; i < vertices.size(); i++){
            (*pos)[i * 3] = vertices[i].position.x;
            (*pos)[i * 3 + 1] = vertices[i].position.y;
            (*pos)[i * 3 + 2] = vertices[i].position.z;
            (*norm)[i * 3] = vertices[i].normal.x;
            (*norm)[i * 3 + 1] = vertices[i].normal.y;
            (*norm)[i * 3 + 2] = vertices[i].normal.z;
            (*texCoord)[i * 2] = vertices[i].texCoord.x;
            (*texCoord)[i * 2 + 1] = vertices[i].texCoord.y;
        }
    }
    return indices.size();
}

GeometryObject GeometryObject::genTwoSidedPlane(){
    GeometryObject result = GeometryObject();
    //plane is offset because badly made shaders may cause a centered object to be unlit
    GeometryVertex v1 = GeometryVertex(GLKVector3{-0.5, -.5, -.5}, GLKVector3{0, -1, 0}, GLKVector2{0, 0});
    GeometryVertex v2 = GeometryVertex(GLKVector3{-0.5, -.5, .5}, GLKVector3{0, -1, 0}, GLKVector2{0, 1});
    GeometryVertex v3 = GeometryVertex(GLKVector3{0.5, -.5, .5}, GLKVector3{0, -1, 0}, GLKVector2{1, 1});
    GeometryVertex v4 = GeometryVertex(GLKVector3{0.5, -.5, -.5}, GLKVector3{0, -1, 0}, GLKVector2{1, 0});
    
    result.vertices = std::vector<GeometryVertex>{ v1, v2, v3, v4};
    
    result.indices = std::vector<u_int>{0, 2, 1, 0, 3, 2};

    return result;
}
