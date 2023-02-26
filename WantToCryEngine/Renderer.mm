//
//  Renderer.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-02-11.
//

#include "Renderer.hpp"

//These correspond to uniforms in the shader file.
//They get converted to indices corresponding to the relevant uniform
//when passed in as integers.
//This will let us keep the GLint values referncing uniforms in an array
//and get them out in a convenient fashion.
enum
{
    UNIFORM_VIEW_MATRIX,
    UNIFORM_MODEL_MATRIX,
    UNIFORM_PROJECTION_MATRIX,
    UNIFORM_CAMERAFACING_VEC4,
    UNIFORM_CAMERAPOS_VEC4,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_TEX_SAMPLER2D,
    UNIFORM_FOGACTIVE_BOOL,
    UNIFORM_FOGSTART_FLOAT,
    UNIFORM_FOGFULL_FLOAT,
    UNIFORM_FOGCOLOR_VEC4,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

//Same here. Passing these as ints will give us relevant vertex attributes.
enum
{
    ATTRIB_POS,
    ATTRIB_COLOR,
    ATTRIB_NORMAL,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

Renderer::Renderer(){
    NSBundle* bundleName = [NSBundle mainBundle];
    NSString* nspath = [bundleName bundlePath];
    NSString* nspathAppended = [nspath stringByAppendingString: @"/"];

    resourcePath = std::string();
    resourcePath = nspathAppended.UTF8String;

    nextTexture = 0;
    
    std::cout << "Finished renderer creation." << std::endl;
}

Renderer::~Renderer(){
    glDeleteProgram(programObject);
}

char* Renderer::readShaderSource(const std::string& path){
    //This is, while ugly, an easy way to do this.
    FILE* file = fopen(path.data(), "rb");
    if(!file){
        std::cerr << "Unable to load shader file: " << path.data() << std::endl;
        return NULL;
    }

    fseek(file, 0, SEEK_END);
    size_t len = ftell(file);
    
    fclose(file);
    
    char* buffer = (char*)malloc(len + 1);
    buffer[len] = 0; //this null-terminates the whole thing
    
    file = fopen(path.data(), "rb");
    if(!file){
        std::cerr << "Unable to load shader file (reopen failed): " << path << std::endl;
        return NULL;
    }
    
    if(!fread(buffer, len, 1, file)){
        fclose(file);
        std::cerr << "Read shader file " << path << " but result length zero!" << std::endl;
        return NULL;
    }
    fclose(file);
    
    std::cout << "Read shader source from " << path << std::endl;
    
    return buffer;
}

GLuint Renderer::loadShader(GLenum shaderType, char* shaderSource){
    //tell OpenGL to set up a new shader.
    GLuint result = glCreateShader(shaderType);
    
    if(!result){ //if shader wasn't set up for whatever reason, we can't keep going.
        return 0;
    }
    
    //Load source into our new shader and compile it
    glShaderSource(result, 1, &shaderSource, NULL);
    glCompileShader(result);
    
    //test to see if the compile worked. Output relevant error message if not.
    GLint shaderAnswer;
    glGetShaderiv(result, GL_COMPILE_STATUS, &shaderAnswer);
    if(!shaderAnswer){
        glGetShaderiv(result, GL_INFO_LOG_LENGTH, &shaderAnswer);
        if(shaderAnswer){
            char* logBuffer = (char*)malloc(shaderAnswer);
            glGetShaderInfoLog(result, shaderAnswer, NULL, logBuffer);
            std::cerr << "Shader compile fail: " << logBuffer << std::endl;
            free(logBuffer);
        } else {
            std::cerr << "Shader compile failed with no log." << std::endl;
        }
        glDeleteShader(result);
        return 0;
    }
    
    std::cout << "Loaded a shader." << std::endl;
    
    //If nothing broke, the shader is all ready to be loaded into the program.
    return result;
}

GLuint Renderer::loadGLProgram(char* vertexShaderSource, char* fragShaderSource){
    //load shaders and check if they're OK.
    GLuint vertShader = loadShader(GL_VERTEX_SHADER, vertexShaderSource);
    if(!vertShader){
        return 0;
    }
    GLuint fragShader = loadShader(GL_FRAGMENT_SHADER, fragShaderSource);
    if(!fragShader){
        glDeleteShader(vertShader); //if the frag has gone bad, we can't go on and need to clean up.
        return 0;
    }
    
    //Set up the Program Object.
    GLuint resultProgram = glCreateProgram();
    if(!resultProgram){
        glDeleteShader(vertShader);
        glDeleteShader(fragShader);
        std::cerr << "Failed program creation." << std::endl;
        return 0;
    }
    
    //give shaders to the program object.
    glAttachShader(resultProgram, vertShader);
    glAttachShader(resultProgram, fragShader);
    
    //Link and test program.
    glLinkProgram(resultProgram);
    GLint programAnswer;
    glGetProgramiv(resultProgram, GL_LINK_STATUS, &programAnswer);
    if(!programAnswer){
        glGetProgramiv(resultProgram, GL_INFO_LOG_LENGTH, &programAnswer);
        if(programAnswer){
            char* logBuffer = (char*)malloc(programAnswer);
            glGetProgramInfoLog(resultProgram, programAnswer, NULL, logBuffer);
            std::cerr << "GL Program Object creation failed: " << logBuffer << std::endl;
            free(logBuffer);
        } else {
            std::cerr << "GL Program Object creation failed with no message." << std::endl;
        }
        glDeleteProgram(resultProgram);
        return 0;
    }
    
    //Slate shaders for deletion when no program is using them anymore.
    //i.e. when the program gets deleted.
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    
    std::cout << "Loaded GL program." << std::endl;
    
    return resultProgram;
}

/*
void Renderer::loadModel(const std::string& path, const std::string& refName){
    if(models.contains(refName)){
        std::cerr << "Model called " << refName << " already loaded. Overwriting." << std::endl;
        models.erase(refName);
    }
    models[refName] = WavefrontLoader::ReadFile(resourcePath + path);
    std::cout << "Loaded model " << path << std::endl;
}
*/

void Renderer::setup(GLKView* view){
    //Allocate, set up, and tests the Context that will manage OpenGL ES.
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!view.context) {
        std::cerr << "Failed to create view context. " << std::endl;
        return;
    }
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    targetView = view;
    [EAGLContext setCurrentContext:view.context];
    if (!targetView){
        return;
    }
    
