#version 300 es
precision highp float;

// Perlin frag shader!
// For each pixel, this builds a 3D point `samplePos` from the pixel's
// object-space position, evaluates single-octave 3D Perlin noise at it,
// remaps that noise to [0, 1], tints it with u_Color, and writes the result.

uniform vec4 u_Color;   
uniform float u_Time;          // animate the noise by moving along Z
in vec4 fs_Pos;                // object-space position
out vec4 out_Col;

// helpers: modulo & permutation hash for pseudo-random value per lattice corner
float mod289(float x) { return x - floor(x * (1.0/289.0)) * 289.0; }
vec3  mod289(vec3 x) { return x - floor(x * (1.0/289.0)) * 289.0; }
vec4  mod289(vec4 x) { return x - floor(x * (1.0/289.0)) * 289.0; }

vec4 permute(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }

// quintic fade curve (smooth interpolation weights)
vec3 fade(vec3 t) { return t*t*t*(t*(t*6.0 - 15.0) + 10.0); }

// pick one of 12 gradient directions from a hash
vec3 gradientFromHash(float hash) {
  int idx = int(floor(hash * 12.0)) % 12;
  const vec3 gradTable[12] = vec3[12](
    vec3( 1.0,  1.0,  0.0), vec3(-1.0,  1.0,  0.0), vec3( 1.0, -1.0,  0.0), vec3(-1.0, -1.0,  0.0),
    vec3( 1.0,  0.0,  1.0), vec3(-1.0,  0.0,  1.0), vec3( 1.0,  0.0, -1.0), vec3(-1.0,  0.0, -1.0),
    vec3( 0.0,  1.0,  1.0), vec3( 0.0, -1.0,  1.0), vec3( 0.0,  1.0, -1.0), vec3( 0.0, -1.0, -1.0)
  );
  return gradTable[idx];
}

// single-octave 3D Perlin noise
float perlin3d(vec3 samplePos) {
  // integer lattice cell and fractional part
  vec3 cellCoord   = floor(samplePos);
  vec3 localPos    = samplePos - cellCoord;
  vec3 fadeWeights = fade(localPos);

  // build hashed indices for the cube’s x/y/z corners
  vec4 cornerX = mod289(vec4(cellCoord.x, cellCoord.x + 1.0, cellCoord.x,       cellCoord.x + 1.0));
  vec4 cornerY = mod289(vec4(cellCoord.y, cellCoord.y,       cellCoord.y + 1.0, cellCoord.y + 1.0));
  vec4 cornerZ0 = mod289(vec4(cellCoord.z));
  vec4 cornerZ1 = mod289(vec4(cellCoord.z + 1.0));

  // permute to spread out pseudo-random indices
  vec4 permXY  = permute(permute(cornerX) + cornerY);
  vec4 permXYZ0 = permute(permXY + cornerZ0); // 4 bottom corners
  vec4 permXYZ1 = permute(permXY + cornerZ1); // 4 top corners

  // gradients for each of the 8 cube corners
  vec4 hash0 = permXYZ0 * (1.0 / 289.0);
  vec4 hash1 = permXYZ1 * (1.0 / 289.0);

  vec3 grad000 = gradientFromHash(hash0.x);
  vec3 grad100 = gradientFromHash(hash0.y);
  vec3 grad010 = gradientFromHash(hash0.z);
  vec3 grad110 = gradientFromHash(hash0.w);
  vec3 grad001 = gradientFromHash(hash1.x);
  vec3 grad101 = gradientFromHash(hash1.y);
  vec3 grad011 = gradientFromHash(hash1.z);
  vec3 grad111 = gradientFromHash(hash1.w);

  // corner offset vectors (point relative to each corner)
  vec3 offset000 = localPos + vec3( 0.0,  0.0,  0.0);
  vec3 offset100 = localPos + vec3(-1.0,  0.0,  0.0);
  vec3 offset010 = localPos + vec3( 0.0, -1.0,  0.0);
  vec3 offset110 = localPos + vec3(-1.0, -1.0,  0.0);
  vec3 offset001 = localPos + vec3( 0.0,  0.0, -1.0);
  vec3 offset101 = localPos + vec3(-1.0,  0.0, -1.0);
  vec3 offset011 = localPos + vec3( 0.0, -1.0, -1.0);
  vec3 offset111 = localPos + vec3(-1.0, -1.0, -1.0);

  // dot product of gradient with offset at each corner
  float dot000 = dot(grad000, offset000);
  float dot100 = dot(grad100, offset100);
  float dot010 = dot(grad010, offset010);
  float dot110 = dot(grad110, offset110);
  float dot001 = dot(grad001, offset001);
  float dot101 = dot(grad101, offset101);
  float dot011 = dot(grad011, offset011);
  float dot111 = dot(grad111, offset111);

  // interpolate along x, then y, then z
  float interpX00 = mix(dot000, dot100, fadeWeights.x);
  float interpX10 = mix(dot010, dot110, fadeWeights.x);
  float interpX01 = mix(dot001, dot101, fadeWeights.x);
  float interpX11 = mix(dot011, dot111, fadeWeights.x);

  float interpY0 = mix(interpX00, interpX10, fadeWeights.y);
  float interpY1 = mix(interpX01, interpX11, fadeWeights.y);

  float interpZ = mix(interpY0, interpY1, fadeWeights.z);

  // scale to keep range roughly [-1, 1]
  return interpZ * 1.06066;
}

void main() {
  // scale controls feature size (smaller = larger blobs)
  float noiseScale = 1.2;

  // 3D coordinate: object-space xyz; animate by sliding along Z
  vec3 noisePos = fs_Pos.xyz * noiseScale;
  noisePos.z += u_Time * 0.25;

  // sample single-octave 3D perlin
  float noiseValue = perlin3d(noisePos); // [-1, 1]
  noiseValue = noiseValue * 0.5 + 0.5;   // remap -> [0, 1]

  // gentle shaping
  noiseValue = smoothstep(0.05, 0.95, noiseValue);

  vec3 finalColor = u_Color.rgb * noiseValue;
  out_Col = vec4(finalColor, 1.0);
}
