//
//  PreloadedGeometryObject.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-03.
//

//This is a simple container for some information that needs to be stored when dealing with
//geometry that was loaded into an OpenGL Vertex Array Object instead of being uploaded
//every frame.

#include <OpenGLES/ES3/gl.h>
#include <GLKit/GLKit.h>
#include <string>
#include <vector>
#include <map>

#ifndef PreloadedGeometryObject_hpp
#define PreloadedGeometryObject_hpp

struct PreloadedGeometryObject{
    //the index of the VAO that's being used.
    GLuint vao;
    //Radius of the model used for frustrum-type checks
    float radius;
    //index buffer. It's a list becase it's easier to deal with, especially when opening a file.
    std::vector<int> indices;
    PreloadedGeometryObject(GLuint vertexArrayObject, float rad, const std::vector<int> indexBuffer) : vao(vertexArrayObject), radius(rad), indices(indexBuffer) {}
    PreloadedGeometryObject() : vao(0), radius(0), indices() {}
};

#include <stdio.h>

#endif /* PreloadedGeometryObject_hpp */
