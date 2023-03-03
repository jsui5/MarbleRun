//
//  GeometryObject.hpp
//  greencube
//
//  Created by Max Korchagov on 2023-02-09.
//

#ifndef GeometryObject_h
#define GeometryObject_h

#include <stdio.h>
#include <iostream>
#include <OpenGLES/ES3/gl.h>
#include <GLKit/GLKit.h>
#include <vector>

struct GeometryVertex {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 texCoord;
    
    GeometryVertex(){}
    
    GeometryVertex(const GLKVector3& pos, const GLKVector3& norm, const GLKVector2& uv) :
        position(pos), normal(norm), texCoord(uv) {}
};

class GeometryObject {
public:
    std::vector<GeometryVertex> vertices;
    std::vector<u_int> indices;
    GeometryObject();
    int loadSelfIntoBuffers(float** pos, float** norm, float** texCoord, int** ind) const;
    static GeometryObject genPlane();
    float GetRadius() const;
private:
    float radius;
};

#endif /* GeometryObject_h */