    //Load shader source code.
    char* vertShaderSource = readShaderSource(resourcePath + "Shader.vsh");
    char* fragShaderSource = readShaderSource(resourcePath + "Shader.fsh");
    
    //Set up the program object.
    programObject = loadGLProgram(vertShaderSource, fragShaderSource);
    if(!programObject){
        std::cerr << "Setup failure due to no program object." << std::endl;
    }
    
    //Set up uniforms.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(programObject, "modelViewProjectionMatrix");
    uniforms[UNIFORM_VIEW_MATRIX] = glGetUniformLocation(programObject, "viewMatrix");
    uniforms[UNIFORM_MODEL_MATRIX] = glGetUniformLocation(programObject, "modelMatrix");
    uniforms[UNIFORM_PROJECTION_MATRIX] = glGetUniformLocation(programObject, "projectionMatrix");
    uniforms[UNIFORM_CAMERAFACING_VEC4] = glGetUniformLocation(programObject, "cameraFacing");
    uniforms[UNIFORM_CAMERAPOS_VEC4] = glGetUniformLocation(programObject, "cameraPos");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(programObject, "normalMatrix");
    uniforms[UNIFORM_TEX_SAMPLER2D] = glGetUniformLocation(programObject, "tex");
    uniforms[UNIFORM_FOGACTIVE_BOOL] = glGetUniformLocation(programObject, "fogActive");
    uniforms[UNIFORM_FOGSTART_FLOAT] = glGetUniformLocation(programObject, "fogStart");
    uniforms[UNIFORM_FOGFULL_FLOAT] = glGetUniformLocation(programObject, "fogFull");
    uniforms[UNIFORM_FOGCOLOR_VEC4] = glGetUniformLocation(programObject, "fogColor");
    
