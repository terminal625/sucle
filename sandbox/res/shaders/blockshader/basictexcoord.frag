#version 120
varying vec2 TexCoord;
varying float mycolor;
varying float fogratio;

uniform sampler2D ourTexture;
uniform vec3 fogcolor;

void main()
{

vec4 texcolor = texture2D(ourTexture, TexCoord);
gl_FragColor= vec4(mix(fogcolor, mycolor *  texcolor.xyz, fogratio), texcolor.a);
;
}

