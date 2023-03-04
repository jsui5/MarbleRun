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

//doesn't work, do not use.
GeometryObject GeometryObject::genPlane(){
    GeometryObject result = GeometryObject();
    GeometryVertex v1 = GeometryVertex(GLKVector3{-0.5, -.5, 0}, GLKVector3{0, 1, 0}, GLKVector2{0, 0});
    GeometryVertex v2 = GeometryVertex(GLKVector3{-0.5, -.5, 0}, GLKVector3{0, 1, 0}, GLKVector2{0, 1});
    GeometryVertex v3 = GeometryVertex(GLKVector3{0.5, -.5, 0}, GLKVector3{0, 1, 0}, GLKVector2{1, 1});
    GeometryVertex v4 = GeometryVertex(GLKVector3{0.5, -.5, 0}, GLKVector3{0, 1, 0}, GLKVector2{1, 0});
    GeometryVertex v5 = GeometryVertex(GLKVector3{-0.5, -.5, 0}, GLKVector3{0, -1, 0}, GLKVector2{0, 0});
    GeometryVertex v6 = GeometryVertex(GLKVector3{-0.5, -.5, 0}, GLKVector3{0, -1, 0}, GLKVector2{0, 1});
    GeometryVertex v7 = GeometryVertex(GLKVector3{0.5, -.5, 0}, GLKVector3{0, -1, 0}, GLKVector2{1, 1});
    GeometryVertex v8 = GeometryVertex(GLKVector3{0.5, -.5, 0}, GLKVector3{0, -1, 0}, GLKVector2{1, 0});

    result.vertices = std::vector<GeometryVertex>{ v1, v2, v3, v4, v5, v6, v7, v8};
    
    result.indices = std::vector<int>{0, 1, 2, 0, 3, 1, 4, 5, 6, 4, 7, 5};

    return result;
}

float GeometryObject::GetRadius() const{
    return radius;
}

GeometryObject::GeometryObject(){
    radius = 0;
    for(GeometryVertex i : vertices){
        radius = std::max(radius, GLKVector3Length(i.position));
    }
}
