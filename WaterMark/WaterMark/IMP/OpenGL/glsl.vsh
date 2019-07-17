attribute vec4 Position;
attribute vec2 TextureCoords;
varying vec2 vc2_coords;

void main (void) {
    gl_Position = Position;
    vc2_coords = TextureCoords;
}
