#version 300 es
precision highp float;

in vec4 vs_Pos;   // object-space position
in vec4 vs_Nor;   // object-space normal
in vec4 vs_Col;

uniform mat4 u_Model;
uniform mat4 u_ViewProj;
uniform mat3 u_ModelInvTr;
uniform float u_Time;

out vec4 fs_Pos;  // object-space pos for perlin frag
out vec4 fs_Nor;  // world-space normal for lambert frag
out vec4 fs_Col;

// Helpers
mat3 rotY(float a) {
  float c = cos(a), s = sin(a);
  return mat3( c, 0.0,  s,
               0.0, 1.0, 0.0,
              -s, 0.0,  c );
}
mat3 rotZ(float a) {
  float c = cos(a), s = sin(a);
  return mat3( c, -s, 0.0,
               s,  c, 0.0,
               0.0, 0.0, 1.0 );
}

void main() {
  // Start in object space
  vec3 posObj = vs_Pos.xyz;
  vec3 nrmObj = vs_Nor.xyz;

  // Normalize height in [0,1]
  float yNorm = clamp((posObj.y + 1.0) * 0.5, 0.0, 1.0);
  // Bell-shaped taper across height (strongest mid-height, gentle near ends)
  float heightTaper = smoothstep(0.0, 0.3, yNorm) * (1.0 - smoothstep(0.7, 1.0, yNorm));

  // 1) Gentle height-based twist with taper
  float twistMax     = 0.7;          // max radians of twist from bottom->top
  float twistTimeMod = 0.5 + 0.5 * sin(u_Time * 0.6);  // 0..1 over time
  float twistAngle   = (posObj.y) * twistMax * twistTimeMod * heightTaper;
  mat3 twistRot      = rotY(twistAngle);

  posObj = twistRot * posObj;
  nrmObj = twistRot * nrmObj;

  // 2) Subtle bend (rotate around Z a tiny bit based on X)
  // This reads like a page curl; much cleaner than big normal pushes.
  float bendAmt  = 0.15 * sin(u_Time * 0.4); // time-varying strength
  float bendAng  = posObj.x * bendAmt * (0.6 + 0.4 * cos(u_Time * 0.7)); // non-uniform
  mat3 bendRot   = rotZ(bendAng);

  posObj = bendRot * posObj;
  nrmObj = bendRot * nrmObj;

  // Soft ripple with radial falloff
  // Fall off toward the cube edges to avoid ugly stretching
  float radial = length(posObj.xz);
  // Edge of a unit cube corner is ~sqrt(2) ~ 1.414; we start damping before that
  float edgeFalloff = smoothstep(1.2, 0.2, radial); // 1 near center, ~0 near edges

  float freqX = 4.0, freqY = 3.1, freqZ = 3.6;
  float speed = 2.0;
  float phase = u_Time * speed;
  float wave  = sin(posObj.x * freqX + posObj.y * freqY + posObj.z * freqZ + phase);

  float waveAmp = 0.08; // smaller than before for cleanliness
  posObj += normalize(nrmObj) * (waveAmp * wave * edgeFalloff);

  // Outputs
  fs_Pos = vec4(posObj, 1.0);
  fs_Nor = vec4(normalize(u_ModelInvTr * nrmObj), 0.0);
  fs_Col = vs_Col;

  vec4 posWorld = u_Model * vec4(posObj, 1.0);
  gl_Position   = u_ViewProj * posWorld;
}
