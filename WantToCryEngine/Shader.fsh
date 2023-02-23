#version 300 es

precision highp float;
in vec4 v_color;
in vec4 v_normal;
in vec2 v_texCoord;
in float v_dist;
in vec4 v_toEye;
out vec4 o_fragColor;

uniform mat4 rotMatrix;
uniform vec4 cameraFacing;
uniform vec4 cameraPos;
uniform vec4 normalMatrix;
uniform mat4 modelViewProjectionMatrix;
uniform sampler2D tex;
uniform bool fogActive;
uniform float fogStart;
uniform float fogFull;
uniform vec4 fogColor;

vec3 SimpleDiffuse(vec3 lightColor, vec3 lightDir){
    return dot(v_normal.xyz, lightDir) * lightColor;
}

vec3 SimpleToon(vec3 lightColor, vec3 lightDir){
    vec3 result = dot(v_normal.xyz, lightDir) * lightColor;
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

//Equation is same as the linear fog from normal, non-ES OpenGL.
float FogPowerLinear(){
    return clamp((fogFull - v_dist)/(fogFull - fogStart), 0.0, 1.0);
}

void main()
{
    vec3 lightColor = vec3(1, 1, 1);
    vec3 light = normalize(vec3(-.5, 1, 0.2));
    if(fogActive){
        float fogPower = FogPowerLinear();
        o_fragColor = (texture(tex, v_texCoord) * v_color * vec4(SimpleDiffuse(lightColor, light), 1)) * fogPower + fogColor * (1.0 - fogPower);
    } else {
        o_fragColor = texture(tex, v_texCoord) * v_color * vec4(SimpleDiffuse(lightColor, light), 1);
    }
}