    setEnvironment(15, 50, GLKVector4{0.3, 0.3, 0.4, 1});
    glEnable(GL_DEPTH_TEST); //Enable depth testing for objects to be obscured by each other
    glEnable(GL_CULL_FACE); //Enable backface culling
    
    
    std::cout << "Finished GL setup." <<std::endl;

}

void Renderer::update(){
    //set up perspective matrix for later use with displaying things.
    float aspectRatio = (float)targetView.drawableWidth / (float)targetView.drawableHeight;
    perspective = GLKMatrix4MakePerspective(60.0f * M_PI / 180.0f, aspectRatio, 1.0f, 200.0f);
    glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MATRIX], 1, FALSE, (const float*)perspective.m);

    //this is more efficient than recalculating it every time
    view = getViewMatrix();
    
    glUniform4f(uniforms[UNIFORM_CAMERAFACING_VEC4], view.m03, view.m13, view.m23, 0);// I think this is right?
    glUniform4f(uniforms[UNIFORM_CAMERAPOS_VEC4], camPos.x, camPos.y, camPos.z, 1);
    glUniformMatrix4fv(uniforms[UNIFORM_VIEW_MATRIX], 1, FALSE, (const float*)view.m);

    //Clear the screen - done once per frame so that when objects are done all of them remain until the next frame. Stencil isn't used so we don't touch it.
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void Renderer::drawGeometryObject(const GeometryObject &object, const GLKVector3 &pos, const GLKVector3 &rot, const GLKVector3 &scale, GLuint textureIndex, const GLKVector4 &color, CGRect *drawArea){
            
    int indexCount = object.loadSelfIntoBuffers(&posBuffer, &normBuffer, &texCoordBuffer, &indexBuffer);
    
    GLKMatrix4 model = GLKMatrix4TranslateWithVector3(GLKMatrix4Identity, pos);
    model = GLKMatrix4Rotate(model, rot.x, 1, 0, 0);
    model = GLKMatrix4Rotate(model, rot.y, 0, 1, 0);
    model = GLKMatrix4Rotate(model, rot.z, 0, 0, 1);
    model = GLKMatrix4ScaleWithVector3(model, scale);
    glUniformMatrix4fv(uniforms[UNIFORM_MODEL_MATRIX], 1, FALSE, (const float*)model.m);

    GLKMatrix4 rotMat;
    rotMat = GLKMatrix4Rotate(GLKMatrix4Identity, rot.x, 1, 0, 0);
    rotMat = GLKMatrix4Rotate(rotMat, rot.y, 0, 1, 0);
    rotMat = GLKMatrix4Rotate(rotMat, rot.z, 0, 0, 1);

//    glUniformMatrix4fv(uniforms[UNIFORM_ROTATION_MATRIX], 1, FALSE, (const float*)rotMat.m);
    
    bool invertFlag;
    
    GLKMatrix4 mvp = GLKMatrix4Multiply(view, model);
    mvp = GLKMatrix4Multiply(perspective, mvp);
    
    GLKMatrix4 normalMatrix = GLKMatrix4Transpose(GLKMatrix4Invert(model, &invertFlag));

    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, FALSE, (const float*)mvp.m);
    glUniformMatrix4fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, FALSE, (const float*)normalMatrix.m);
        
