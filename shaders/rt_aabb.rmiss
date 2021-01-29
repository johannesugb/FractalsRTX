#version 460
#extension GL_EXT_ray_tracing : require

struct Ray
{
    vec3 origin;
    vec3 direction;
};

struct Payload 
{
    Ray ray;
    int cnt;
    bool hit;
};

layout(location = 0) rayPayloadInEXT Payload hitValue;

void main()
{
    hitValue.hit = false;
}