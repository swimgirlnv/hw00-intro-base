import { vec3, vec4 } from "gl-matrix";
import Drawable from "../rendering/gl/Drawable";
import { gl } from "../globals";

class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;

  constructor(center: vec3) {
    super(); // Call the constructor of the super class. This is required.
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
  }

  create() {
    const idx: number[] = [];
    for (let f = 0; f < 6; f++) {
      const b = f * 4;
      idx.push(b, b + 1, b + 2, b, b + 2, b + 3);
    }
    this.indices = new Uint32Array(idx);
    this.normals = new Float32Array([
      // Front
      0, 0, 1, 0, 
      0, 0, 1, 0, 
      0, 0, 1, 0, 
      0, 0, 1, 0,
      // Back
      0, 0, -1, 0, 
      0, 0, -1, 0, 
      0, 0, -1, 0, 
      0, 0, -1, 0,
      // Left
      -1, 0, 0, 0, 
      -1, 0, 0, 0, 
      -1, 0, 0, 0, 
      -1, 0, 0, 0,
      // Right
      1, 0, 0, 0, 
      1, 0, 0, 0, 
      1, 0, 0, 0, 
      1, 0, 0, 0,
      // Top
      0, 1, 0, 0, 
      0, 1, 0, 0, 
      0, 1, 0, 0, 
      0, 1, 0, 0,
      // Bottom
      0, -1, 0, 0, 
      0, -1, 0, 0, 
      0, -1, 0, 0, 
      0, -1, 0, 0,
    ]);

    // Per face normals
    this.positions = new Float32Array([
      // Front  (z=+1)
      -1, -1, 1, 1, 
      1, -1, 1, 1, 
      1, 1, 1, 1, 
      -1, 1, 1, 1,
      // Back   (z=-1)
      1, -1, -1, 1, 
      -1, -1, -1, 1, 
      -1, 1, -1, 1, 
      1, 1, -1, 1,
      // Left   (x=-1)
      -1, -1, -1, 1, 
      -1, -1, 1, 1, 
      -1, 1, 1, 1, 
      -1, 1, -1, 1,
      // Right  (x=+1)
      1, -1, 1, 1, 
      1, -1, -1, 1, 
      1, 1, -1, 1, 
      1, 1, 1, 1,
      // Top    (y=+1)
      -1, 1, 1, 1, 
      1, 1, 1, 1, 
      1, 1, -1, 1, 
      -1, 1, -1, 1,
      // Bottom (y=-1)
      -1, -1, -1, 1, 
      1, -1, -1, 1, 
      1, -1, 1, 1, 
      -1, -1, 1, 1,
    ]);

    this.generateIdx();
    this.generatePos();
    this.generateNor();

    this.count = this.indices.length;
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

    console.log(`Created Cube`);
  }
}

export default Cube;
