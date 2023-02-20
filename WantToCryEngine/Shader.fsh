#version 300 es

precision highp float;
in vec4 v_color;
in vec4 v_normal;
in vec2 v_texCoord;
in float v_dist;
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


void main()
{
    vec4 light = normalize(vec4(-1, 1, 0.2, 0));
    if(fogActive){
        //Equation is same as the linear fog from normal, non-ES OpenGL.
        float fogPower = clamp((fogFull - v_dist)/(fogFull - fogStart), 0.0, 1.0);
        o_fragColor = (texture(tex, v_texCoord) * v_color * dot(rotMatrix * v_normal, light)) * fogPower + fogColor * (1.0 - fogPower);
    } else {
        o_fragColor = texture(tex, v_texCoord) * v_color * dot(rotMatrix * v_normal, light);
    }
}
