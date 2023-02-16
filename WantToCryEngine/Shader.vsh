#version 300 es

layout(location = 0) in vec4 position;
layout(location = 1) in vec4 color;
layout(location = 2) in vec4 normal;

out vec4 v_color;
out vec4 v_normal;

uniform mat4 rotMatrix;
uniform vec4 cameraFacing;
uniform vec4 normalMatrix;
uniform mat4 modelViewProjectionMatrix;

void main()
{
    v_color = color;
    v_normal = normal;
    gl_Position = modelViewProjectionMatrix * position;
}
