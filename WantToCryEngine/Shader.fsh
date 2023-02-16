#version 300 es

precision highp float;
in vec4 v_color;
in vec4 v_normal;
out vec4 o_fragColor;

uniform mat4 rotMatrix;
uniform vec4 cameraFacing;
uniform vec4 normalMatrix;
uniform mat4 modelViewProjectionMatrix;

void main()
{
    vec4 light = normalize(vec4(-1, 1, 0.2, 0));
    o_fragColor = v_color * dot(rotMatrix * v_normal, light);
}
