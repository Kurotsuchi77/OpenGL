#version 330 core

uniform int myrenderStyle;
uniform sampler2D tex;
uniform sampler2D bump_tex;
uniform int using_textures;

in vec3 mynormal;
in vec4 myvertex;
in vec2 mytexturecoordinates;
in vec3 mytangent;

in float mywave;

uniform mat4 myview_matrix;
uniform mat3 mynormal_matrix;
uniform mat4 mymodel_matrix;

uniform vec4 Ks;
uniform vec4 Kd;
uniform vec4 Ka;
uniform float Ns;

uniform vec4 light_colors[16];
uniform vec4 light_position[16];
uniform vec4 light_direction[16];
uniform int light_type[16];


out vec4 FragColor;


vec4 ComputeLight (const in vec3 direction, const in vec4 lightcolor, const in vec3 normal, const in vec3 halfvec, const in float angle, const in vec4 mydiffuse, const in vec4 myspecular, const in float myshininess) 
{
        float nDotL = dot(normal, direction)  ;         
        vec4 diffuse = mydiffuse * lightcolor * angle * max (nDotL, 0.0) ;  

        float nDotH = dot(normal, halfvec) ; 
        vec4 specular = myspecular * lightcolor * angle * pow (max(nDotH, 0.0), myshininess) ; 

        vec4 retval = diffuse + specular ; 
				
        return retval ;            
} 



void main (void)
{   
	vec3 eyepos = vec3(0,0,0);

	vec4 _mypos = myview_matrix * myvertex;
	vec3 mypos = _mypos.xyz / _mypos.w;
	vec3 mypos_to_eyepos = normalize( eyepos - mypos );

	vec3 normal = normalize(mynormal_matrix * mynormal);

	vec4 diffuse = vec4(0,0,0,1);
	if (using_textures == 1)
		diffuse = texture(tex, mytexturecoordinates.st);
	else
		diffuse = Kd;


	for (int i = 0; i < 16; ++i) {

		if (light_type[i] == 0) continue;
		
		vec4 _lightpos = myview_matrix * light_position[i];
		vec3 lightpos =  _lightpos.xyz / _lightpos.w;

		vec3 direction = normalize(mynormal_matrix * light_direction[i].xyz);

		vec3 mypos_to_lightpos = normalize( lightpos - mypos );
		float angle = 1;

		if (light_type[i] == 2) // directional light
			mypos_to_lightpos = -direction;
		else if (light_type[i] == 3) // spotlight
			angle = pow(dot(-mypos_to_lightpos,direction),40);

		if (mywave == 1.0) {

			vec3 half0 = normalize (mypos_to_lightpos + mypos_to_eyepos) ; 

			// Reflection de la texture sur l'objet
			vec3 ReflectVec = normalize(reflect(-mypos_to_lightpos, normal));

			float uu = (ReflectVec.z+ReflectVec.y)/(2.0*ReflectVec.z);
			float vv = (ReflectVec.z+ReflectVec.x)/(2.0*ReflectVec.z);
			float t = 2*sqrt(ReflectVec.x*ReflectVec.x + ReflectVec.y*ReflectVec.y + (ReflectVec.z+1)*(ReflectVec.z+1));
			uu = ReflectVec.x/t + 0.5;
			vv = ReflectVec.y/t + 0.5;
			vec4 reflectcolor = texture(tex,vec2(uu,vv)).rgba;

			reflectcolor = ComputeLight(mypos_to_lightpos, light_colors[i], normal, half0, angle, reflectcolor, Ks, Ns) ;

			FragColor += reflectcolor;
			
		} else {


			FragColor += light_colors[i] * angle *  diffuse * max(dot( normal, mypos_to_lightpos ),0.0);

			vec3 reflectedray = reflect( -mypos_to_lightpos, normal );

			//specular color
			FragColor += light_colors[i] * angle * Ks * 
				   pow( max( dot(reflectedray, mypos_to_eyepos ), 0.0), 200) ;
		}
	}

}