//    glActiveTexture(GL_TEXTURE0 + textureIndex);
    glUniform1i(uniforms[UNIFORM_TEX_SAMPLER2D], (textureIndex));
    
    glViewport(0, 0, (int)targetView.drawableWidth, (int)targetView.drawableHeight);
    glUseProgram(programObject);
    
    glVertexAttribPointer(ATTRIB_POS, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GL_FLOAT), posBuffer);
    glEnableVertexAttribArray(ATTRIB_POS);
    glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_TRUE, 3*sizeof(GL_FLOAT), normBuffer);
    glEnableVertexAttribArray(ATTRIB_NORMAL);
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_TRUE, 2*sizeof(GL_FLOAT), texCoordBuffer);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);

    glVertexAttrib4fv(ATTRIB_COLOR, color.v);
    
    glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_INT, indexBuffer);
    
    free(posBuffer);
    free(normBuffer);
    free(texCoordBuffer);
    free(indexBuffer);

}

//This is responsible for making the camera mobile.
GLKMatrix4 Renderer::getViewMatrix(){
    GLKMatrix4 rotor = GLKMatrix4MakeYRotation(camRot.y);
    rotor = GLKMatrix4RotateX(rotor, camRot.x);
    rotor = GLKMatrix4RotateZ(rotor, camRot.z);
    
    GLKVector3 forward = GLKMatrix4MultiplyVector3(rotor, GLKVector3{0, 0, 1});
    GLKVector3 top = GLKMatrix4MultiplyVector3(rotor, GLKVector3{0, 1, 0});
    GLKVector3 right = GLKMatrix4MultiplyVector3(rotor, GLKVector3{1, 0, 0});
    
    GLKMatrix4 result{
        right.x, top.x, forward.x, 0,
        right.y, top.y, forward.y, 0,
        right.z, top.z, forward.z, 0,
        GLKVector3DotProduct(right, camPos), GLKVector3DotProduct(top, camPos), GLKVector3DotProduct(forward, camPos), 1
    };
    
    return result;
}

GLuint Renderer::loadTexture(CGImage* img){
        
    size_t xSize = CGImageGetWidth(img);
    size_t ySize = CGImageGetHeight(img);
    
    GLubyte* pixelBuffer = (GLubyte*)malloc(xSize * ySize * 4 * sizeof(GLubyte));
    
    //This is some kind of Apple-brand black magic that loads an image into a buffer.
    CGContextRef context = CGBitmapContextCreate(pixelBuffer, xSize, ySize, 8, xSize*4, CGImageGetColorSpace(img), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, xSize, ySize), img);
    CGContextRelease(context);

    //Get a place for the new texture.
    GLuint handle;
    glGenTextures(1, &handle);
    //Set active texture to next free slot.
    glActiveTexture(GL_TEXTURE0 + nextTexture);
    //Bind the handle to the active slot as a 2D Texture.
    glBindTexture(GL_TEXTURE_2D , handle);
    glTexParameteri(GL_TEXTURE_2D , GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    //Upload it.
    glTexImage2D(GL_TEXTURE_2D , 0, GL_RGBA, xSize, ySize, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixelBuffer);
    //Data has been copied from the buffer to VRAM, so we don't need it anymore.
    free(pixelBuffer);
    
    GLuint result = nextTexture;
    
    nextTexture++;

    return result;
}

void Renderer::setEnvironment(float fogStartDist, float fogFullDist, const GLKVector4& color){
    //This minimizes the number of uniform changes when turning fog off.
    if(fogFullDist > fogStartDist){
        //non-zero values get evaluated as True when passed into shader bool uniform
        glUniform1i(uniforms[UNIFORM_FOGACTIVE_BOOL], 1);
        glUniform1f(uniforms[UNIFORM_FOGSTART_FLOAT], fogStartDist);
        glUniform1f(uniforms[UNIFORM_FOGFULL_FLOAT], fogFullDist);
        glUniform4f(uniforms[UNIFORM_FOGCOLOR_VEC4], color.x, color.y, color.z, color.w);
    } else {
        //Conversely, zero is false.
        glUniform1i(uniforms[UNIFORM_FOGACTIVE_BOOL], 0);
    }
    glClearColor(color.x, color.y, color.z, color.w);
}
