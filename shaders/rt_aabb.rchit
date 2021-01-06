#version 460
#extension GL_EXT_ray_tracing : require
#extension GL_EXT_nonuniform_qualifier : require

struct Ray
{
    vec3 origin;
    vec3 direction;
};

struct Payload 
{
    Ray ray;
    bool hit;
};

layout(set = 1, binding = 0) uniform accelerationStructureEXT topLevelAS;

layout(location = 0) rayPayloadInEXT Payload hitValue;
layout(location = 1) rayPayloadEXT Payload hitRecursive;
hitAttributeEXT vec3 attribs;
layout(location = 2) rayPayloadEXT float secondaryRayHitValue;

void main()
{
//    vec3 origin = gl_WorldRayOriginEXT + gl_WorldRayDirectionEXT * gl_HitTEXT;
//    vec3 direction = normalize(vec3(0.8, 1, 0));
//    uint rayFlags = gl_RayFlagsOpaqueEXT | gl_RayFlagsTerminateOnFirstHitEXT;
//    uint cullMask = 0xff;
//    float tmin = 0.001;
//    float tmax = 100.0;
//
//    traceRayEXT(topLevelAS, rayFlags, cullMask, 1 /* sbtRecordOffset */, 0 /* sbtRecordStride */, 1 /* missIndex */, origin, tmin, direction, tmax, 2 /*payload location*/);

//	hitValue.

//    uint rayFlags = gl_RayFlagsOpaqueEXT;
//    uint cullMask = 0xff;
//    float tmin = 0.001;
//    float tmax = 100.0;
//    traceRayEXT(topLevelAS, rayFlags, cullMask, 0 /*sbtRecordOffset*/, 0 /*sbtRecordStride*/, 0 /*missIndex*/, hitValue.ray.origin, tmin, hitValue.ray.direction, tmax, 0 /*payload*/);
//

    // TODO: Hier geht's weiter:
    // Payload not supported in Intersection shader => d.h. Intersection shader macht wirklich nur eine sphere intersection
    // Das Aufmultiplizieren der Matrizen und die Rekursion müssen hier gemacht werden.
}