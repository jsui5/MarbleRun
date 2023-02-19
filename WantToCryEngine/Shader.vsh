#version 300 es

layout(location = 0) in vec4 position;
layout(location = 1) in vec4 color;
layout(location = 2) in vec4 normal;
layout(location = 3) in vec2 texCoord;

out vec4 v_color;
out vec4 v_normal;
out vec2 v_texCoord;

uniform mat4 rotMatrix;
uniform vec4 cameraFacing;
uniform vec4 normalMatrix;
uniform mat4 modelViewProjectionMatrix;
uniform sampler2D tex;

void main()
{
    v_color = color;
    v_normal = normal;
    v_texCoord = texCoord;
    gl_Position = modelViewProjectionMatrix * position;
}
