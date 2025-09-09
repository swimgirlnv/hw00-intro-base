# rwaterso HW00 CIS 5660: The Cube

Live website can be found [here](https://swimgirlnv.github.io/hw00-intro-base/).

For this project, we start off with the making of 

### The cube.

Found in `src/geometry/Cube.ts`. I wanted a cube centered around (0,0,0). Using `Square.ts` as an initial guide, we have the indicies in 3D space where the front is z=+1, back is z=-1, etc for x and y. I use 4x4 matricies here to turn the matrix into homongenous coordinates for the 3D points (this.positions) and vectors (this.normals).

### `perlin-frag.glsl`
I wanted to have fun with time as an input (originally inspired by Shadertoys ["new"](https://www.shadertoy.com/new) file). This shader uses single-octave 3D Perlin noise to color each fragment. The noise is sampled in object space and animated over time by sliding along the Z-axis. The output is remapped to [0,1], shaped with smoothstep, and multiplied by u_Color.

### `trig-vert.glsl`
The vertex shader twists around Y based on height and time, with a smooth taper near the top and bottom.  Normals are rotated alongside positions so the lighting stays correct, and everything is finally transformed into clip space. The cube kinda becomes like a jelly cube!

### Fun with icosphere!

https://i.imgur.com/7DsHi5B.mp4

