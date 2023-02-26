#version 300 es

layout(location = 0) in vec4 position;
layout(location = 1) in vec4 color;
layout(location = 2) in vec4 normal;
layout(location = 3) in vec2 texCoord;

out vec4 v_color;
out vec3 v_normal;
out vec3 v_pos;
out vec2 v_texCoord;
out float v_dist;

uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform mat4 projectionMatrix;
uniform mat4 normalMatrix;
//this is here because the extra memory is worth not having to calculate it every damn vertex
uniform mat4 modelViewProjectionMatrix;

void main()
{
    v_pos = (modelMatrix * position).xyz;
    v_dist = length(((modelViewProjectionMatrix * position)).xyz);
    v_color = color;
    v_normal = normalize(mat3(normalMatrix) * normal.xyz);
    v_texCoord = texCoord;
    gl_Position = modelViewProjectionMatrix * position;
}
