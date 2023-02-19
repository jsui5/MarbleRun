//
//  Renderer.hpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-11.
//

#ifndef Renderer_hpp
#define Renderer_hpp

#include <GLKit/GLKit.h>
#include <OpenGLES/ES3/gl.h>

#include "Common.h"
#include <vector>
#include <fstream>
#include <sstream>
#include <iostream>
#include <string>
#include <map>
#include "WavefrontLoader.hpp"

class Renderer{
private:
    char* readShaderSource(const std::string& path);
    GLuint loadShader(GLenum shaderType, char* shaderSource);
    GLuint loadGLProgram(char* vertexShaderSource, char* fragShaderSource);
    std::string resourcePath;
    GLKView* targetView;
    GLuint programObject;
    GLuint nextTexture;
//    std::map<std::string, GeometryObject> models;
//    std::map<std::string, GLuint> textures;
    GLKMatrix4 perspective;
    GLKMatrix4 view;
    float* posBuffer;
    float* normBuffer;
    float* texCoordBuffer;
    int* indexBuffer;

public:
    Renderer();
    ~Renderer();
    void setup(GLKView* view);
    void loadModel(const std::string& path, const std::string& refName);
    void update();
    void drawModel(const std::string& refName, const GLKVector3& pos,
                   const GLKVector3& rot, CGRect* drawArea);
    void drawGeometryObject(const GeometryObject& object,
                            const GLKVector3& pos, const GLKVector3& rot, const GLKVector3& scale, GLuint textureIndex,
                            const GLKVector4& color, CGRect* drawArea);
    GLuint loadTexture(CGImageRef img);
    GLKMatrix4 getViewMatrix();
    GLKVector3 camPos;
    GLKVector3 camRot;
};

#endif /* Renderer_hpp */
