#version 330 core

layout(location = 0) in vec4 vertex_modelspace;
layout(location = 2) in vec3 normal_modelspace;
layout(location = 3) in vec2 texture_modelspace;
layout(location = 4) in vec3 tangent_modelspace;


out vec3 mynormal;
out vec4 myvertex;
out vec2 mytexturecoordinates;
out vec3 mytangent;

uniform mat4 myprojection_matrix;
uniform mat4 myview_matrix;
uniform mat3 mynormal_matrix;
uniform mat4 mymodel_matrix;

uniform int wave;
uniform float dx;
uniform float dy;
uniform float wave_intensity;

uniform float t; // gestion de l'animation


out float mywave;


float computeHeight(float x, float y)
{
   float dist = (x+dx)*(x+dx) + (y+dy)*(y+dy);
   dist = pow(dist, 0.5);
   float rdist = (40.0 - dist)/10.0;
  
   float zv = rdist*0.02*sin(dist*1.2 - t*1.0 + 1.57) - 0.45;
   return zv * wave_intensity;
}


void main() {

	if (wave == 1) {

		float delta = 0.001;
		float z1 = computeHeight(vertex_modelspace.x+delta, vertex_modelspace.z) - computeHeight(vertex_modelspace.x, vertex_modelspace.z);
		z1 = z1/delta;

		float z2 = computeHeight(vertex_modelspace.x, vertex_modelspace.z+delta) - computeHeight(vertex_modelspace.x, vertex_modelspace.z);
		z2 = z2/delta;

		vec3 t1 = vec3(1, z1, 0);
		vec3 t2 = vec3(0, -z2, -1);
		mynormal = normalize(cross(t1, t2));

		float zv =  computeHeight(vertex_modelspace.x, vertex_modelspace.z);

		myvertex = vec4(vertex_modelspace.x,zv,vertex_modelspace.z,1.0);
		gl_Position = myprojection_matrix * myview_matrix * mymodel_matrix * myvertex;

	} else if (wave == 0) {
	    gl_Position = myprojection_matrix * myview_matrix * mymodel_matrix * vertex_modelspace; 
		myvertex = vertex_modelspace;
		mynormal = normal_modelspace;
	}

	mywave = wave;
	mytexturecoordinates = texture_modelspace;
	mytangent = tangent_modelspace;
}
