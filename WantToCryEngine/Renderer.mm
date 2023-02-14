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
    UNIFORM_VIEWPROJECTION_MATRIX,
    UNIFORM_CAMERAFACING_VEC4,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
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

    models = std::map<std::string, GeometryObject>();
    
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

void Renderer::loadModel(const std::string& path, const std::string& refName){
    if(models.contains(refName)){
        std::cerr << "Model called " << refName << " already loaded. Overwriting." << std::endl;
        models.erase(refName);
    }
    models[refName] = WavefrontLoader::ReadFile(resourcePath + path);
    std::cout << "Loaded model " << path << std::endl;
}

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
    uniforms[UNIFORM_VIEWPROJECTION_MATRIX] = glGetUniformLocation(programObject, "viewProjectionMatrix");
    uniforms[UNIFORM_CAMERAFACING_VEC4] = glGetUniformLocation(programObject, "cameraFacing");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(programObject, "normalMatrix");
    
    glClearColor(0.1, 0.1, 0.1, 1); //Set background color.
    glEnable(GL_DEPTH_TEST); //Enable depth testing for objects to be obscured by each other
    glEnable(GL_CULL_FACE); //Enable backface culling
    
    
    std::cout << "Finished GL setup." <<std::endl;

}

void Renderer::update(){
    //set up perspective matrix for later use with displaying things.
    float aspectRatio = (float)targetView.drawableWidth / (float)targetView.drawableHeight;
    perspective = GLKMatrix4MakePerspective(60.0f * M_PI / 180.0f, aspectRatio, 1.0f, 20.0f);
    
    //Clear the screen - done once per frame so that when objects are done all of them remain until the next frame. Stencil isn't used so we don't touch it.
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void Renderer::drawModel(const std::string& refName, const GLKVector3& pos,
                         const GLKVector3& rot, CGRect* drawArea){
    
    if(!models.contains(refName)){
        std::cerr << "No model called \"" << refName << "\" - not drawing anything." << std::endl;
        return;
    }
    
    glUniformMatrix4fv(uniforms[UNIFORM_VIEWPROJECTION_MATRIX], 1, FALSE, (const float*)perspective.m);
        
    int indexCount = models[refName].loadSelfIntoBuffers(&posBuffer, &normBuffer, &texCoordBuffer, &indexBuffer);
    
    GLKMatrix4 mvp = GLKMatrix4TranslateWithVector3(GLKMatrix4Identity, pos);
    mvp = GLKMatrix4Rotate(mvp, rot.x, 1, 0, 0);
    mvp = GLKMatrix4Rotate(mvp, rot.y, 0, 1, 0);
    mvp = GLKMatrix4Rotate(mvp, rot.z, 0, 0, 1);
    
    bool invertFlag;
    
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(mvp, &invertFlag);
    
    mvp = GLKMatrix4Multiply(perspective, mvp);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, FALSE, (const float*)mvp.m);
    glUniformMatrix4fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, FALSE, (const float*)normalMatrix.m);
    glUniform4f(uniforms[UNIFORM_CAMERAFACING_VEC4], 1, 0, 0, 0);
    
    
    glViewport(0, 0, (int)targetView.drawableWidth, (int)targetView.drawableHeight);
    glUseProgram(programObject);
    
    glVertexAttribPointer(ATTRIB_POS, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GL_FLOAT), posBuffer);
    glEnableVertexAttribArray(ATTRIB_POS);
    glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_TRUE, 3*sizeof(GL_FLOAT), normBuffer);
    glEnableVertexAttribArray(ATTRIB_NORMAL);
    
    glVertexAttrib4f(ATTRIB_COLOR, 0, 1, 0, 1);
    
    glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_INT, indexBuffer);
    
    free(posBuffer);
    free(normBuffer);
    free(texCoordBuffer);
    free(indexBuffer);
}

void Renderer::drawGeometryObject(const GeometryObject &object, const GLKVector3 &pos, const GLKVector3 &rot, const GLKVector3 &scale, const GLKVector4 &color, CGRect *drawArea){
    
    glUniformMatrix4fv(uniforms[UNIFORM_VIEWPROJECTION_MATRIX], 1, FALSE, (const float*)perspective.m);
        
    int indexCount = object.loadSelfIntoBuffers(&posBuffer, &normBuffer, &texCoordBuffer, &indexBuffer);
    
    GLKMatrix4 mvp = GLKMatrix4TranslateWithVector3(GLKMatrix4Identity, pos);
    mvp = GLKMatrix4Rotate(mvp, rot.x, 1, 0, 0);
    mvp = GLKMatrix4Rotate(mvp, rot.y, 0, 1, 0);
    mvp = GLKMatrix4Rotate(mvp, rot.z, 0, 0, 1);
    mvp = GLKMatrix4ScaleWithVector3(mvp, scale);
    
    bool invertFlag;
    
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(mvp, &invertFlag);
    
    mvp = GLKMatrix4Multiply(perspective, mvp);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, FALSE, (const float*)mvp.m);
    glUniformMatrix4fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, FALSE, (const float*)normalMatrix.m);
    glUniform4f(uniforms[UNIFORM_CAMERAFACING_VEC4], 1, 0, 0, 0);
    
    
    glViewport(0, 0, (int)targetView.drawableWidth, (int)targetView.drawableHeight);
    glUseProgram(programObject);
    
    glVertexAttribPointer(ATTRIB_POS, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GL_FLOAT), posBuffer);
    glEnableVertexAttribArray(ATTRIB_POS);
    glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_TRUE, 3*sizeof(GL_FLOAT), normBuffer);
    glEnableVertexAttribArray(ATTRIB_NORMAL);
    
    glVertexAttrib4fv(ATTRIB_COLOR, color.v);
    
    glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_INT, indexBuffer);
    
    free(posBuffer);
    free(normBuffer);
    free(texCoordBuffer);
    free(indexBuffer);

}
