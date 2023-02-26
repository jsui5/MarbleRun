#version 300 es

precision highp float;
in vec4 v_color;
in vec3 v_normal;
in vec3 v_pos;
in vec2 v_texCoord;
in float v_dist;
out vec4 o_fragColor;

uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform mat4 projectionMatrix;
uniform mat4 normalMatrix;
uniform mat4 modelViewProjectionMatrix;

//camera info in case we need it
uniform vec4 cameraFacing;
uniform vec4 cameraPos;

//texture sampler - only color for now
uniform sampler2D tex;

//fog stuff
uniform bool fogActive;
uniform float fogStart;
uniform float fogFull;
uniform vec4 fogColor;

vec3 SimpleDiffuse(vec3 lightColor, vec3 lightDir){
    return max(dot(v_normal, lightDir), 0.0f) * lightColor ;
}

vec3 SimpleToon(vec3 lightColor, vec3 lightDir){
    vec3 result = dot(v_normal, lightDir) * lightColor;
    float rn = length(result);
    if(rn  < 0.3){
        result = normalize(result) * 0.2;
    } else if(rn  < 0.7){
        result = normalize(result) * 0.5;
    } else if(rn  < 0.95){
        result = normalize(result) * 0.9;
    } else {
        result = vec3(1, 1, 1);
    }
    return result;
}

vec3 Specular(float specularPower, vec3 lightColor, vec3 lightDir){
    float shn = 2.0f;
    
    vec3 viewDir = normalize(cameraPos.xyz - v_pos);
    vec3 reflectionDir = reflect(-lightDir, v_normal);
    
    return pow(max(0.0f, dot(v_normal, reflectionDir)), shn)  * lightColor * specularPower;
}

vec4 SpecularDiffuse(float specularPower, vec3 lightColor, vec3 lightDir){
    return  vec4(Specular(specularPower, lightColor, lightDir) + SimpleDiffuse(lightColor, lightDir), 1);
}

//Equation is same as the linear fog from normal, non-ES OpenGL.
float FogPowerLinear(){
    return clamp((fogFull - v_dist)/(fogFull - fogStart), 0.0, 1.0);
}

void main()
{
    vec3 lightColor = vec3(1, 1, 1);
    vec3 light = normalize(vec3(-0.35, 0.8, 0.2));
    if(fogActive){
        float fogPower = FogPowerLinear();
        o_fragColor = (texture(tex, v_texCoord) * v_color * SpecularDiffuse(0.5f, lightColor, light)) * fogPower + fogColor * (1.0 - fogPower);
    } else {
        o_fragColor = texture(tex, v_texCoord) * v_color * SpecularDiffuse(0.5f, lightColor, light);
    }
}
