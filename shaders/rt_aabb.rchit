#version 460
#extension GL_EXT_ray_tracing : require
#extension GL_EXT_nonuniform_qualifier : require

layout(push_constant) uniform PushConstants {
	mat4 mCameraTransform;
    int mMaxRecursions;
} pushConstants;

struct aligned_aabb
{
	vec3 mMinBounds;
	vec3 mMaxBounds;
	vec2 _align;
};

struct Sphere
{
  vec3  center;
  float radius;
};

struct Ray
{
    vec3 origin;
    vec3 direction;
};

// Ray-Sphere intersection
// http://viclw17.github.io/2018/07/16/raytracing-ray-sphere-intersection/
float hitSphere(const Sphere s, const Ray r)
{
  vec3  oc           = r.origin - s.center;
  float a            = dot(r.direction, r.direction);
  float b            = 2.0 * dot(oc, r.direction);
  float c            = dot(oc, oc) - s.radius * s.radius;
  float discriminant = b * b - 4 * a * c;
  if(discriminant < 0)
  {
    return -1.0;
  }
  else
  {
    return (-b - sqrt(discriminant)) / (2.0 * a);
  }
}

// Ray-AABB intersection
float hitAabb(const aligned_aabb aabb, const Ray r)
{
  vec3  invDir  = 1.0 / r.direction;
  vec3  t0      = invDir * (aabb.mMinBounds - r.origin);
  vec3  t1      = invDir * (aabb.mMaxBounds - r.origin);
  vec3  tmin    = min(t0, t1);
  vec3  tmax    = max(t0, t1);
  float maxcomp = max(tmin.x, max(tmin.y, tmin.z));
  float mincomp = min(tmax.x, min(tmax.y, tmax.z));
  return maxcomp > mincomp ? maxcomp : -1.0;
}


struct Payload 
{
    Ray ray;
    int cnt;
    bool hit;
};

layout(set = 1, binding = 0) uniform accelerationStructureEXT topLevelAS;

layout(location = 0) rayPayloadInEXT Payload hitValue;
layout(location = 1) rayPayloadEXT   Payload hitRecursive;
hitAttributeEXT vec3 attribs;

// returns: true if recursive ray hit, false if it didn't
bool traceRecursively(Ray ray, in int cntStart, out int finalCnt)
{
    uint rayFlags = gl_RayFlagsOpaqueEXT;
    uint cullMask = 0xff;
    float tmin = 0.001;
    float tmax = 1000.0;
    hitRecursive.cnt = hitValue.cnt + 1;
    hitRecursive.hit = true;
    traceRayEXT(topLevelAS, rayFlags, cullMask, 0 /*sbtRecordOffset*/, 0 /*sbtRecordStride*/, 0 /*missIndex*/, ray.origin, tmin, ray.direction, tmax, 1 /*payload*/);
    // return values:
    finalCnt = hitRecursive.cnt;
    return hitRecursive.hit;
}

Ray transformParentRay(mat4 M)
{
    Ray ray;
    // Copy parent:
    ray.origin    = gl_WorldRayOriginEXT;
    ray.direction = gl_WorldRayDirectionEXT;
    // Transform:
    mat4   CT = pushConstants.mCameraTransform;
    mat4  iCT = inverse(pushConstants.mCameraTransform);
    mat4 modM = inverse(M);
    ray.origin = (modM * vec4(ray.origin, 1.0)).xyz;
    ray.direction = mat3(modM) * ray.direction;
    return ray;
}


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


    // D.h. wir machen hier jetzt die selben kugeln wie im intersection shader und transformieren den ray entsprechend

    float tHit    = -1;


    mat4 M;
    mat4 M0 = mat4(
        gl_WorldToObject3x4EXT[0],
        gl_WorldToObject3x4EXT[1],
        gl_WorldToObject3x4EXT[2],
        vec4(0.0, 0.0, 0.0, 1.0)
    );

    // Exit depending on the #recursions
    if (pushConstants.mMaxRecursions < hitValue.cnt) {
        return;
    }

    Sphere s;
    s.radius = 0.5;

    s.center = vec3(0.0, 0.5, 0.0);
    M = mat4(
        vec4(s.radius, 0.0, 0.0, 0.0),
        vec4(0.0, s.radius, 0.0, 0.0),
        vec4(0.0, 0.0, s.radius, 0.0),
        vec4(s.center, 1.0)
    );
    Ray ray1 = transformParentRay(M);

    s.center = vec3(0.5, -0.5, 0.0);
    M = mat4(
        vec4(s.radius, 0.0, 0.0, 0.0),
        vec4(0.0, s.radius, 0.0, 0.0),
        vec4(0.0, 0.0, s.radius, 0.0),
        vec4(s.center, 1.0)
    );
    Ray ray2 = transformParentRay(M);

    s.center = vec3(-0.5, -0.5, 0.0);
    M = mat4(
        vec4(s.radius, 0.0, 0.0, 0.0),
        vec4(0.0, s.radius, 0.0, 0.0),
        vec4(0.0, 0.0, s.radius, 0.0),
        vec4(s.center, 1.0)
    );
    Ray ray3 = transformParentRay(M);

    int startCnt = hitValue.cnt + 1;
    int endCnt1, endCnt2, endCnt3;
    bool hit1 = traceRecursively(ray1, startCnt, endCnt1);
    bool hit2 = traceRecursively(ray2, startCnt, endCnt2);
    bool hit3 = traceRecursively(ray3, startCnt, endCnt3);
    hitValue.hit = hit1 || hit2 || hit3;
    hitValue.cnt = max(endCnt1, max(endCnt2, endCnt3));
}